import SwiftUI
import Combine

// MARK: - Models

struct ZTask: Identifiable, Codable {
    var id = UUID()
    var title: String
    var note: String = ""
    var isDone: Bool = false
    var priority: Priority = .medium
    var dueDate: Date? = nil
    var tag: String = ""

    enum Priority: String, Codable, CaseIterable {
        case low, medium, high
        var color: Color {
            switch self {
            case .low: return .zenitMint
            case .medium: return .zenitAccent
            case .high: return .zenitRose
            }
        }
    }
}

struct JournalEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date = Date()
    var mood: Mood = .neutral
    var body: String = ""
    var gratitude: String = ""

    enum Mood: String, Codable, CaseIterable {
        case amazing, happy, neutral, low, rough
        var emoji: String {
            switch self {
            case .amazing: return "\u{1F929}"
            case .happy:   return "\u{1F60A}"
            case .neutral: return "\u{1F610}"
            case .low:     return "\u{1F615}"
            case .rough:   return "\u{1F62B}"
            }
        }
        var label: String { rawValue.capitalized }
    }
}

struct FocusSession: Identifiable, Codable {
    var id = UUID()
    var date: Date = Date()
    var duration: Int  // seconds completed
    var label: String
}

// MARK: - AppStore

class AppStore: ObservableObject {
    @Published var tasks: [ZTask] = [
        ZTask(title: "Ship Zenit v1.0", priority: .high, tag: "Work"),
        ZTask(title: "Buy matcha latte", priority: .low, tag: "Personal"),
        ZTask(title: "Review pull requests", priority: .medium, tag: "Work"),
        ZTask(title: "Call mum", priority: .medium, tag: "Personal")
    ]

    @Published var journalEntries: [JournalEntry] = []
    @Published var focusSessions: [FocusSession] = []
    @Published var streakCount: Int = 4
    @Published var todayFocusMinutes: Int = 47
        @Published var journalStreak: Int = 7
    @Published var productivityScore: Double = 82.0
    @Published var completedTasksCount: Int = 24
    @Published var totalFocusHours: Double = 12.5
    @Published var completedHabitsCount: Int = 5
    @Published var totalHabitsCount: Int = 7
    
    var weeklyFocusData: [FocusDataPoint] {
        [
            FocusDataPoint(day: "Mon", minutes: 95),
            FocusDataPoint(day: "Tue", minutes: 110),
            FocusDataPoint(day: "Wed", minutes: 85),
            FocusDataPoint(day: "Thu", minutes: 120),
            FocusDataPoint(day: "Fri", minutes: 100),
            FocusDataPoint(day: "Sat", minutes: 75),
            FocusDataPoint(day: "Sun", minutes: 60)
        ]
    }
    
    var topHabits: [HabitStat] {
        [
            HabitStat(name: "Morning Exercise", icon: "💪", completionRate: 0.95),
            HabitStat(name: "Meditation", icon: "🧘", completionRate: 0.88),
            HabitStat(name: "Reading", icon: "📚", completionRate: 0.76),
            HabitStat(name: "Journaling", icon: "✍️", completionRate: 0.84),
            HabitStat(name: "Hydration", icon: "💧", completionRate: 0.92)
        ]
    }
    
    func moodCount(for mood: Mood) -> Int {
        journalEntries.filter { $0.mood == mood }.count
    }

    // Focus timer state
    @Published var timerActive: Bool = false
    @Published var timerSecondsLeft: Int = 25 * 60
    @Published var timerLabel: String = "Deep Work"
    private var timerCancellable: AnyCancellable?

    var completedToday: Int {
        tasks.filter { $0.isDone }.count
    }

    var totalTasks: Int { tasks.count }

    func toggleTask(_ task: ZTask) {
        if let i = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[i].isDone.toggle()
        }
    }

    func addTask(_ task: ZTask) {
        tasks.insert(task, at: 0)
    }

    func deleteTask(_ task: ZTask) {
        tasks.removeAll { $0.id == task.id }
    }

    func addJournalEntry(_ entry: JournalEntry) {
        journalEntries.insert(entry, at: 0)
    }

    // MARK: Focus Timer
    func startTimer() {
        timerActive = true
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timerSecondsLeft > 0 {
                    self.timerSecondsLeft -= 1
                } else {
                    self.stopTimer()
                    let session = FocusSession(duration: 25 * 60, label: self.timerLabel)
                    self.focusSessions.append(session)
                    self.todayFocusMinutes += 25
                }
            }
    }

    func pauseTimer() {
        timerActive = false
        timerCancellable?.cancel()
    }

    func stopTimer() {
        timerActive = false
        timerSecondsLeft = 25 * 60
        timerCancellable?.cancel()
    }

    func timerDisplay() -> String {
        let m = timerSecondsLeft / 60
        let s = timerSecondsLeft % 60
        return String(format: "%02d:%02d", m, s)
    }
}
