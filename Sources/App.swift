import SwiftUI
import UniformTypeIdentifiers

let screenWidth = 320
let screenHeight = 256

class WorldManager: ObservableObject {

    init() {
        screen.fill()
        guard let path = Bundle.main.path(forResource: "Assets/doom1", ofType: "wad") else {
            lastErrorDescription = "Could not find the asset doom1.wad in the application bundle."
            return
        }
        load(url: URL(fileURLWithPath: path))
    }

    let screen: Screen = Screen(width: screenWidth, height: screenHeight)
    let joypad = Joypad()
    private(set) var lastErrorDescription: String? = nil

    // WAD/World management.
    @Published private(set) var world: World? = nil
    @Published private(set) var worldIsLoading: Bool = false
    @Published private(set) var worldVersion: Int = 0

    /// Load a new WAD file. The operation is asynchronous and loading occurrs in the background.
    func load(url: URL) {
        worldIsLoading = true
        var newWorld: World? = nil
        var errorDescription: String? = nil

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                newWorld = try loadWAD(fromURL: url)
            }
            catch let error as DecodingError {
                errorDescription = String(describing: error)
            }
            catch let error as LocalizedError {
                errorDescription = error.errorDescription ?? "Unknown error."
            }
            catch {
                errorDescription = error.localizedDescription
            }
            DispatchQueue.main.async {
                self.world = newWorld
                self.lastErrorDescription = errorDescription
                self.worldVersion += 1
                self.activeMapIndex = 0
                self.worldIsLoading = false
            }
        }
    }

    // Map selection.
    var activeMapIndex: Int = 0 {
        willSet(index) {
            self.objectWillChange.send()
            guard let world = world else { return }
            world.map = world.maps[index]
        }
    }
    var activeMapName: String { world?.map?.name ?? "-" }
    var mapCount: Int { world?.maps.count ?? 0 }
    func name(ofMap id: Int) -> String { world?.maps[id].name ?? "-" }

    private func get(url: URL) -> World? {
        do {
            return try loadWAD(fromURL: url)
        }
        catch let error as DecodingError {
            lastErrorDescription = String(describing: error)
        }
        catch let error as LocalizedError {
            lastErrorDescription = error.errorDescription ?? "Unknown error."
        }
        catch {
            lastErrorDescription = error.localizedDescription
        }
        return nil
    }

    // Screenshots.
    typealias ScreenshotsCallback = ([CGImage]) -> Void
    private var screenshotsJobs: [ScreenshotsCallback] = []
    private var screenshotsQueue = DispatchQueue(label: "goom.screenshot", attributes: .concurrent)

    /// Schedule taking a screenshot at the next frame draw.
    /// The call is thread-safe.
    func takeScreenshot(_ action: @escaping ScreenshotsCallback) {
        screenshotsQueue.async {
            self.screenshotsJobs.append(action)
        }
    }

    /// Pop the last screenshot-taking request. The call is thread-safe.
    func popScreenshotsAction() -> ScreenshotsCallback? {
        screenshotsQueue.sync {
            return self.screenshotsJobs.popLast()
        }
    }
}

struct ImageFile: FileDocument {
    static var readableContentTypes = [UTType.gif]
    var images: [CGImage] = []

    init(_ images: [CGImage]) {
        self.images = images
    }

    init(configuration: ReadConfiguration) throws {
        throw RuntimeError("Cannot load screenshots.")
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = save(cgImages: images)
        else { throw RuntimeError("Cannot save screenshot.") }
        return FileWrapper(regularFileWithContents: data)
    }
}

struct WorldView: View {
    @StateObject var worldManager = WorldManager()
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var screenshot: ImageFile? = nil

    var mapPicker: some View {
        return Picker(
            selection: $worldManager.activeMapIndex,
            label: Text("Map")
        ) {
            // id: \.self does not seem to update properly when loading
            // a new map, probably because the ids of the integers are not
            // actually changing
            ForEach(0..<worldManager.mapCount) {
                Text(worldManager.name(ofMap: $0)).tag($0)
            }
        }
        .frame(maxWidth: 160)
        .id(worldManager.worldVersion)
    }

    var screen: some View {
        ZStack {
            if worldManager.world != nil {
                ScreenView()
                    .environmentObject(worldManager)
                    .fileImporter(
                        isPresented: $isImporting,
                        allowedContentTypes: [UTType("org.goom.wad")!],
                        allowsMultipleSelection: false
                    ) { result in
                        do {
                            let urls = try result.get()
                            if let url = urls.first {
                                if url.startAccessingSecurityScopedResource() {
                                    worldManager.load(url: url)
                                    url.stopAccessingSecurityScopedResource()
                                }
                            }
                        }
                        catch {}
                    }
                    .fileExporter(
                        isPresented: $isExporting,
                        document: screenshot,
                        contentType: UTType.gif
                    ) { result in
                        screenshot = nil
                    }
                    .zIndex(0)
            }
            else {
                ZStack {
                    Color(.black)
                    Text(worldManager.lastErrorDescription ?? "No WAD file loaded.")
                }.zIndex(0)
            }

            if self.worldManager.worldIsLoading {
                ZStack {
                    #if os(macOS)
                        Color(NSColor.controlBackgroundColor)
                            .ignoresSafeArea()
                            .opacity(0.9)
                    #else
                        Color(.systemBackground)
                            .ignoresSafeArea()
                            .opacity(0.9)
                    #endif
                    HStack {
                        HStack(spacing: 10) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Text("Loading WAD…")
                        }
                    }
                }.zIndex(1)
                    .transition(.opacity.animation(.easeInOut(duration: 0.5)))
            }
        }
    }

    var body: some View {
        #if os(macOS)
            screen
                .toolbar {
                    HStack(alignment: .firstTextBaseline) {
                        mapPicker

                        Button("Open WAD…") {
                            isImporting.toggle()
                        }

                        Button("Save Screenshot…") {
                            worldManager.takeScreenshot {
                                screenshot = ImageFile($0)
                                isExporting = true
                            }
                        }
                    }
                }
        #else
            NavigationView {
                screen
                    .navigationTitle("Goom")
                    .navigationBarHidden(true)
                    .toolbar {
                        ToolbarItemGroup(placement: .bottomBar) {
                            mapPicker

                            Button {
                                worldManager.takeScreenshot {
                                    screenshot = ImageFile($0)
                                    isExporting = true
                                }
                            } label: {
                                Image(systemName: "camera.fill")
                            }

                            Button {
                                isImporting.toggle()
                            } label: {
                                Image(systemName: "square.and.arrow.down")
                            }
                        }
                    }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}

@main
struct SwiftUIAppLifeCycleApp: App {
    var body: some Scene {
        WindowGroup {
            WorldView()
        }
    }
}
