// Screen.swift

#if os(macOS)
    import Cocoa
#else
    import UIKit
#endif

import MetalKit
import SwiftUI

private extension Float {
    init(_ x: Bool) {
        self = x ? 1.0 : 0.0
    }
}

private extension Vector {
    init(_ v: CGPoint) {
        x = Float(v.x)
        y = Float(v.y)
    }
}

// MARK: - Joypad

class Joypad {
    var walk = Float(0.0)
    var turn = Float(0.0)
    var strafe = Float(0.0)

    struct Keys {
        var forward = false
        var backward = false
        var left = false
        var right = false
        var strafe = false
        var strafeLeft = false
        var strafeRight = false
        var run = false
    }

    private var keys = Keys()

    private func update() {
        let l = keys.left && !keys.strafe
        let r = keys.right && !keys.strafe
        let sl = keys.strafeLeft || (keys.left && keys.strafe)
        let sr = keys.strafeRight || (keys.right && keys.strafe)
        let speed = keys.run ? Float(1.0) : Float(0.5)
        if !keys.forward || !keys.backward { walk = speed * (Float(keys.forward) - Float(keys.backward)) }
        if !r || !l { turn = speed * (Float(r) - Float(l)) }
        if !sr || !sl { strafe = speed * (Float(sr) - Float(sl)) }
    }

    func interpet(key: String, down: Bool) -> Bool {
        switch key {
        case "w": keys.forward = down
        case "s": keys.backward = down
        case "a": keys.left = down
        case "d": keys.right = down
        case ",", "<": keys.strafeLeft = down
        case ".", ">": keys.strafeRight = down
        default: return false
        }
        update()
        return true
    }

    func interpret(vector: Vector) {
        let norm = max(Float(200.0), vector.magnitude())
        let v = vector * (Float(1.0) / norm)
        walk = -v.y
        turn = v.x
    }

    #if os(macOS)
        func interpret(modifierFlags: NSEvent.ModifierFlags) -> Bool {
            keys.strafe = modifierFlags.contains(.option)
            keys.run = modifierFlags.contains(.shift)
            update()
            return true
        }
    #endif
}

// MARK: - Screen

class Screen {
    private(set) var width: Int
    private(set) var height: Int

    let bytesPerPixel = 4
    let bitsPerComponent = 8
    var bytesPerRow: Int { bytesPerPixel * width }
    var byteCount: Int { bytesPerRow * height }
    private var buffer: UnsafeMutablePointer<UInt32>
    var pixels: UnsafeMutableBufferPointer<UInt32> { .init(start: buffer, count: byteCount / 4) }
    let fieldOfView = Float.pi / 2

    init(width w: Int, height h: Int) {
        width = w
        height = h
        buffer = UnsafeMutablePointer<UInt32>.allocate(capacity: w * h)
    }

    func fill() {
        for y in 0 ..< height {
            for x in 0 ..< width {
                pixels[width * y + x] = ((y + x) % 8 < 3) ? 0xFFFF_FFFF : 0
            }
        }
    }
}

// MARK: - UI

class ScreenMTKView: MTKView {
    var owner: ScreenView?

    #if os(macOS)
        override var acceptsFirstResponder: Bool { true }
        private var displayLink: CVDisplayLink?

        override func flagsChanged(with event: NSEvent) {
            _ = owner?.worldManager.joypad.interpret(modifierFlags: event.modifierFlags)
        }

        override func keyDown(with event: NSEvent) {
            let characters = event.charactersIgnoringModifiers!.lowercased()
            _ = owner?.worldManager.joypad.interpet(key: characters, down: true)
        }

        override func keyUp(with event: NSEvent) {
            let characters = event.charactersIgnoringModifiers!.lowercased()
            _ = owner?.worldManager.joypad.interpet(key: characters, down: false)
        }

        func play() {
            if displayLink == nil {
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(windowWillClose),
                                                       name: NSWindow.willCloseNotification,
                                                       object: window)
                CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
                if let displayLink = displayLink {
                    CVDisplayLinkSetOutputCallback(displayLink, ScreenMTKView.callback, Unmanaged.passUnretained(self).toOpaque())
                }
            }
            if let displayLink = displayLink { CVDisplayLinkStart(displayLink) }
        }

        func pause() {
            if let displayLink = displayLink { CVDisplayLinkStop(displayLink) }
        }

        static let callback: CVDisplayLinkOutputCallback = { (_, _, _, _, _, context) -> CVReturn in
            let view = Unmanaged<ScreenMTKView>.fromOpaque(context!).takeUnretainedValue()
            view.draw()
            return kCVReturnSuccess
        }

        @objc func windowWillClose(_ notification: Notification) {
            if notification.object as AnyObject? === window { pause() }
        }

        deinit {
            pause()
            displayLink = nil
        }
    #endif

    #if os(iOS)
        private var displayLink: CADisplayLink?
        var touchBeganPoint = CGPoint()

        override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
            if let touch = touches.first {
                touchBeganPoint = touch.location(in: self)
            }
        }

        override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
            if let touch = touches.first {
                let currentPoint = touch.location(in: self)
                owner?.worldManager.joypad.interpret(vector: Vector(currentPoint) - Vector(touchBeganPoint))
            }
        }

        override func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent?) {
            if let touch = touches.first {
                let currentPoint = touch.location(in: self)
                touchBeganPoint = currentPoint
                owner?.worldManager.joypad.interpret(vector: Vector(currentPoint) - Vector(touchBeganPoint))
            }
        }

        func play() {
            if displayLink == nil {
                displayLink = UIScreen.main.displayLink(withTarget: self, selector: #selector(callback))
                displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
            }
            displayLink?.isPaused = false
        }

        func pause() {
            displayLink?.isPaused = true
        }

        @objc func callback() {
            draw()
        }

        @objc func didEnterBackground(_: Notification) {
            pause()
        }

        @objc func willEnterForeground(_: Notification) {
            play()
        }

        deinit {
            displayLink?.invalidate()
            displayLink = nil
        }
    #endif
}

private class Buffer<T> {
    var device: MTLDevice?
    var count: Int = 0
    var byteCount: Int { count * MemoryLayout<T>.stride }
    var buffer: MTLBuffer? = nil
    
    init(device: MTLDevice?) {
        self.device = device
    }

    func allocate(count: Int = 1) {
        self.count = count

        #if os(macOS)
        buffer = device?.makeBuffer(
            length: byteCount,
            options: [.storageModeManaged, .cpuCacheModeWriteCombined]
        )
        #else
        buffer = device?.makeBuffer(
            length: byteCount,
            options: [.cpuCacheModeWriteCombined]
        )
        #endif
    }
        
    func copy(fromArray data: [T]) {
        if (data.count != count) { allocate(count: data.count) }

        data.withUnsafeBytes { ptr in
            buffer?.contents().copyMemory(from: ptr.baseAddress!, byteCount: byteCount)
        }
        
        #if os(macOS)
            buffer?.didModifyRange(0 ..< byteCount)
        #endif
    }
    
    func copy(_ data: T) {
        copy(fromArray: [data])
    }
}

class MapMTK {
    private let screenMtk: ScreenMTKViewCoordinator
    private var mapVertexBuffer: Buffer<MapVertex>
    private var playerVertexBuffer: Buffer<MapVertex>
    private var transformationBuffer: Buffer<matrix_float4x4>
    private var renderPipelineState: MTLRenderPipelineState?
    private var drawableSize = CGSize()
    private var currentMap: Map? = nil
    private var numSegments = 0
    
    init(_ screenMtk: ScreenMTKViewCoordinator) {
        self.screenMtk = screenMtk
        mapVertexBuffer = .init(device: self.screenMtk.device)
        playerVertexBuffer = .init(device: self.screenMtk.device)
        transformationBuffer = .init(device: self.screenMtk.device)
        initMetal()
    }

    private struct MapVertex {
        var pos: vector_float4
        var color: vector_float4
    }
    
    private let transformationDataSize = MemoryLayout<float4x4>.stride

    
    func makeRenderPassDescriptor(drawable: CAMetalDrawable) -> MTLRenderPassDescriptor {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .load
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        return renderPassDescriptor
    }
        
    func draw(in view: MTKView, with cbu: MTLCommandBuffer) {
        guard let map = screenMtk.owner.worldManager.world?.map else { return }
        if map !== currentMap { load(map: map) }
        
        let sx = 0.3 / Float(3000)
        let sy = sx * Float(screenMtk.drawableSize.width) / Float(screenMtk.drawableSize.height)
        let tx = map.player.position.x
        let ty = map.player.position.y
        let a = map.player.angle
        let sa = sin(a)
        let ca = cos(a)
        let center = matrix_float4x4(rows:[
            SIMD4<Float>(1, 0, 0, -tx),
            SIMD4<Float>(0, 1, 0, -ty),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(0, 0, 0, 1)
        ])
        let rotate = matrix_float4x4(rows:[
            SIMD4<Float>(sa, -ca, 0, 0),
            SIMD4<Float>(ca,  sa, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(0, 0, 0, 1)
        ])
        let scale = matrix_float4x4(rows:[
            SIMD4<Float>(sx, 0, 0, 0.75),
            SIMD4<Float>(0, sy, 0, 0.5),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(0, 0, 0, 1)
        ])
        transformationBuffer.copy(scale * rotate * center)
        
        let ps = Float(150)
        let triangle = [
            MapVertex(pos: SIMD4<Float>(tx+ps*(ca), ty+ps*(sa), 0.5, 1), color: SIMD4<Float>(0,0,1,1)),
            MapVertex(pos: SIMD4<Float>(tx+ps*(-ca/4-sa/2), ty+ps*(-sa/4+ca/2), 0.5, 1), color: SIMD4<Float>(0,0,1,1)),
            MapVertex(pos: SIMD4<Float>(tx+ps*(-ca/4+sa/2), ty+ps*(-sa/4-ca/2), 0.5, 1), color: SIMD4<Float>(0,0,1,1)),
        ]
        playerVertexBuffer.copy(fromArray: triangle)

        guard
            let drw = view.currentDrawable,
            let rce = cbu.makeRenderCommandEncoder(descriptor: makeRenderPassDescriptor(drawable: drw)),
            let rps = renderPipelineState
        else { return }

        rce.setRenderPipelineState(rps)
        rce.setVertexBuffer(mapVertexBuffer.buffer, offset: 0, index: 0)
        rce.setVertexBuffer(transformationBuffer.buffer, offset: 0, index: 1)
        rce.drawPrimitives(type: .line, vertexStart: 0, vertexCount: 2, instanceCount: mapVertexBuffer.count/2)
        rce.setVertexBuffer(playerVertexBuffer.buffer, offset: 0, index: 0)
        rce.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        rce.endEncoding()
    }

    private func initMetal() {
        let shaders = """
        #include <metal_stdlib>
        using namespace metal;
        struct MapVertex {
            float4 pos [[position]];
            float4 color;
        };
        vertex MapVertex map_vertex_func(uint id [[vertex_id]],
                                         uint instance_id [[instance_id]],
                                         constant float4x4 &transformation [[buffer(1)]],
                                         constant MapVertex *vertices [[buffer(0)]]) {
            return MapVertex{ transformation * vertices[id + instance_id*2].pos, vertices[id + instance_id*2].color };
        }
        fragment float4 map_fragment_func(MapVertex point [[stage_in]]) {
            return point.color;
        }
        """

        let library = try! screenMtk.device?.makeLibrary(source: shaders, options: nil)
        let rpd = MTLRenderPipelineDescriptor()
        rpd.vertexFunction = library?.makeFunction(name: "map_vertex_func")
        rpd.fragmentFunction = library?.makeFunction(name: "map_fragment_func")
        rpd.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineState = try? screenMtk.device?.makeRenderPipelineState(descriptor: rpd)
    }

    func load(map: Map) {
        currentMap = map
        let color = SIMD4<Float>(1,1,1,1)
        let vertices = map.walls.flatMap { [
            MapVertex(pos: [$0.base.v1.x, $0.base.v1.y, 0.5, 1], color: color),
            MapVertex(pos: [$0.base.v2.x, $0.base.v2.y, 0.5, 1], color: color)
        ] }
        mapVertexBuffer.copy(fromArray: vertices)
    }
}

class ScreenMTKViewCoordinator: NSObject, MTKViewDelegate {
    let owner: ScreenView

    fileprivate var device: MTLDevice?
    fileprivate var commandQueue: MTLCommandQueue?
    private var texture: MTLTexture?
    private var vertexBuffer: Buffer<Vertex>
    private var renderPipelineState: MTLRenderPipelineState?
    private var samplerState: MTLSamplerState?
    private var textureSemaphore = DispatchSemaphore(value: 1)
    fileprivate var drawableSize = CGSize()
    
    private var map: MapMTK? = nil

    init(_ owner: ScreenView) {
        device = MTLCreateSystemDefaultDevice()
        self.vertexBuffer = .init(device: device)
        self.owner = owner
        super.init()
        initMetal()
        self.map = MapMTK(self)
    }

    func setup(screenMTKView: ScreenMTKView) {
        screenMTKView.delegate = self
        screenMTKView.owner = owner
        screenMTKView.device = device
        screenMTKView.isPaused = true
        screenMTKView.enableSetNeedsDisplay = false
        screenMTKView.play()
    }

    func mtkView(_: MTKView, drawableSizeWillChange size: CGSize) {
        drawableSize = size
        updateScreenShape()
    }

    func draw(in view: MTKView) {
        guard let world = owner.worldManager.world else { return }
        world.update(with: owner.worldManager.joypad)
        world.draw(in: owner.worldManager.screen)

        let screen = owner.worldManager.screen

        guard
            let tex = texture,
            let drw = view.currentDrawable,
            let rpd = view.currentRenderPassDescriptor,
            let cbu = commandQueue?.makeCommandBuffer(),
            let rce = cbu.makeRenderCommandEncoder(descriptor: rpd),
            let rps = renderPipelineState
        else { return }

        tex.replace(region: MTLRegionMake2D(0, 0, screen.width, screen.height),
                    mipmapLevel: 0,
                    slice: 0,
                    withBytes: screen.pixels.baseAddress!,
                    bytesPerRow: screen.bytesPerRow,
                    bytesPerImage: 0)

        rce.setRenderPipelineState(rps)
        rce.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: 0)
        rce.setFragmentTexture(texture, index: 0)
        rce.setFragmentSamplerState(samplerState, index: 0)
        rce.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
        rce.endEncoding()

        map?.draw(in: view, with: cbu)

        cbu.present(drw)
        cbu.addCompletedHandler { [weak self] _ in
            self?.textureSemaphore.signal()
        }
        cbu.commit()
    }

    private struct Vertex {
        var pos: vector_float4
        var uv: vector_float2
    }

    private func initMetal() {
        commandQueue = device?.makeCommandQueue()

        let shaders = """
        #include <metal_stdlib>
        using namespace metal;
        struct Vertex {
            float4 pos [[position]];
            float2 uv;
        };
        vertex Vertex vertex_func(uint id [[vertex_id]],
                                  constant Vertex *vertices [[buffer(0)]]) {
            return vertices[id];
        }
        fragment half4 fragment_func(Vertex point [[stage_in]],
                                     texture2d<float, access::sample> texture [[texture(0)]],
                                     sampler sampler [[sampler(0)]]) {
            float4 color = texture.sample(sampler, point.uv);
            return half4(color);
        }
        """

        let library = try! device?.makeLibrary(source: shaders, options: nil)
        let rpd = MTLRenderPipelineDescriptor()
        rpd.vertexFunction = library?.makeFunction(name: "vertex_func")
        rpd.fragmentFunction = library?.makeFunction(name: "fragment_func")
        rpd.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineState = try? device?.makeRenderPipelineState(descriptor: rpd)

        // Texture containing the bitmap.
        let screen = owner.worldManager.screen
        let tds = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: MTLPixelFormat.bgra8Unorm,
            width: screen.width,
            height: screen.height,
            mipmapped: false
        )
        texture = device?.makeTexture(descriptor: tds)

        // Texture sampler.
        let sde = MTLSamplerDescriptor()
        sde.minFilter = .linear
        sde.magFilter = .nearest
        samplerState = device?.makeSamplerState(descriptor: sde)
    }

    private func updateScreenShape() {
        let screen = owner.worldManager.screen
        let frameWidth = Double(drawableSize.width)
        let frameHeight = Double(drawableSize.height)
        let screenWidth = Double(screen.width)
        let screenHeight = Double(screen.height)
        let scale = min(frameWidth / screenWidth, frameHeight / screenHeight)
        let w = Float((scale * screenWidth) / frameWidth)
        let h = Float((scale * screenHeight) / frameHeight)
        let vertices = [Vertex(pos: [-w, +h, 0.0, 1.0], uv: [0, 0]),
                          Vertex(pos: [+w, +h, 0.0, 1.0], uv: [1, 0]),
                          Vertex(pos: [-w, -h, 0.0, 1.0], uv: [0, 1]),
                          Vertex(pos: [+w, -h, 0.0, 1.0], uv: [1, 1])]
        vertexBuffer.copy(fromArray: vertices)
    }
}

#if os(macOS)
    struct ScreenView: NSViewRepresentable {
        @EnvironmentObject var worldManager: WorldManager
        @Environment(\.scenePhase) private var scenePhase

        func makeCoordinator() -> ScreenMTKViewCoordinator {
            return ScreenMTKViewCoordinator(self)
        }

        func makeNSView(context: Context) -> NSView {
            let view = ScreenMTKView()
            context.coordinator.setup(screenMTKView: view)
            DispatchQueue.main.async {
                view.window?.makeFirstResponder(view)
            }
            return view
        }

        func updateNSView(_ view: NSView, context _: Context) {
            guard let screenMtkView = view as? ScreenMTKView else { return }
            switch scenePhase {
            case .active:
                screenMtkView.play()
            case .inactive, .background:
                fallthrough
            @unknown default:
                screenMtkView.pause()
            }
        }
    }
#else
    struct ScreenView: UIViewRepresentable {
        @EnvironmentObject var worldManager: WorldManager
        @Environment(\.scenePhase) private var scenePhase

        func makeCoordinator() -> ScreenMTKViewCoordinator {
            return ScreenMTKViewCoordinator(self)
        }

        func makeUIView(context: Context) -> UIView {
            let view = ScreenMTKView()
            context.coordinator.setup(screenMTKView: view)
            return view
        }

        func updateUIView(_ view: UIView, context _: Context) {
            guard let screenMtkView = view as? ScreenMTKView else { return }
            switch scenePhase {
            case .active:
                screenMtkView.play()
            case .inactive, .background:
                fallthrough
            @unknown default:
                screenMtkView.pause()
            }
        }
    }
#endif
