import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedTab: Int = 0
    @State private var tabBarVisible = true

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                TasksView()
                    .tag(1)
                FocusView()
                    .tag(2)
                JournalView()
                    .tag(3)
                InsightsView()
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            ZenitTabBar(selectedTab: $selectedTab)
                .padding(.bottom, 8)
        }
        .ignoresSafeArea(edges: .bottom)
        .background(Color.zenitBlack)
    }
}
