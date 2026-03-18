import SwiftUI

struct MoodView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedMood: MoodEntry.MoodLevel? = nil
    @State private var noteText = ""
    @State private var moodLogged = false
    @State private var cardScale: CGFloat = 0.9

    var body: some View {
        ZStack {
            Color(hex: "0D0D0F").ignoresSafeArea()

            // Ambient color matching selected mood
            if let mood = selectedMood {
                Circle()
                    .fill(mood.color.opacity(0.1))
                    .frame(width: 380, height: 380)
                    .blur(radius: 100)
                    .animation(.easeInOut(duration: 0.5), value: selectedMood)
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 6) {
                        Text("How are you?")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text(Date(), style: .date)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.top, 70)

                    // Mood selector
                    VStack(spacing: 20) {
                        Text("Pick a vibe")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                            .tracking(1)
                            .textCase(.uppercase)

                        HStack(spacing: 16) {
                            ForEach(MoodEntry.MoodLevel.allCases, id: \.self) { mood in
                                MoodButton(mood: mood, isSelected: selectedMood == mood) {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                        selectedMood = mood
                                        store.todayMood = mood
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    }
                                }
                            }
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white.opacity(0.04))
                            .overlay(RoundedRectangle(cornerRadius: 28).strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
                    )

                    // Note input
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Add a note", systemImage: "pencil.line")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))

                        ZStack(alignment: .topLeading) {
                            if noteText.isEmpty {
                                Text("What's on your mind...")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.25))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                            }
                            TextEditor(text: $noteText)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 100, maxHeight: 140)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.white.opacity(0.05))
                            .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
                    )

                    // Log button
                    Button {
                        guard selectedMood != nil else { return }
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            moodLogged = true
                            store.logMood(level: selectedMood!, note: noteText)
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { moodLogged = false }
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: moodLogged ? "checkmark.circle.fill" : "heart.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text(moodLogged ? "Logged!" : "Log Mood")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            Group {
                                if let mood = selectedMood {
                                    LinearGradient(colors: [mood.color, mood.color.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                                } else {
                                    LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.07)], startPoint: .leading, endPoint: .trailing)
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: (selectedMood?.color ?? .clear).opacity(0.4), radius: 16, x: 0, y: 8)
                    }
                    .disabled(selectedMood == nil)

                    // Weekly mood chart
                    WeeklyMoodChart(entries: store.moodHistory)
                        .padding(.bottom, 100)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

// MARK: - Mood Button
struct MoodButton: View {
    let mood: MoodEntry.MoodLevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(mood.emoji)
                    .font(.system(size: 36))
                    .scaleEffect(isSelected ? 1.25 : 1.0)
                    .shadow(color: isSelected ? mood.color.opacity(0.6) : .clear, radius: 12)

                Text(mood.rawValue)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? mood.color : .white.opacity(0.35))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? mood.color.opacity(0.15) : Color.clear)
                    .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(isSelected ? mood.color.opacity(0.4) : Color.clear, lineWidth: 1.5))
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
    }
}

// MARK: - Weekly Mood Chart
struct WeeklyMoodChart: View {
    let entries: [MoodEntry]
    private let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This week")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            HStack(alignment: .bottom, spacing: 0) {
                ForEach(Array(days.enumerated()), id: \.offset) { i, day in
                    VStack(spacing: 6) {
                        if i < entries.count {
                            Text(entries[i].level.emoji)
                                .font(.system(size: 22))
                                .frame(height: 44)
                        } else {
                            Circle()
                                .fill(Color.white.opacity(0.08))
                                .frame(width: 8, height: 8)
                                .frame(height: 44)
                        }
                        Text(day)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(Color.white.opacity(0.07), lineWidth: 1))
        )
    }
}
