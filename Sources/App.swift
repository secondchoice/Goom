import SwiftUI
import UniformTypeIdentifiers

let screenWidth = 320
let screenHeight = 256

class WorldManager: ObservableObject {
    private(set) lazy var world: World? = {
        guard let path = Bundle.main.path(forResource: "Assets/doom1", ofType: "wad") else {
            lastErrorDescription = "Could not find the asset doom1.wad in the application bundle."
            return nil
        }
        return get(url: URL(fileURLWithPath: path))
    }()

    let screen: Screen = Screen(width: screenWidth, height: screenHeight)
    let joypad = Joypad()
    private(set) var lastErrorDescription = ""

    var currentMapIndex: Int = 0 {
        willSet(index) {
            self.objectWillChange.send()
            guard let world = world else { return }
            world.map = world.maps[index]
        }
    }

    var currentMapName: String { world?.map?.name ?? "-" }
    var mapCount: Int { world?.maps.count ?? 0 }
    func name(ofMap id: Int) -> String { world?.maps[id].name ?? "-" }

    func load(url: URL) {
        world = get(url: url)
        currentMapIndex = 0
    }

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
}

struct WorldView: View {
    @StateObject var worldManager = WorldManager()

    var mapPicker: some View {
        return Picker(
            selection: $worldManager.currentMapIndex,
            label: Text("Map")
        ) {
            ForEach(0..<worldManager.mapCount, id: \.self) {
                Text(worldManager.name(ofMap: $0)).tag($0)
            }
        }
        .frame(maxWidth: 160)
    }

    #if os(macOS)
        func showOpenPanel() -> URL? {
            let openPanel = NSOpenPanel()
            openPanel.allowedFileTypes = ["wad"]
            openPanel.allowsMultipleSelection = false
            openPanel.canChooseDirectories = false
            openPanel.canChooseFiles = true
            let response = openPanel.runModal()
            return response == .OK ? openPanel.url : nil
        }
    #endif

    #if os(iOS)
        var form: some View {
            return Form {
                Section(header: Text("Map")) {
                    mapPicker
                }
            }
            .navigationBarTitle("Settings")
            .navigationBarHidden(false)
        }
        @State private var isImporting = false
    #endif

    var screen: some View {
        if worldManager.world != nil {
            return AnyView(
                ScreenView()
                    .environmentObject(worldManager)
                    .frame(
                        minWidth: 320,
                        maxWidth: .infinity,
                        minHeight: 256,
                        maxHeight: .infinity
                    )
            )
        }
        else {
            return AnyView(Text(worldManager.lastErrorDescription))
        }
    }

    var body: some View {
        #if os(macOS)
            screen
                .toolbar {
                    HStack(alignment: .firstTextBaseline) {
                        mapPicker
                            .padding(.top, 6)

                        Button("Open WAD…") {
                            if let url = showOpenPanel() {
                                worldManager.load(url: url)
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
                            NavigationLink(
                                destination: form,
                                label: {
                                    Text("Map \(worldManager.currentMapName)").padding(.top, 6)
                                }
                            )

                            Button {
                                isImporting = true
                            } label: {
                                Image(systemName: "square.and.arrow.down")
                            }
                        }
                    }
                    .fileImporter(
                        isPresented: $isImporting,
                        allowedContentTypes: [UTType("org.goom.wad")!],
                        allowsMultipleSelection: false
                    ) { result in
                        do {
                            let urls = try result.get()
                            worldManager.load(url: urls.first!)
                        }
                        catch {}
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
