//  Renderer.swift
//  Goom

import CoreGraphics
import Foundation

extension Int {
    func clamp(_ lowerBound: Int, _ upperBound: Int) -> Int {
        return Swift.max(lowerBound, Swift.min(upperBound, self))
    }

    init(flooring x: Float) {
        self.init(floor(x))
    }

    init(ceiling x: Float) {
        self.init(ceil(x))
    }

    init(rounding x: Float) {
        self.init(round(x))
    }

    init(flooring x: Float, mod n: Int) {
        self.init(mod(Int(flooring: x), n))
    }
}

extension World {

    class View {
        let screen: Screen
        var width: Int { screen.width }
        var height: Int { screen.height }
        // Image coordinates of the leftmost pixel
        let x0c: Float
        // Image coordiantes of the topmost pixel
        let y0c: Float
        let focalLength: Float
        let minDepth = Float(0.01)
        let maxDepth = Float(1000)
        // Top vertical pixel index of open span
        var apertureTop: [Int]
        // Bottom vertical pixel of open span + 1
        var apertureBottom: [Int]
        var palettes: [[UInt32]] = []

        init(in screen: Screen) {
            self.screen = screen
            x0c = -Float(screen.width - 1) / Float(2)
            y0c = Float(screen.height - 1) / Float(2)
            focalLength = Float(screen.width) / (2.0 * tan(screen.fieldOfView / 2.0))
            apertureTop = [Int](repeating: 0, count: screen.width)
            apertureBottom = [Int](repeating: screen.height, count: screen.width)
        }

        func clip(segment: inout Segment, range: inout Range<Float>) {
            let halfWidth = Float(width) / 2
            for boundary in [
                Line(normal: [-focalLength, halfWidth], offset: 0),
                Line(normal: [focalLength, halfWidth], offset: 0),
                Line(normal: [0, 1], offset: -minDepth),
            ] {
                let (visibleRange, _) = boundary.cut(segment: segment)
                segment = segment.slice(part: visibleRange)
                range = range.slice(part: visibleRange)
                if range.isEmpty { break }
            }
        }
    }

    private static func vfill(
        _ screen: Screen,
        _ xp: Int,
        _ ytp: Int,
        _ ybp: Int,
        _ column: [UInt8],
        _ mask: [UInt8]?,
        _ palette: [UInt32],
        _ vt: Float,
        _ dv: Float
    ) {
        @inline(__always) func kernel(_ height: Int, _ mod: (Int, Int) -> Int = mod) {
            var v = Int(vt * Float(1 << 16))
            let dv = Int(dv * Float(1 << 16))
            var pixel = screen.pixels.baseAddress! + xp + ytp * screen.width
            let end = screen.pixels.baseAddress! + xp + ybp * screen.width
            while pixel < end {
                let vp = mod(v >> 16, height)
                if (mask?[vp] ?? 1) != 0 {
                    pixel.pointee = palette[Int(column[Int(vp)])]
                }
                v += dv
                pixel += screen.width
            }
        }
        switch column.count {
        case 8: kernel(8, mod2)
        case 16: kernel(16, mod2)
        case 32: kernel(32, mod2)
        case 64: kernel(64, mod2)
        case 128: kernel(128, mod2)
        default: kernel(column.count)
        }
    }

    class Drawable {
        let texture: Texture
        let uSpace: Space
        let vSpace: Space
        let heights: (bottom: Float, top: Float)

        let inverseDepthSpace: Space
        let x1c: Float
        let x2c: Float
        let xrangep: Range<Int>
        let apertureTop: [Int]
        let apertureBottom: [Int]

        init(
            in view: View,
            texture: Texture,
            base: Segment,
            uSpace: Space,
            vSpace: Space,
            heights: (bottom: Float, top: Float)
        ) {
            self.texture = texture
            self.heights = heights
            self.uSpace = uSpace
            self.vSpace = vSpace

            let depth1 = base.v1.y
            let depth2 = base.v2.y
            let inverseDepth1 = 1 / depth1
            let inverseDepth2 = 1 / depth2
            inverseDepthSpace = Space(begin: inverseDepth1, end: inverseDepth2)

            x1c = view.focalLength * base.v1.x * inverseDepth1
            x2c = view.focalLength * base.v2.x * inverseDepth2

            let xlp = Int(ceiling: min(x1c, x2c) - view.x0c)
            let xrp = Int(ceiling: max(x1c, x2c) - view.x0c)
            xrangep = xlp..<xrp

            apertureTop = Array(view.apertureTop[xrangep])
            apertureBottom = Array(view.apertureBottom[xrangep])
        }

        func draw(in view: View, withPalettes palettes: [[UInt32]]) {
            if xrangep.isEmpty { return }
            let screen = view.screen

            for (i, xp) in xrangep.enumerated() {
                let xc = Float(xp) + view.x0c
                let alpha = (xc - x1c) / (x2c - x1c)
                let inverseDepth = inverseDepthSpace[alpha]
                let depth = 1 / inverseDepth
                let lambda = alpha * depth * inverseDepthSpace.end
                let depthIndex = max(0, depth - view.minDepth) / (view.maxDepth - view.minDepth)

                func project(y: Float) -> Float { view.focalLength * inverseDepth * y }
                let ytc = project(y: heights.top)
                let ybc = project(y: heights.bottom)

                let ytp = max(Int(ceiling: view.y0c - ytc), apertureTop[i])
                let ybp = min(Int(ceiling: view.y0c - ybc), apertureBottom[i])
                if ytp >= ybp { continue }

                let u = uSpace[lambda]
                let up = Int(flooring: u, mod: texture.width)
                let column = texture.pixels[up]
                let mask = texture.mask?[up]
                let lightLevel = min(Int(Float(palettes.count) * depthIndex), palettes.count - 1)

                let yc = view.y0c - Float(ytp)
                let dv = (vSpace.begin - vSpace.end) / (ybc - ytc)
                let v = dv * (yc - ytc) + vSpace.end
                vfill(screen, xp, ytp, ybp, column, mask, palettes[lightLevel], v, -dv)
            }
        }
    }

    func postpone(thingsInFragment fragment: WallFragment, forSide side: Side, in view: View)
        -> [Drawable]
    {
        guard let map = map else { return [] }
        var postponed: [Drawable] = []
        let thingFragments =
            side == .left ? fragment.leftThingFragments : fragment.rightThingFragments

        let posedThingFragments = thingFragments.map {
            (thingFragment: $0, depth: map.player.toCamera(vector: $0.thing.position).y)
        }

        for (thingFragment, _) in posedThingFragments.sorted(by: { $0.depth < $1.depth }) {
            let thing = thingFragment.thing
            guard thing.textures.count > 0, let texture = thing.textures[0] else { continue }

            let height = thing.height - map.player.height
            let heights = (bottom: height, top: height + Float(texture.height))

            var base = map.player.toCamera(segment: thingFragment.asSegment)
            var range = thingFragment.range
            view.clip(segment: &base, range: &range)
            if range.isEmpty { continue }

            let us = Space(begin: 0, end: Float(texture.width)).slice(part: range)
            let vs = Space(begin: Float(texture.height), end: 0)
            postponed.append(
                Drawable(
                    in: view,
                    texture: texture,
                    base: base,
                    uSpace: us,
                    vSpace: vs,
                    heights: heights
                )
            )
        }
        return postponed
    }

    func draw(fragment: WallFragment, in view: View, appending postponed: inout [Drawable])
        -> BSP<WallFragment>.VisitState
    {
        guard let map = map else { return .end }
        let screen = view.screen
        let wall = fragment.wall
        let frontSide = wall.base.side(ofPoint: map.player.position)
        let wallFacesPlayer = frontSide == .left

        // Postpone drawing things in front of this plane.
        postponed += postpone(
            thingsInFragment: fragment,
            forSide: wallFacesPlayer ? .left : .right,
            in: view
        )

        // Obtain the wall fragment base in the camera coordinates.
        var base = map.player.toCamera(segment: wall.base.slice(part: fragment.range))
        let sa = sin(map.player.angle)
        let ca = cos(map.player.angle)

        // Cull the entire subtree containing this wall fragment if possible.
        do {
            // Intersection with x=0:
            //
            // (x2 - x1) l + x1 = x
            // (z2 - z1) l + z1 = z
            // z = z1 + (z2 - z1)/(x2 - x1) * (x - x1)
            // z = (z1 - (z2 - z1)/(x2 - x1) * x1) + (z2 - z1)/(x2 - x1) * x
            // z = (z1 - slope * x1) + slope * x
            // slope = (z2 - z1)/(x2 - x1)
            let x1 = base.v1.x
            let z1 = base.v1.y
            let x2 = base.v2.x
            let z2 = base.v2.y
            let threshold = Float(0.00001)
            let halfWidth = Float(view.width) / 2
            if abs(x2 - x1) > threshold {
                let slope = (z2 - z1) / (x2 - x1)
                if z1 - slope * x1 < -threshold, abs(slope) <= (halfWidth / view.focalLength) {
                    return .cull
                }
            }
        }

        // Postpone drawing thing behind this plane.
        defer {
            postponed += postpone(
                thingsInFragment: fragment,
                forSide: wallFacesPlayer ? .right : .left,
                in: view
            )
        }

        // Clip the wall fragment base to the frustrum.
        var range = fragment.range
        view.clip(segment: &base, range: &range)
        if range.isEmpty { return .more }

        // Project the wall fragment base to the image plane.
        let depth1 = base.v1.y
        let depth2 = base.v2.y
        let inverseDepthSpace = Space(begin: 1 / depth1, end: 1 / depth2)
        let x1c = view.focalLength * base.v1.x * inverseDepthSpace.begin
        let x2c = view.focalLength * base.v2.x * inverseDepthSpace.end
        let xlp = Int(ceiling: min(x1c, x2c) - view.x0c)
        let xrp = Int(ceiling: max(x1c, x2c) - view.x0c)
        if xlp >= xrp { return .more }

        assert(xlp >= 0)
        assert(xlp <= xrp)
        assert(xrp <= view.width)

        for xp in xlp..<xrp {
            let xc = Float(xp) + view.x0c
            let alpha = (xc - x1c) / (x2c - x1c)
            let inverseDepth = inverseDepthSpace[alpha]
            let depth = 1 / inverseDepth
            let lambdaFragment = alpha * depth * inverseDepthSpace.end
            let depthIndex = max(0, depth - view.minDepth) / (view.maxDepth - view.minDepth)

            let lambda = (range.upperBound - range.lowerBound) * lambdaFragment + range.lowerBound

            func project(y: Float) -> Float {
                view.focalLength * inverseDepth * (y - map.player.height)
            }

            @inline(__always) func getAperture(_ ytc: Float, _ ybc: Float) -> (Int, Int) {
                let ytp = max(Int(ceiling: view.y0c - ytc), view.apertureTop[xp])
                let ybp = min(Int(ceiling: view.y0c - ybc), view.apertureBottom[xp])
                if ytp <= view.apertureTop[xp] {
                    view.apertureTop[xp] = max(view.apertureTop[xp], ybp)
                }
                if ybp >= view.apertureBottom[xp] {
                    view.apertureBottom[xp] = min(view.apertureBottom[xp], ytp)
                }
                return (ytp, ybp)
            }

            func draw(wall part: Wall.Part, _ ytc: Float, _ ybc: Float) {
                let (ytp, ybp) = getAperture(ytc, ybc)
                if ytp >= ybp { return }
                guard let texture = part.texture else { return }

                let u = part.uSpace[lambda]
                let up = Int(flooring: u, mod: texture.width)
                let column = texture.pixels[up]
                let lightLevel = min(Int(Float(palettes.count) * depthIndex), palettes.count - 1)

                let yc = view.y0c - Float(ytp)
                let dv = (part.vSpace.begin - part.vSpace.end) / (ybc - ytc)
                let vt = dv * (yc - ytc) + part.vSpace.end
                World.vfill(screen, xp, ytp, ybp, column, nil, palettes[lightLevel], vt, -dv)
            }

            func draw(sky texture: Texture, _ ytp: Int, _ ybp: Int) {
                let angle = atan2(view.focalLength, Float(xp) + view.x0c) + map.player.angle
                let u = 2 * Float(texture.width) * angle / Float.pi
                let up = Int(flooring: u, mod: texture.width)
                let column = texture.pixels[up]

                let ytc = Float(view.height) / 2
                let ybc = -ytc / 3
                let yc = view.y0c - Float(ytp)
                let dv = Float(texture.height) / (ybc - ytc)
                let vt = dv * (yc - ytc)
                World.vfill(screen, xp, ytp, ybp, column, nil, palettes[0], vt, -dv)
            }

            func draw(flat part: Sector.Part, _ ytc: Float, _ ybc: Float) {
                let (ytp, ybp) = getAperture(ytc, ybc)
                if ytp >= ybp { return }
                guard let texture = part.texture else { return }

                if texture.isSky { return draw(sky: texture, ytp, ybp) }

                let height = part.height - map.player.height
                if abs(height) < 0.001 { return }

                let depthScaling = Float(palettes.count) / (view.maxDepth - view.minDepth)
                let scaledMinDepth = depthScaling * view.minDepth
                let xc = Float(xp) + view.x0c
                let yc = view.y0c - Float(ytp)
                let dInverseDepth = -1 / (height * view.focalLength)
                var inverseDepth = yc / (height * view.focalLength)
                let xcf = xc / view.focalLength
                let u0 = (sa * xcf + ca) / depthScaling
                let v0 = (-ca * xcf + sa) / depthScaling

                @inline(__always) func fill(
                    _ width: Int,
                    _ height: Int,
                    _ mod: (Int, Int) -> Int = mod
                ) {
                    for pixelIndex in stride(
                        from: xp + ytp * screen.width,
                        to: xp + ybp * screen.width,
                        by: screen.width
                    ) {
                        let depth = depthScaling / inverseDepth
                        let u = depth * u0 + map.player.position.x
                        let v = -(depth * v0 + map.player.position.y)  // textures are indexed from the top down
                        let up = mod(Int(flooring: u), width)
                        let vp = mod(Int(flooring: v), height)
                        let lightLevel = max(
                            0,
                            min(Int(depth - scaledMinDepth), palettes.count - 1)
                        )
                        let color = texture.pixels[up][vp]
                        let value = palettes[lightLevel][Int(color)]
                        screen.pixels[pixelIndex] = value
                        inverseDepth += dInverseDepth
                    }
                }

                if texture.height == 64, texture.width == 64 {
                    fill(64, 64, mod2)
                }
                else {
                    fill(texture.width, texture.height)
                }
            }

            let top: Float = 100_000
            let bottom: Float = -100_000

            if wall.rightSector == nil {
                // Draw a solid wall.
                if frontSide == .left {
                    let frontSector = wall.leftSector
                    let frontCeiling = project(y: frontSector.ceiling.height)
                    let frontFloor = project(y: frontSector.floor.height)
                    draw(flat: wall.leftSector.ceiling, top, frontCeiling)
                    draw(flat: wall.leftSector.floor, frontFloor, bottom)
                    draw(wall: wall.middle, frontCeiling, frontFloor)
                }
            }
            else {
                // Draw a wall with an open mid section.
                let (frontSector, backSector) =
                    (frontSide == .left)
                    ? (wall.leftSector, wall.rightSector!) : (wall.rightSector!, wall.leftSector)
                let frontCeiling = project(y: frontSector.ceiling.height)
                let frontFloor = project(y: frontSector.floor.height)
                let backCeiling = project(y: backSector.ceiling.height)
                let backFloor = project(y: backSector.floor.height)

                // Special case for sky.
                let skipTopWall =
                    (wall.top.texture == nil) && (frontSector.ceiling.texture?.isSky ?? false)
                let skipTopFlat =
                    skipTopWall && (frontSector.ceiling.height < backSector.ceiling.height)

                // Draw both flats first as, when the aperture is negative (e.g. elevator),
                // they may occlude the walls.
                if !skipTopFlat { draw(flat: frontSector.ceiling, top, frontCeiling) }
                draw(flat: frontSector.floor, frontFloor, bottom)

                // Draw the walls.
                if !skipTopWall { draw(wall: wall.top, frontCeiling, backCeiling) }
                draw(wall: wall.bottom, backFloor, frontFloor)
            }
        }

        // Draw a semi-transparent mid wall.
        if wall.rightSector != nil, let texture = wall.middle.texture {
            let heights = (
                max(wall.leftSector.floor.height, wall.rightSector!.floor.height)
                    - map.player.height,
                min(wall.leftSector.ceiling.height, wall.rightSector!.ceiling.height)
                    - map.player.height
            )
            let us = wall.middle.uSpace.slice(part: range)
            let vs = wall.middle.vSpace
            postponed.append(
                Drawable(
                    in: view,
                    texture: texture,
                    base: base,
                    uSpace: us,
                    vSpace: vs,
                    heights: heights
                )
            )
        }

        return .more
    }

    func draw(in screen: Screen) {
        guard let map = map else { return }

        // Reposition the player on top of the floor under them.
        map.bsp.root?.visit(
            from: map.player.position,
            nearestFirst: true,
            action: {
                fragment in
                map.player.height =
                    fragment.wall.groundHeight(under: map.player.position, atPhase: self.phase)
                    + map.player.hegightFromGround
                return .end
            }
        )

        // Reposition the things.
        map.placeThings(atTime: phase)

        let view = View(in: screen)
        var postponed: [Drawable] = []
        var numDrawn = 0
        let maxNumDrawn = 2000
        var checkPeriodMask = 1

        var screenShots: [CGImage] = []
        var screenShotChecksum: UInt32 = 1

        func takeScreenshot() {
            guard self.screenshotActionsQueue.count > 0, screenShots.count < 100 else { return }
            let sum = checksum(of: UnsafeBufferPointer<UInt32>(screen.pixels))
            if sum != screenShotChecksum {
                screenShotChecksum = sum
                if let image = screen.toCGImage() {
                    screenShots.append(image)
                }
            }
        }

        if self.screenshotActionsQueue.count > 0 {
            screen.fill()
        }
        takeScreenshot()

        map.bsp.root?.visit(
            from: map.player.position,
            nearestFirst: true,
            action: {
                fragment in
                let state = draw(fragment: fragment, in: view, appending: &postponed)
                numDrawn += 1
                if numDrawn & checkPeriodMask == 0 {
                    if zip(view.apertureTop, view.apertureBottom).allSatisfy({ $0.0 >= $0.1 }) {
                        return .end
                    }
                    checkPeriodMask = (checkPeriodMask << 1) | 1
                }
                takeScreenshot()
                return (numDrawn >= maxNumDrawn) ? .end : state
            }
        )

        for drawable in postponed.reversed() {
            drawable.draw(in: view, withPalettes: palettes)
            takeScreenshot()
        }

        // Prepare animations for the next cycle.
        time += 1 / 60.0
        phase = (cos(time) + 1) / 2

        map.walls.forEach {
            $0.top.set(phase: phase)
            $0.middle.set(phase: phase)
            $0.bottom.set(phase: phase)
        }

        map.sectors.forEach {
            $0.floor.set(phase: phase)
            $0.ceiling.set(phase: phase)
        }

        if let action = self.screenshotActionsQueue.popLast() {
            action(screenShots)
        }
    }
}
