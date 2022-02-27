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

class Sector: Decodable, Identifiable {
    struct Part: Decodable {
        class State {
            var height: Float
            init(height: Float) { self.height = height }
        }

        let state: State
        let heightStates: [Float]
        let texture: Texture?

        enum CodingKeys: String, CodingKey {
            case height
            case altHeight
            case texture
        }

        init(heights: [Float], texture: Texture?) {
            self.heightStates = heights
            self.texture = texture
            self.state = State(height: heights[0])
        }

        init(from decoder: Decoder) throws {
            let builder = try getBuilder(from: decoder)
            let values = try decoder.container(keyedBy: Sector.Part.CodingKeys.self)
            var heights = [try values.decode(Float.self, forKey: .height)]
            if let h = try values.decodeIfPresent(Float.self, forKey: .altHeight) {
                heights.append(h)
            }
            heightStates = heights
            state = State(height: heightStates[0])
            let textureId = try values.decode(Int.self, forKey: .texture)
            texture = builder.textures[textureId]
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

    let id: Int
    let ceiling: Part
    let floor: Part

    enum CodingKeys: String, CodingKey {
        case id
        case top
        case bottom
        case animation
    }

    init(id: Int, ceiling: Part, floor: Part) {
        self.id = id
        self.ceiling = ceiling
        self.floor = floor
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: Sector.CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        ceiling = try values.decode(Part.self, forKey: .top)
        floor = try values.decode(Part.self, forKey: .bottom)
        try getBuilder(from: decoder).sectors[id] = self
    }
}

// MARK: - Wall

class Wall: Decodable {
    struct Part: Decodable {
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

        enum CodingKeys: String, CodingKey {
            case uv
            case altUv
            case texture
        }

        init(from decoder: Decoder) throws {
            let builder = try getBuilder(from: decoder)
            let values = try decoder.container(keyedBy: Wall.Part.CodingKeys.self)
            let uv = try values.decode(Segment.self, forKey: .uv)
            var uSpaceStates_ = [Space(begin: uv.v1.x, end: uv.v2.x)]
            var vSpaceStates_ = [Space(begin: uv.v1.y, end: uv.v2.y)]
            if let uv = try values.decodeIfPresent(Segment.self, forKey: .altUv) {
                uSpaceStates_.append(Space(begin: uv.v1.x, end: uv.v2.x))
                vSpaceStates_.append(Space(begin: uv.v1.y, end: uv.v2.y))
            }
            uSpaceStates = uSpaceStates_
            vSpaceStates = vSpaceStates_
            state = State(uSpace: uSpaceStates[0], vSpace: vSpaceStates[0])
            let textureId = try values.decode(Int.self, forKey: .texture)
            texture = builder.textures[textureId]
        }

        var uSpace: Space { state.uSpace }
        var vSpace: Space { state.vSpace }
    }

    let base: Segment
    let top: Part
    let middle: Part
    let bottom: Part
    let leftSector: Sector
    let rightSector: Sector?

    enum CodingKeys: String, CodingKey {
        case base
        case top
        case middle
        case bottom
        case frontSector
        case backSector
    }

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

    required init(from decoder: Decoder) throws {
        let builder = try getBuilder(from: decoder)
        let values = try decoder.container(keyedBy: Wall.CodingKeys.self)
        base = try values.decode(Segment.self, forKey: .base)
        top = try values.decode(Part.self, forKey: .top)
        middle = try values.decode(Part.self, forKey: .middle)
        bottom = try values.decode(Part.self, forKey: .bottom)
        let frontSectorId = try values.decode(Int.self, forKey: .frontSector)
        let backSectorId = try values.decode(Int?.self, forKey: .backSector)
        if let lf = builder.sectors[frontSectorId] {
            leftSector = lf
        }
        else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Left floor ID \(frontSectorId) does not exist."
                )
            )
        }
        if backSectorId != nil {
            if let rf = builder.sectors[backSectorId!] {
                rightSector = rf
            }
            else {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Back floor ID \(backSectorId!) does not exist."
                    )
                )
            }
        }
        else {
            rightSector = nil
        }
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

class Thing: Decodable {
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

    enum CodingKeys: String, CodingKey {
        case position
        case angle
        case textures
    }

    required init(from decoder: Decoder) throws {
        let builder = try getBuilder(from: decoder)
        let values = try decoder.container(keyedBy: Thing.CodingKeys.self)
        position = try values.decode(Vector.self, forKey: .position)
        angle = try values.decode(Float.self, forKey: .angle)
        let textureIds = try values.decode([Int].self, forKey: .textures)
        textures = textureIds.map { builder.textures[$0] }
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

class Texture: Decodable, Identifiable {
    let id: Int
    let name: String
    var pixels: [[UInt8]]
    var mask: [[UInt8]]?
    let width: Int
    let height: Int
    let offset: Vector
    let isSky: Bool

    init(
        id: Int,
        name: String,
        pixels: [[UInt8]],
        mask: [[UInt8]]?,
        width: Int,
        height: Int,
        offset: Vector,
        isSky: Bool
    ) {
        self.id = id
        self.name = name
        self.pixels = pixels
        self.mask = mask
        self.width = width
        self.height = height
        self.offset = offset
        self.isSky = isSky
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case offset
        case isSky
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: Texture.CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        offset = try values.decode(Vector.self, forKey: .offset)
        isSky = try values.decode(Bool.self, forKey: .isSky)
        if let path = Bundle.main.path(forResource: "Assets/" + name, ofType: "png"),
            let src = CGDataProvider(filename: path),
            let img = CGImage(
                pngDataProviderSource: src,
                decode: nil,
                shouldInterpolate: false,
                intent: .defaultIntent
            ),
            let data = img.dataProvider?.data
        {
            let buffer = UnsafeBufferPointer(
                start: CFDataGetBytePtr(data),
                count: CFDataGetLength(data)
            )
            width = img.width
            height = img.height
            pixels = []
            for c in 0..<width {
                let column = stride(from: c, to: c + width * height, by: width).map {
                    UInt8(buffer[$0])
                }
                pixels.append(column)
            }
        }
        else {
            width = 64
            height = 64
            pixels = []
            for c in 0..<width {
                let column = (0..<height).map { r in
                    ((r & 32) ^ (c & 32)) != 0 ? UInt8(0) : UInt8(1)
                }
                pixels.append(column)
            }
        }
        if let path = Bundle.main.path(forResource: "Assets/" + name + "_mask", ofType: "png"),
            let src = CGDataProvider(filename: path),
            let img = CGImage(
                pngDataProviderSource: src,
                decode: nil,
                shouldInterpolate: false,
                intent: .defaultIntent
            ),
            let data = img.dataProvider?.data
        {
            let buffer = UnsafeBufferPointer(
                start: CFDataGetBytePtr(data),
                count: CFDataGetLength(data)
            )
            precondition(width == img.width)
            precondition(height == img.height)
            mask = []
            for c in 0..<width {
                let column = stride(from: c, to: c + width * height, by: width).map {
                    UInt8(buffer[$0])
                }
                mask!.append(column)
            }
        }
        else {
            mask = nil
        }

        try getBuilder(from: decoder).textures[id] = self
    }
}

// MARK: - Player

class Player: Decodable {
    var position: Vector = .init(x: 0, y: -2)
    var angle: Float = 0
    var height: Float = 0

    let maxLinearSpeed: Float = 10
    let maxStrafeSpeed: Float = 10
    let maxAngularSpeed: Float = 0.06
    let hegightFromGround: Float = 45

    enum CodingKeys: String, CodingKey {
        case position
        case angle
    }

    init(
        position: Vector = .init(x: 0, y: -2),
        angle: Float = 0
    ) {
        self.position = position
        self.angle = angle
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: Player.CodingKeys.self)
        position = try values.decode(Vector.self, forKey: .position)
        angle = try values.decode(Float.self, forKey: .angle)
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

class Map: Decodable {
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

    enum CodingKeys: String, CodingKey {
        case name
        case player
        case sectors
        case walls
        case things
    }

    required init(from decoder: Decoder) throws {
        try getBuilder(from: decoder).sectors.removeAll()
        let values = try decoder.container(keyedBy: Map.CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        sectors = try values.decode([Sector].self, forKey: .sectors)
        walls = try values.decode([Wall].self, forKey: .walls)
        player = try values.decode(Player.self, forKey: .player)
        things = try values.decode([Thing].self, forKey: .things)
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

class World: Decodable {
    let maps: [Map]
    let textures: [Texture]
    var palettes: [[UInt32]]
    var phase = Float(0)
    var time = Float(0)

    weak var map: Map?

    enum CodingKeys: String, CodingKey {
        case maps
        case textures
        case palettes
    }

    init(
        maps: [Map],
        textures: [Texture],
        palettes: [[UInt32]]
    ) {
        self.maps = maps
        self.textures = textures
        self.palettes = palettes
        self.map = maps.first
    }

    class Builder {
        var sectors: [Int: Sector] = [:]
        var textures: [Int: Texture] = [:]
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: World.CodingKeys.self)
        textures = try values.decode([Texture].self, forKey: .textures)
        maps = try values.decode([Map].self, forKey: .maps)
        palettes = try values.decode([[UInt32]].self, forKey: .palettes)
        map = maps[0]
    }

    static func load() throws -> World {
        guard let path = Bundle.main.path(forResource: "Assets/world", ofType: "json") else {
            throw RuntimeError("Could not find the asset world.json in the application bundle.")
        }
        let json = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let decoder = JSONDecoder()
        decoder.userInfo[.worldBuilder] = Builder()
        return try decoder.decode(World.self, from: json)
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

extension CodingUserInfoKey {
    fileprivate static let worldBuilder = CodingUserInfoKey(rawValue: "worldBuilder")!
}

private func getBuilder(from decoder: Decoder) throws -> World.Builder {
    guard let builder = decoder.userInfo[.worldBuilder] as? World.Builder else {
        throw DecodingError.dataCorrupted(
            .init(
                codingPath: decoder.codingPath,
                debugDescription: "Decoder incorrectly initialized."
            )
        )
    }
    return builder
}
