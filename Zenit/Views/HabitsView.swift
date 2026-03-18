import SwiftUI

struct HabitsView: View {
    @EnvironmentObject var store: AppStore
    @State private var showingAddHabit = false
    @State private var newHabitName = ""
    @State private var newHabitEmoji = "⭐️"
    @State private var selectedColor = "purple"
    @State private var animateIn = false

    let emojiOptions = ["⭐️","💧","📚","🏃","🧘","💪","🎯","🌿","✍️","🎨"]
    let colorOptions = ["purple","blue","green","orange","pink"]

    var body: some View {
        ZStack {
            ZenitTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    headerSection
                    streakBanner
                    habitsList
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
            }

            addButton

            if showingAddHabit {
                addHabitSheet
            }
        }
        .onAppear { withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { animateIn = true } }
    }

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Habits")
                .font(ZenitTheme.displayFont)
                .foregroundColor(.white)
            Text("\(store.habits.filter { $0.completedToday }.count) of \(store.habits.count) done today")
                .font(ZenitTheme.captionFont)
                .foregroundColor(ZenitTheme.textSecondary)
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
    }

    var streakBanner: some View {
        let totalStreak = store.habits.map { $0.streak }.max() ?? 0
        return ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [Color.purple.opacity(0.4), Color.blue.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
            HStack(spacing: 16) {
                Text("🔥")
                    .font(.system(size: 40))
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(totalStreak) day streak")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Keep the momentum going")
                        .font(ZenitTheme.captionFont)
                        .foregroundColor(ZenitTheme.textSecondary)
                }
                Spacer()
                CircularProgress(progress: store.habits.isEmpty ? 0 : Double(store.habits.filter { $0.completedToday }.count) / Double(store.habits.count))
                    .frame(width: 52, height: 52)
            }
            .padding(20)
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateIn)
    }

    var habitsList: some View {
        VStack(spacing: 14) {
            ForEach(store.habits.indices, id: \.self) { i in
                HabitRow(habit: $store.habits[i])
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 30)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(i) * 0.07 + 0.15), value: animateIn)
            }
        }
    }

    var addButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { withAnimation(.spring()) { showingAddHabit = true } }) {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 58, height: 58)
                        .background(LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .clipShape(Circle())
                        .shadow(color: Color.purple.opacity(0.5), radius: 16, x: 0, y: 8)
                }
                .padding(.trailing, 28)
                .padding(.bottom, 110)
            }
        }
    }

    var addHabitSheet: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea().onTapGesture { withAnimation(.spring()) { showingAddHabit = false } }
            VStack(spacing: 20) {
                Text("New Habit")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(newHabitEmoji)
                    .font(.system(size: 56))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(emojiOptions, id: \.self) { emoji in
                            Text(emoji)
                                .font(.system(size: 28))
                                .frame(width: 52, height: 52)
                                .background(newHabitEmoji == emoji ? Color.white.opacity(0.2) : Color.white.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .onTapGesture { newHabitEmoji = emoji }
                        }
                    }.padding(.horizontal, 4)
                }
                TextField("Habit name...", text: $newHabitName)
                    .font(ZenitTheme.bodyFont)
                    .foregroundColor(.white)
                    .padding(14)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                Button(action: createHabit) {
                    Text("Add Habit")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient(colors: [Color.purple, Color.blue], startPoint: .leading, endPoint: .trailing))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(newHabitName.isEmpty)
                .opacity(newHabitName.isEmpty ? 0.5 : 1)
            }
            .padding(28)
            .background(ZenitTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .padding(.horizontal, 24)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    func createHabit() {
        guard !newHabitName.isEmpty else { return }
        let habit = Habit(name: newHabitName, emoji: newHabitEmoji, colorName: selectedColor)
        store.habits.append(habit)
        store.saveHabits()
        newHabitName = ""
        newHabitEmoji = "⭐️"
        withAnimation(.spring()) { showingAddHabit = false }
    }
}

struct HabitRow: View {
    @Binding var habit: Habit
    @State private var tapped = false

    var body: some View {
        HStack(spacing: 16) {
            Text(habit.emoji)
                .font(.system(size: 28))
                .frame(width: 52, height: 52)
                .background(habit.completedToday ? accentColor.opacity(0.3) : Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(ZenitTheme.bodyFont)
                    .foregroundColor(.white)
                    .strikethrough(habit.completedToday, color: ZenitTheme.textSecondary)
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.orange)
                    Text("\(habit.streak) day streak")
                        .font(ZenitTheme.captionFont)
                        .foregroundColor(ZenitTheme.textSecondary)
                }
            }
            Spacer()
            Button(action: toggle) {
                ZStack {
                    Circle()
                        .fill(habit.completedToday ? accentColor : Color.white.opacity(0.08))
                        .frame(width: 36, height: 36)
                    if habit.completedToday {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .scaleEffect(tapped ? 1.2 : 1.0)
        }
        .padding(16)
        .background(ZenitTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(habit.completedToday ? accentColor.opacity(0.4) : Color.white.opacity(0.06), lineWidth: 1))
    }

    var accentColor: Color {
        switch habit.colorName {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "pink": return .pink
        default: return .purple
        }
    }

    func toggle() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            tapped = true
            habit.completedToday.toggle()
            if habit.completedToday { habit.streak += 1 } else { habit.streak = max(0, habit.streak - 1) }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { withAnimation { tapped = false } }
    }
}

struct CircularProgress: View {
    var progress: Double
    var body: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.1), lineWidth: 4)
            Circle().trim(from: 0, to: CGFloat(progress)).stroke(LinearGradient(colors: [.purple,.blue], startPoint: .topLeading, endPoint: .bottomTrailing), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}
