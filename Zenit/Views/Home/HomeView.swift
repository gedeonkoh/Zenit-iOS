import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: AppStore
    @State private var greeting = ""
    @State private var headerVisible = false
    @State private var cardsVisible = false

    var body: some View {
        ZStack {
            OrbBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text(greeting)
                            .font(ZFont.caption).foregroundColor(.zenitSubtext)
                            .textCase(.uppercase).tracking(2)
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Your day,").font(ZFont.hero).foregroundColor(.zenitText)
                                Text(dayLabel()).font(ZFont.hero)
                                    .foregroundStyle(LinearGradient(colors: [.zenitAccent, .zenitAccent2], startPoint: .leading, endPoint: .trailing))
                            }
                            Spacer()
                            VStack(spacing: 4) {
                                ZStack {
                                    Circle().fill(LinearGradient(colors: [.zenitGold, .zenitRose], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 52, height: 52).shadow(color: .zenitGold.opacity(0.5), radius: 12)
                                    Text("\u{1F525}").font(.system(size: 22))
                                }
                                Text("\(store.streakCount)d streak").font(ZFont.micro).foregroundColor(.zenitGold)
                            }
                        }
                    }
                    .padding(.top, 60)
                    .opacity(headerVisible ? 1 : 0).offset(y: headerVisible ? 0 : 20)

                    // Stats Row
                    HStack(spacing: 12) {
                        StatCard(value: "\(store.completedToday)", label: "Done today", icon: "checkmark.circle.fill", color: .zenitMint)
                        StatCard(value: "\(store.todayFocusMinutes)m", label: "Focus time", icon: "timer", color: .zenitAccent)
                        StatCard(value: "\(store.tasks.filter { !$0.isDone }.count)", label: "Pending", icon: "tray.fill", color: .zenitRose)
                    }
                    .opacity(cardsVisible ? 1 : 0).offset(y: cardsVisible ? 0 : 20)

                    ProgressArcCard().opacity(cardsVisible ? 1 : 0)

                    // Tasks
                    VStack(spacing: 12) {
                        ZSectionHeader("Today", subtitle: "\(store.tasks.filter { !$0.isDone }.count) remaining")
                        ForEach(store.tasks.prefix(3)) { task in QuickTaskRow(task: task) }
                    }
                    .opacity(cardsVisible ? 1 : 0)

                    MoodBannerCard().opacity(cardsVisible ? 1 : 0)
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            updateGreeting()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) { headerVisible = true }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) { cardsVisible = true }
        }
    }

    func updateGreeting() {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12: greeting = "Good morning"
        case 12..<17: greeting = "Good afternoon"
        case 17..<22: greeting = "Good evening"
        default: greeting = "Still up?"
        }
    }

    func dayLabel() -> String {
        let f = DateFormatter(); f.dateFormat = "EEEE."
        return f.string(from: Date())
    }
}

struct StatCard: View {
    let value: String; let label: String; let icon: String; let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).font(.system(size: 18, weight: .semibold)).foregroundColor(color)
            Text(value).font(ZFont.title2).foregroundColor(.zenitText)
            Text(label).font(ZFont.micro).foregroundColor(.zenitSubtext)
        }
        .frame(maxWidth: .infinity, alignment: .leading).glassCard(padding: 16)
    }
}

struct ProgressArcCard: View {
    @EnvironmentObject var store: AppStore
    @State private var progress: CGFloat = 0
    var pct: CGFloat { guard store.totalTasks > 0 else { return 0 }; return CGFloat(store.completedToday) / CGFloat(store.totalTasks) }
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle().stroke(Color.zenitBorder, lineWidth: 6).frame(width: 80, height: 80)
                Circle().trim(from: 0, to: progress)
                    .stroke(AngularGradient(colors: [.zenitAccent, .zenitMint], center: .center), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 80, height: 80).rotationEffect(.degrees(-90))
                Text("\(Int(progress * 100))%").font(ZFont.bodyMed).foregroundColor(.zenitText)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("Tasks complete").font(ZFont.title3).foregroundColor(.zenitText)
                Text("\(store.completedToday) of \(store.totalTasks) done today").font(ZFont.caption).foregroundColor(.zenitSubtext)
                ProgressView(value: progress).progressViewStyle(LinearProgressViewStyle(tint: .zenitAccent)).scaleEffect(x: 1, y: 1.5)
            }
        }
        .glassCard()
        .onAppear { withAnimation(.spring(response: 1, dampingFraction: 0.7).delay(0.5)) { progress = pct } }
    }
}

struct QuickTaskRow: View {
    @EnvironmentObject var store: AppStore
    let task: ZTask
    @State private var bounce = false
    var body: some View {
        HStack(spacing: 14) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { bounce = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { bounce = false }
                store.toggleTask(task)
            } label: {
                ZStack {
                    Circle().stroke(task.isDone ? task.priority.color : Color.zenitBorder, lineWidth: 2).frame(width: 26, height: 26)
                    if task.isDone { Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundColor(task.priority.color).scaleEffect(bounce ? 1.4 : 1.0) }
                }
            }.buttonStyle(.plain)
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title).font(ZFont.bodyMed).foregroundColor(task.isDone ? .zenitSubtext : .zenitText).strikethrough(task.isDone, color: .zenitSubtext)
                if !task.tag.isEmpty {
                    Text(task.tag).font(ZFont.micro).foregroundColor(task.priority.color)
                        .padding(.horizontal, 8).padding(.vertical, 2).background(task.priority.color.opacity(0.15)).clipShape(Capsule())
                }
            }
            Spacer()
            Circle().fill(task.priority.color).frame(width: 8, height: 8)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(Color.zenitSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.zenitBorder.opacity(0.5), lineWidth: 0.5))
    }
}

struct MoodBannerCard: View {
    var body: some View {
        HStack(spacing: 16) {
            Text("\u{1F31F}").font(.system(size: 36))
            VStack(alignment: .leading, spacing: 4) {
                Text("How are you feeling?").font(ZFont.bodyMed).foregroundColor(.zenitText)
                Text("Log today's mood in 10 seconds").font(ZFont.caption).foregroundColor(.zenitSubtext)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(.zenitAccent)
        }
        .glassCard(padding: 18)
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(LinearGradient(colors: [.zenitAccent.opacity(0.6), .zenitAccent2.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
    }
}
