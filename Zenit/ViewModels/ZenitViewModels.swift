import Foundation
import SwiftUI
import Combine

// ─────────────────────────────────────────────
//  ZENIT — All ViewModels
// ─────────────────────────────────────────────

// MARK: – TaskViewModel
class TaskViewModel: ObservableObject {
    @Published var tasks: [ZenitTask] = []
    @Published var showingAddTask = false
    @Published var filterTag: String = ""

    private let storageKey = "zenit_tasks"

    init() { load() }

    var completedToday: Int {
        let cal = Calendar.current
        return tasks.filter { $0.isCompleted && cal.isDateInToday($0.completedAt ?? .distantPast) }.count
    }

    var pendingTasks: [ZenitTask] { tasks.filter { !$0.isCompleted } }
    var completedTasks: [ZenitTask] { tasks.filter { $0.isCompleted } }

    var filtered: [ZenitTask] {
        filterTag.isEmpty ? tasks : tasks.filter { $0.tag == filterTag }
    }

    func add(_ task: ZenitTask) {
        tasks.insert(task, at: 0)
        save()
    }

    func toggle(_ task: ZenitTask) {
        if let i = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[i].isCompleted.toggle()
            tasks[i].completedAt = tasks[i].isCompleted ? Date() : nil
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            save()
        }
    }

    func delete(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        save()
    }

    func delete(_ task: ZenitTask) {
        tasks.removeAll { $0.id == task.id }
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([ZenitTask].self, from: data) {
            tasks = decoded
        } else {
            tasks = Self.sampleTasks
        }
    }

    static let sampleTasks: [ZenitTask] = [
        ZenitTask(title: "Review triboelectric tile results", priority: .high, tag: "Research"),
        ZenitTask(title: "Push Zenit to GitHub", priority: .critical, tag: "Dev"),
        ZenitTask(title: "Prep workshop slides", priority: .medium, tag: "Education"),
        ZenitTask(title: "Read 20 pages", priority: .low, tag: "Personal"),
        ZenitTask(title: "Reply to mentor email", priority: .high, tag: "Work"),
    ]
}

// MARK: – HabitViewModel
class HabitViewModel: ObservableObject {
    @Published var habits: [ZenitHabit] = []

    private let storageKey = "zenit_habits"

    init() { load() }

    func toggle(_ habit: ZenitHabit) {
        if let i = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[i].toggleToday()
            let style: UIImpactFeedbackGenerator.FeedbackStyle = habits[i].completedToday ? .heavy : .light
            UIImpactFeedbackGenerator(style: style).impactOccurred()
            save()
        }
    }

    func add(_ habit: ZenitHabit) {
        habits.append(habit)
        save()
    }

    func delete(at offsets: IndexSet) {
        habits.remove(atOffsets: offsets)
        save()
    }

    var completedTodayCount: Int { habits.filter { $0.completedToday }.count }
    var totalStreakDays: Int { habits.map { $0.streak }.reduce(0, +) }

    private func save() {
        if let data = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([ZenitHabit].self, from: data) {
            habits = decoded
        } else {
            habits = Self.sampleHabits
        }
    }

    static let sampleHabits: [ZenitHabit] = [
        ZenitHabit(name: "Deep Work",    emoji: "🧠", colorHex: "6C6EF5", streak: 7),
        ZenitHabit(name: "Exercise",     emoji: "⚡", colorHex: "FF6B35", streak: 14),
        ZenitHabit(name: "Read",         emoji: "📖", colorHex: "00F5D4", streak: 3),
        ZenitHabit(name: "Meditate",     emoji: "🌿", colorHex: "7BC67E", streak: 5),
        ZenitHabit(name: "No Phone AM",  emoji: "🌙", colorHex: "C77DFF", streak: 2),
    ]
}

// MARK: – FocusViewModel
class FocusViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var isPaused  = false
    @Published var selectedMode: FocusMode = .pomodoro
    @Published var secondsRemaining: Int = FocusMode.pomodoro.minutes * 60
    @Published var sessionLabel: String = ""
    @Published var sessions: [FocusSession] = []
    @Published var isBreak = false
    @Published var breathingPhase: Double = 0

    private var timer: Timer?
    private var breathTimer: Timer?
    private let storageKey = "zenit_sessions"

    init() {
        load()
        startBreathingAnimation()
    }

    var progress: Double {
        let total = Double(selectedMode.minutes * 60)
        return 1.0 - (Double(secondsRemaining) / total)
    }

    var timeString: String {
        let m = secondsRemaining / 60
        let s = secondsRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    var todayFocusMinutes: Int {
        let cal = Calendar.current
        return sessions
            .filter { cal.isDateInToday($0.startedAt) && $0.wasCompleted }
            .map { $0.duration }
            .reduce(0, +)
    }

    func selectMode(_ mode: FocusMode) {
        guard !isRunning else { return }
        selectedMode = mode
        secondsRemaining = mode.minutes * 60
        isBreak = false
    }

    func start() {
        isRunning = true
        isPaused  = false
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func pause() {
        isPaused = true
        timer?.invalidate()
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    func resume() {
        isPaused = false
        start()
    }

    func stop() {
        timer?.invalidate()
        isRunning = false
        isPaused  = false
        secondsRemaining = selectedMode.minutes * 60
        isBreak = false
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    private func tick() {
        if secondsRemaining > 0 {
            secondsRemaining -= 1
        } else {
            complete()
        }
    }

    private func complete() {
        timer?.invalidate()
        isRunning = false
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        let session = FocusSession(
            duration: selectedMode.minutes,
            taskLabel: sessionLabel.isEmpty ? selectedMode.rawValue : sessionLabel,
            mode: selectedMode.rawValue,
            startedAt: Date(),
            completedAt: Date(),
            wasCompleted: true,
            deepWorkScore: Int.random(in: 70...100)
        )
        sessions.insert(session, at: 0)
        save()
        secondsRemaining = selectedMode.minutes * 60
    }

    private func startBreathingAnimation() {
        breathTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.breathingPhase += 0.02
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([FocusSession].self, from: data) {
            sessions = decoded
        }
    }
}
