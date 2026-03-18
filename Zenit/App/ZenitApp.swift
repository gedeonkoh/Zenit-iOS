import SwiftUI

@main
struct ZenitApp: App {
    @StateObject private var taskVM = TaskViewModel()
    @StateObject private var habitVM = HabitViewModel()
    @StateObject private var focusVM = FocusViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(taskVM)
                .environmentObject(habitVM)
                .environmentObject(focusVM)
                .preferredColorScheme(.dark)
        }
    }
}
