import SwiftUI

let screenWidth = 320
let screenHeight = 256

class WorldManager: ObservableObject {
    private(set) lazy var world: World? = {
        do {
            return try World.load()
        } catch let error as DecodingError {
            lastErrorDescription = String(describing: error)
        } catch let error as LocalizedError {
            lastErrorDescription = error.errorDescription ?? "Unknown error."
        } catch {
            lastErrorDescription = error.localizedDescription
        }
        return nil
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
}

struct WorldView: View {
    @StateObject var worldManager = WorldManager()

    var mapPicker: some View {
        return Picker(
            selection: $worldManager.currentMapIndex,
            label: Text("Map")
        ) {
            ForEach(0 ..< worldManager.mapCount, id: \.self) {
                Text(worldManager.name(ofMap: $0)).tag($0)
            }
        }
        .frame(maxWidth: 160)
    }

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
    #endif

    var body: some View {
        #if os(macOS)
            VStack {
                if worldManager.world != nil {
                    mapPicker
                        .padding(.top, 6)
                    ScreenView()
                        .environmentObject(worldManager)
                } else {
                    Text(worldManager.lastErrorDescription)
                }
            }
            .frame(minWidth: 320, maxWidth: .infinity,
                   minHeight: 256, maxHeight: .infinity)
        #else
            if worldManager.world != nil {
                NavigationView {
                    VStack(spacing: 2) {
                        NavigationLink(destination: form, label: {
                            Text("Map \(worldManager.currentMapName)").padding(.top, 6)
                    })
                        ScreenView()
                            .environmentObject(worldManager)
                    }
                    .navigationBarHidden(true)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            } else {
                Text(worldManager.lastErrorDescription)
            }
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
