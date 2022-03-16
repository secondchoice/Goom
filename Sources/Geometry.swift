// Geometry.swift

import Foundation

/// Modulus operator
///
/// `mod(a,n)` computes `a` modulus `n`.
/// `a` and `n` are both integers and `n` must be positive.
/// The modulus is the remainder of the floored division `a - n * floor(a/n)`.
/// The result is thus in the range 0 to `n-1`.
///
/// If `a` is non-negative, `mod(a,n)` is the same as `a % n`.
///
/// See also https://en.wikipedia.org/wiki/Modulo_operation
func mod(_ a: Int, _ n: Int) -> Int {
    assert(n > 0, "Modulus must be positive.")
    return ((a % n) + n) % n
}

/// Modulus operator for powers of 2
///
/// This version is optimised for the case in which `n` is a power of 2.
func mod2(_ a: Int, _ n: Int) -> Int {
    assert(n > 0 && n.nonzeroBitCount == 1, "Modulus must be a power of 2.")
    return Int(bitPattern: UInt(bitPattern: a) % UInt(bitPattern: n))
}

extension Range where Bound == Float {
    /// Check if the range is a subset of the unit interval `[0,1]`.
    var isPartOfUnit: Bool {
        return lowerBound >= 0 && upperBound <= 1 && lowerBound <= upperBound
    }
}

/// The possible sides of a line
enum Side {
    case left
    case right
}

prefix func ~ (side: Side) -> Side {
    return side == .left ? .right : .left
}

// MARK: - Vector

/// A `Vectory` defines the addition, subtraction, right scalar multiplication, and inner product operations.
protocol VectorOperations {
    static func + (lhs: Self, rhs: Self) -> Self
    static func - (lhs: Self, rhs: Self) -> Self
    static func * (lhs: Self, rhs: Float) -> Self
    static func innerProduct(_ lhs: Self, _ rhs: Self) -> Float
}

extension VectorOperations {
    /// The left scalar product is the same as the right scalar product.
    static func * (lhs: Float, rhs: Self) -> Self {
        return rhs * lhs
    }

    /// Returns the magnitude (norm or length) of the vector.
    func magnitude() -> Float {
        return sqrt(Self.innerProduct(self, self))
    }
}

extension Float: VectorOperations {
    static func innerProduct(_ lhs: Float, _ rhs: Float) -> Float {
        return lhs * rhs
    }
}

func dot<T>(_ lhs: T, _ rhs: T) -> Float where T: VectorOperations {
    return T.innerProduct(lhs, rhs)
}

/// 2D vector
///
/// A 2D vector has two scalar components, conventionally callled `x` and `y`.
struct Vector {
    var x: Float
    var y: Float
}

extension Vector: Decodable {
    init(from decoder: Decoder) throws {
        var values = try decoder.unkeyedContainer()
        x = try values.decode(Float.self)
        y = try values.decode(Float.self)
    }
}

extension Vector: CustomStringConvertible {
    var description: String {
        return "[\(x), \(y)]"
    }
}

extension Vector: ExpressibleByArrayLiteral {
    init(arrayLiteral: Float...) {
        assert(arrayLiteral.count == 2, "Initializing a vector requires two numbers.")
        x = arrayLiteral[0]
        y = arrayLiteral[1]
    }
}

extension Vector: VectorOperations {
    static func + (lhs: Vector, rhs: Vector) -> Vector {
        return [lhs.x + rhs.x, lhs.y + rhs.y]
    }

    static func - (lhs: Vector, rhs: Vector) -> Vector {
        return [lhs.x - rhs.x, lhs.y - rhs.y]
    }

    static func * (lhs: Vector, rhs: Float) -> Vector {
        return [lhs.x * rhs, lhs.y * rhs]
    }

    static func innerProduct(_ v1: Vector, _ v2: Vector) -> Float {
        return v1.x * v2.x + v1.y * v2.y
    }
}

extension Vector {
    /// Rotates the 2D vector counterclockwise by 90 degrees.
    func perp() -> Vector {
        return .init(x: -y, y: x)
    }
}

// MARK: - Space

/// A linear space.
///
/// A `Spacey` is the set of objects obtained by linearly interpoalting  the`begin` and  `end` objects.
protocol Spacey {
    associatedtype Element: VectorOperations
    var begin: Element { get }
    var end: Element { get }
    init(begin: Element, end: Element)
}

extension Spacey {
    /// The difference between the `end` and `begin` objects.
    var direction: Element { end - begin }

    /// The lenght of the space.
    var length: Float { direction.magnitude() }

    /// Returns the element at the specified index.
    ///
    /// `index` must be a number in the range [0,1]. The function linearly interpoaltes the
    /// `begin` and `end` coordiantes of the space.
    subscript(index: Float) -> Element { (end - begin) * index + begin }

    /// Slice the space
    ///
    /// Returns the subspace corresponding to the part of unit `part`.
    func slice(part: Range<Float>) -> Self {
        assert(part.isPartOfUnit, "The range must be a part of unit.")
        let b = self[part.lowerBound]
        let e = self[part.upperBound]
        return Self(begin: b, end: e)
    }
}

extension Range: Spacey where Range.Bound == Float {
    var begin: Float { lowerBound }
    var end: Float { upperBound }
    init(begin: Float, end: Float) {
        assert(begin <= end)
        self.init(uncheckedBounds: (lower: begin, upper: end))
    }
}

/// A linear coordiante space.
typealias Space = Vector

extension Space: Spacey {
    var begin: Float { x }
    var end: Float { y }
    init(begin: Float, end: Float) { self.init(x: begin, y: end) }
}

// MARK: - Segment

/// 2D segment
///
/// A segment is given by a pair of vertices `v1` and `v2`.
/// The orientation matters: `v1` is the beginning of the segment and `v2` the end.
struct Segment {
    let v1: Vector
    let v2: Vector
}

extension Segment: Spacey {
    var begin: Vector { v1 }
    var end: Vector { v2 }
    init(begin: Vector, end: Vector) { self.init(v1: begin, v2: end) }
}

extension Segment {
    func side(ofPoint point: Vector) -> Side {
        return Line(containing: self).side(ofPoint: point)
    }
}

extension Segment: Decodable {
    init(from decoder: Decoder) throws {
        var values = try decoder.unkeyedContainer()
        v1 = try values.decode(Vector.self)
        v2 = try values.decode(Vector.self)
    }
}

extension Segment: ExpressibleByArrayLiteral {
    init(arrayLiteral: [Float]...) {
        assert(arrayLiteral.count == 2, "Initializing a segment requires two vectors.")
        self.init(
            v1: .init(x: arrayLiteral[0][0], y: arrayLiteral[0][1]),
            v2: .init(x: arrayLiteral[1][0], y: arrayLiteral[1][1])
        )
    }
}

extension Segment: CustomStringConvertible {
    var description: String {
        return "<\(v1),\(v2)>"
    }
}

// MARK: - Line

/// A 2D line.
///
/// A line is defined by the implicit equation `f(x) = dot(normal, x) + offset = 0`.
/// Points `x` such that `f(x)` is positive are to the left of the line.
struct Line {
    /// The normal points to the left side of the line.
    let normal: Vector
    let offset: Float

    init(normal: Vector, offset: Float) {
        self.normal = normal
        self.offset = offset
    }

    init(containing segment: Segment) {
        normal = segment.direction.perp()
        offset = -dot(normal, segment.v1)
    }
}

extension Line {
    /// Evaluates the line implicit functinn `f(x) = dot(normal, point) + offset`.
    func evaluate(at point: Vector) -> Float {
        return dot(normal, point) + offset
    }

    /// Return the side of  the 2D `point` with respect to the line.
    func side(ofPoint point: Vector) -> Side {
        return evaluate(at: point) >= 0 ? .left : .right
    }
}

extension Line {
    /// Cut the `segment` by the line.
    ///
    /// The function returns two part of units `left` and  `right` corresponding respectively to the
    /// part of the segment to the left and the right of the line (they can potentiallly be empty).
    func cut(segment: Segment) -> (left: Range<Float>, right: Range<Float>) {
        let f1 = evaluate(at: segment.v1)
        let f2 = evaluate(at: segment.v2)
        if f1 >= 0 {
            if f2 >= 0 {
                return (left: 0..<1, right: 1..<1)
            }
            else {
                let lambda = f1 / (f1 - f2)
                return (left: 0..<lambda, right: lambda..<1)
            }
        }
        else {
            if f2 <= 0 {
                return (left: 0..<0, right: 0..<1)
            }
            else {
                let lambda = f1 / (f1 - f2)
                return (left: lambda..<1, right: 0..<lambda)
            }
        }
    }
}

// MARK: - Random

private struct SeededRandomNumberGenerator: RandomNumberGenerator {
    init(seed: Int) {
        srand48(seed)
    }

    func next() -> UInt64 {
        return UInt64(drand48() * Double(UInt64.max))
    }
}

private var seededGenerator = SeededRandomNumberGenerator(seed: 0)

// MARK: - Binary space partitioning tree

/// Building a BSP tree requires primitives whose 2D geometry can be represented by a 2D segment and that can be sliced.
protocol Segmentable {
    var asSegment: Segment { get }
    func slice(part: Range<Float>) -> Self
}

extension Segment: Segmentable {
    var asSegment: Segment { self }
}

class BSP<T: Segmentable> {
    let root: Node?

    init(segments: [T]) {
        root = Node.build(primitives: segments)
    }

    func print() -> String {
        root?.print() ?? "<Empty>"
    }

    enum VisitState {
        case more
        case end
        case cull
    }

    class Node {
        let primitive: T
        let left: BSP.Node?
        let right: BSP.Node?

        func print() -> String {
            var str: String = "[\(primitive)"
            if let left = left { str += ",{\(left.print())}" }
            if let right = right { str += ",{\(right.print())}" }
            str += "]"
            return str
        }

        init(primitive: T, left: Node?, right: Node?) {
            self.primitive = primitive
            self.left = left
            self.right = right
        }

        static func build(primitives: [T]) -> Node? {
            if primitives.count == 0 { return nil }
            let pivotIndex = Int.random(in: 0..<primitives.count, using: &seededGenerator)
            let pivot = primitives[pivotIndex]
            var leftSubtree: [T] = []
            var rightSubtree: [T] = []
            for s in 0..<primitives.count {
                if s == pivotIndex { continue }
                let primitive = primitives[s]
                let (left, right) = Line(containing: pivot.asSegment).cut(
                    segment: primitive.asSegment
                )
                if !left.isEmpty { leftSubtree.append(primitive.slice(part: left)) }
                if !right.isEmpty { rightSubtree.append(primitive.slice(part: right)) }
            }
            return Node(
                primitive: pivot,
                left: build(primitives: leftSubtree),
                right: build(primitives: rightSubtree)
            )
        }

        /// Visit the BSP tree.
        ///
        /// The function descends the BSP tree towards `center` executing the specified `action` at each node.
        /// Specifically, starting from the root of the tree:
        ///
        /// 1. It determines if `center`is to the left or the right of the current node.
        /// 2. If `nearestFirst` is true, it visits the subtree on the same side of `center`; otherwise, it visits the other subtree.
        /// 3. It exectues the specified `action` function on the node.
        /// 4. It visits the remaining subtree.
        ///
        /// The result of `action`  also affects the visit:
        /// * If `action` returns `.more` the visit continues as normal.
        /// * If `action` returns `.cull` the visit continues, but the remaining subtree at this node is skipped.
        /// * If `action` returns `.end` the visit terminates immediately.
        @discardableResult func visit(
            from center: Vector,
            nearestFirst: Bool,
            action: (T) -> VisitState
        ) -> VisitState {
            let centerIsOntheLeft = (primitive.asSegment.side(ofPoint: center) == .left)
            let leftFirst = (nearestFirst == centerIsOntheLeft)
            if let state = (leftFirst ? left : right)?.visit(
                from: center,
                nearestFirst: nearestFirst,
                action: action
            ) {
                if state == .end { return .end }
            }
            switch action(primitive) {
            case .end: return .end
            case .cull: return .more
            case .more: break
            }
            return (leftFirst ? right : left)?.visit(
                from: center,
                nearestFirst: nearestFirst,
                action: action
            ) ?? .more
        }
    }
}
