import Foundation
import SwiftUI

// ─────────────────────────────────────────────
//  ZENIT — All Data Models
// ─────────────────────────────────────────────

// MARK: – ZenitTask
struct ZenitTask: Identifiable, Codable {
    var id = UUID()
    var title: String
    var note: String = ""
    var isCompleted: Bool = false
    var priority: TaskPriority = .medium
    var dueDate: Date? = nil
    var tag: String = ""
    var createdAt: Date = Date()
    var completedAt: Date? = nil
    var energyCost: Int = 2
}

enum TaskPriority: String, Codable, CaseIterable, Identifiable {
    case low, medium, high, critical
    var id: String { rawValue }

    var color: Color {
        switch self {
        case .low:      return Color(hex: "7BC67E")
        case .medium:   return Color(hex: "6C6EF5")
        case .high:     return Color(hex: "FFB347")
        case .critical: return Color(hex: "FF6B35")
        }
    }
    var label: String { rawValue.capitalized }
    var icon: String {
        switch self {
        case .low:      return "leaf.fill"
        case .medium:   return "bolt.fill"
        case .high:     return "flame.fill"
        case .critical: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: – ZenitHabit
struct ZenitHabit: Identifiable, Codable {
    var id = UUID()
    var name: String
    var emoji: String
    var colorHex: String
    var targetDays: Int = 7
    var completedDates: [Date] = []
    var streak: Int = 0
    var createdAt: Date = Date()

    var color: Color { Color(hex: colorHex) }

    var completedToday: Bool {
        Calendar.current.isDateInToday(completedDates.last ?? .distantPast)
    }

    var weeklyProgress: Double {
        let cal = Calendar.current
        let startOfWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let count = completedDates.filter { $0 >= startOfWeek }.count
        return min(Double(count) / Double(targetDays), 1.0)
    }

    mutating func toggleToday() {
        let cal = Calendar.current
        if completedToday {
            completedDates.removeAll { cal.isDateInToday($0) }
            streak = max(0, streak - 1)
        } else {
            completedDates.append(Date())
            streak += 1
        }
    }
}

// MARK: – FocusSession
struct FocusSession: Identifiable, Codable {
    var id = UUID()
    var duration: Int
    var taskLabel: String
    var mode: String
    var startedAt: Date
    var completedAt: Date?
    var wasCompleted: Bool = false
    var deepWorkScore: Int = 0
}

enum FocusMode: String, CaseIterable, Identifiable {
    case pomodoro = "Pomodoro"
    case deepWork = "Deep Work"
    case sprint   = "Sprint"
    case flow     = "Flow"

    var id: String { rawValue }
    var minutes: Int {
        switch self {
        case .pomodoro: return 25
        case .deepWork: return 90
        case .sprint:   return 45
        case .flow:     return 60
        }
    }
    var icon: String {
        switch self {
        case .pomodoro: return "timer"
        case .deepWork: return "brain.head.profile"
        case .sprint:   return "bolt.fill"
        case .flow:     return "water.waves"
        }
    }
    var description: String {
        switch self {
        case .pomodoro: return "25 min · classic rhythm"
        case .deepWork: return "90 min · maximum output"
        case .sprint:   return "45 min · fast execution"
        case .flow:     return "60 min · creative state"
        }
    }
    var breakMinutes: Int {
        switch self {
        case .pomodoro: return 5
        case .deepWork: return 20
        case .sprint:   return 10
        case .flow:     return 15
        }
    }
}

// MARK: – MoodEntry
struct MoodEntry: Identifiable, Codable {
    var id = UUID()
    var energy: Int = 3
    var focus: Int  = 3
    var stress: Int = 3
    var note: String = ""
    var recordedAt: Date = Date()

    var overallScore: Double {
        (Double(energy) + Double(focus) + Double(6 - stress)) / 3.0
    }

    var moodLabel: String {
        switch Int(overallScore.rounded()) {
        case 5:  return "In Flow"
        case 4:  return "Charged"
        case 3:  return "Steady"
        case 2:  return "Drained"
        default: return "Burned Out"
        }
    }

    var moodEmoji: String {
        switch Int(overallScore.rounded()) {
        case 5:  return "⚡"
        case 4:  return "✨"
        case 3:  return "🌤"
        case 2:  return "🌧"
        default: return "🌑"
        }
    }

    var auraColorHex: String {
        switch Int(overallScore.rounded()) {
        case 5:  return "00F5D4"
        case 4:  return "6C6EF5"
        case 3:  return "FFB347"
        case 2:  return "FF6B35"
        default: return "8B8B9E"
        }
    }
}
