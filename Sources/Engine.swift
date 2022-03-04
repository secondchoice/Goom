// Engine.swift

import CoreGraphics
import Foundation

class RuntimeError: LocalizedError {
    private let message: String

    init(_ message: String) {
        self.message = message
    }

    public var errorDescription: String? {
        return message
    }
}

// MARK: - Sector

class Sector {
    struct Part {
        class State {
            var height: Float
            init(height: Float) { self.height = height }
        }

        let state: State
        let heightStates: [Float]
        let texture: Texture?

        init(heights: [Float], texture: Texture?) {
            self.heightStates = heights
            self.texture = texture
            self.state = State(height: heights[0])
        }

        func set(phase: Float) {
            if heightStates.count == 2 {
                state.height = (heightStates[1] - heightStates[0]) * phase + heightStates[0]
            }
            else {
                state.height = heightStates[0]
            }
        }

        var height: Float { state.height }
    }

    let ceiling: Part
    let floor: Part

    init(ceiling: Part, floor: Part) {
        self.ceiling = ceiling
        self.floor = floor
    }
}

// MARK: - Wall

class Wall {
    struct Part {
        class State {
            var uSpace: Space
            var vSpace: Space
            init(uSpace: Space, vSpace: Space) {
                self.uSpace = uSpace
                self.vSpace = vSpace
            }
        }

        private let state: State
        let texture: Texture?
        let uSpaceStates: [Space]
        let vSpaceStates: [Space]
        var uSpace: Space { state.uSpace }
        var vSpace: Space { state.vSpace }

        init(texture: Texture?, uSpaceStates: [Space], vSpaceStates: [Space]) {
            self.texture = texture
            self.uSpaceStates = uSpaceStates
            self.vSpaceStates = vSpaceStates
            self.state = State(uSpace: uSpaceStates[0], vSpace: vSpaceStates[0])
        }

        func set(phase: Float) {
            if uSpaceStates.count == 2 {
                state.uSpace = (uSpaceStates[1] - uSpaceStates[0]) * phase + uSpaceStates[0]
            }
            else {
                state.uSpace = uSpaceStates[0]
            }
            if vSpaceStates.count == 2 {
                state.vSpace = (vSpaceStates[1] - vSpaceStates[0]) * phase + vSpaceStates[0]
            }
            else {
                state.vSpace = vSpaceStates[0]
            }
        }
    }

    let base: Segment
    let top: Part
    let middle: Part
    let bottom: Part
    let leftSector: Sector
    let rightSector: Sector?

    init(
        base: Segment,
        top: Part,
        middle: Part,
        bottom: Part,
        frontSector: Sector,
        backSector: Sector?
    ) {
        self.base = base
        self.top = top
        self.middle = middle
        self.bottom = bottom
        leftSector = frontSector
        rightSector = backSector
    }

    func groundHeight(under position: Vector, atPhase _: Float) -> Float {
        if base.side(ofPoint: position) == .left {
            return leftSector.floor.state.height
        }
        else {
            if let backFloor = rightSector {
                return backFloor.floor.state.height
            }
            else {
                return 0
            }
        }
    }
}

// MARK: - Thing

class Thing {
    var position: Vector
    var angle: Float
    let textures: [Texture?]
    var height: Float = 0

    init(
        position: Vector,
        angle: Float,
        textures: [Texture?]
    ) {
        self.position = position
        self.angle = angle
        self.textures = textures
    }

    func base(withVieweingAngle angle: Float) -> Segment {
        guard textures.count > 0, let texture = textures[0] else {
            return Segment(v1: position, v2: position)
        }
        let dx = sin(angle) * Float(texture.width) / 2
        let dz = cos(angle) * Float(texture.width) / 2
        let x1 = position.x - dx
        let x2 = position.x + dx
        let z1 = position.y - dz
        let z2 = position.y + dz
        return Segment(v1: [x1, z1], v2: [x2, z2])
    }
}

// MARK: - Fragments

final class WallFragment: Segmentable {
    let wall: Wall
    let range: Range<Float>
    var leftThingFragments: [ThingFragment] = []
    var rightThingFragments: [ThingFragment] = []
    var asSegment: Segment { wall.base.slice(part: range) }

    init(ofWall wall: Wall, range: Range<Float> = 0..<1) {
        self.wall = wall
        self.range = range
    }

    func slice(part: Range<Float>) -> WallFragment {
        return WallFragment(ofWall: wall, range: range.slice(part: part))
    }
}

final class ThingFragment: Segmentable {
    let thing: Thing
    let range: Range<Float>
    let angle: Float
    var asSegment: Segment { thing.base(withVieweingAngle: angle).slice(part: range) }

    init(ofThing thing: Thing, atAngle angle: Float, range: Range<Float> = 0..<1) {
        self.thing = thing
        self.range = range
        self.angle = angle
    }

    func slice(part: Range<Float>) -> ThingFragment {
        return ThingFragment(ofThing: thing, atAngle: angle, range: range.slice(part: part))
    }
}

// MARK: - Texture

class Texture {
    let name: String
    var pixels: [[UInt8]]
    var mask: [[UInt8]]?
    let width: Int
    let height: Int
    let offset: Vector
    let isSky: Bool

    init(
        name: String,
        pixels: [[UInt8]],
        mask: [[UInt8]]?,
        width: Int,
        height: Int,
        offset: Vector,
        isSky: Bool
    ) {
        self.name = name
        self.pixels = pixels
        self.mask = mask
        self.width = width
        self.height = height
        self.offset = offset
        self.isSky = isSky
    }
}

// MARK: - Player

class Player {
    var position: Vector = .init(x: 0, y: -2)
    var angle: Float = 0
    var height: Float = 0

    let maxLinearSpeed: Float = 10
    let maxStrafeSpeed: Float = 10
    let maxAngularSpeed: Float = 0.06
    let hegightFromGround: Float = 45

    init(
        position: Vector = .init(x: 0, y: -2),
        angle: Float = 0
    ) {
        self.position = position
        self.angle = angle
    }

    func toCamera(vector v: Vector) -> Vector {
        let c = cos(angle)
        let s = sin(angle)
        let vc = v - position
        return Vector(x: s * vc.x - c * vc.y, y: c * vc.x + s * vc.y)
    }

    func toCamera(segment s: Segment) -> Segment {
        return Segment(v1: toCamera(vector: s.v1), v2: toCamera(vector: s.v2))
    }

    func update(with joypad: Joypad) {
        let currentLinearSpeed = maxLinearSpeed * joypad.walk
        let currentAngularSpeed = maxAngularSpeed * joypad.turn
        let currentStrafeSpeed = maxStrafeSpeed * joypad.strafe
        let dx = cos(angle)
        let dy = sin(angle)
        position.x += currentLinearSpeed * dx + currentStrafeSpeed * dy
        position.y += currentLinearSpeed * dy - currentStrafeSpeed * dx
        angle -= currentAngularSpeed
    }
}

func place(thingFragment: ThingFragment, in node: BSP<WallFragment>.Node, atPhase phase: Float) {
    let base = thingFragment.asSegment

    let (left, right) = Line(containing: node.primitive.asSegment).cut(segment: base)

    if !left.isEmpty {
        if let leftNode = node.left {
            place(thingFragment: thingFragment.slice(part: left), in: leftNode, atPhase: phase)
        }
        else {
            node.primitive.leftThingFragments.append(thingFragment)
            if thingFragment.range.contains(0.5) {
                thingFragment.thing.height = node.primitive.wall.leftSector.floor.height
            }
        }
    }

    if !right.isEmpty {
        if let rightNode = node.right {
            place(thingFragment: thingFragment.slice(part: right), in: rightNode, atPhase: phase)
        }
        else {
            node.primitive.rightThingFragments.append(thingFragment)
            if thingFragment.range.contains(0.5) {
                if let backSector = node.primitive.wall.rightSector {
                    thingFragment.thing.height = backSector.floor.height
                }
                else {
                    thingFragment.thing.height = node.primitive.wall.leftSector.floor.height
                }
            }
        }
    }
}

func removeThingFragments(in node: BSP<WallFragment>.Node) {
    node.primitive.leftThingFragments.removeAll()
    node.primitive.rightThingFragments.removeAll()
    if let left = node.left { removeThingFragments(in: left) }
    if let right = node.right { removeThingFragments(in: right) }
}

// MARK: - Map

class Map {
    let name: String
    let player: Player
    let sectors: [Sector]
    let walls: [Wall]
    let things: [Thing]
    let bsp: BSP<WallFragment>

    init(
        name: String,
        player: Player,
        sectors: [Sector],
        walls: [Wall],
        things: [Thing]
    ) {
        self.name = name
        self.player = player
        self.sectors = sectors
        self.walls = walls
        self.things = things
        bsp = BSP(segments: walls.map { WallFragment(ofWall: $0) })
    }

    func placeThings(atTime time: Float) {
        if let root = bsp.root {
            removeThingFragments(in: root)
            for thing in things {
                place(
                    thingFragment: ThingFragment(ofThing: thing, atAngle: -player.angle),
                    in: root,
                    atPhase: time
                )
            }
        }
    }
}

// MARK: - World

class World {
    let maps: [Map]
    let textures: [Texture]
    var palettes: [[UInt32]]
    var phase = Float(0)
    var time = Float(0)

    weak var map: Map?

    init(
        maps: [Map],
        textures: [Texture],
        palettes: [[UInt32]]
    ) {
        self.maps = maps
        self.map = maps.first
        self.textures = textures
        self.palettes = palettes
    }

    func fill(x: Int, y1: Int, y2: Int, value: UInt32, in screen: Screen) {
        if y1 > y2 { return }
        let cy1 = max(y1, 0)
        let cy2 = min(y2, screen.height)
        if cy1 > cy2 { return }
        for y in cy1..<cy2 {
            screen.pixels[x + y * screen.width] = value
        }
    }

    func clear(screen: Screen) {
        screen.pixels.initialize(repeating: 0)
    }

    func update(with joypad: Joypad) {
        map?.player.update(with: joypad)
    }
}
