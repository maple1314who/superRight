import SwiftUI
import Shared

public struct RootConfigurationView: View {
    @StateObject private var viewModel: MenuManagementViewModel

    public init(
        store: ConfigurationStore = UserDefaultsConfigurationStore()
    ) {
        _viewModel = StateObject(wrappedValue: MenuManagementViewModel(store: store))
    }

    public var body: some View {
        TabView {
            MenuManagementView(viewModel: viewModel)
                .tabItem {
                    Label("菜单管理", systemImage: "list.bullet")
                }

            ApplicationSettingsView(viewModel: viewModel)
                .tabItem {
                    Label("应用设置", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    RootConfigurationView(store: InMemoryConfigurationStore())
}
