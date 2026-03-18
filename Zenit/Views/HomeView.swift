import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: AppStore
    @State private var showGreeting = false
    @State private var pulseAnim = false
    @State private var cardAppear = false

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
        }
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "0D0D0F"), Color(hex: "12121A"), Color(hex: "0A0A12")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Ambient glow orbs
            Circle()
                .fill(Color(hex: "7C6AF7").opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 80)
                .offset(x: -80, y: -180)
                .scaleEffect(pulseAnim ? 1.05 : 0.97)
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: pulseAnim)

            Circle()
                .fill(Color(hex: "F7A26A").opacity(0.08))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(x: 120, y: 120)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {

                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(greeting)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                                .offset(y: showGreeting ? 0 : 10)
                                .opacity(showGreeting ? 1 : 0)

                            Text("Gedeon.")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .offset(y: showGreeting ? 0 : 14)
                                .opacity(showGreeting ? 1 : 0)
                        }
                        Spacer()
                        // Avatar / streak badge
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Color(hex:"7C6AF7"), Color(hex:"A78BFA")], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 46, height: 46)
                            Text("G")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .shadow(color: Color(hex:"7C6AF7").opacity(0.5), radius: 12, x: 0, y: 4)
                    }
                    .padding(.top, 60)

                    // Date pill
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12, weight: .semibold))
                        Text(Date(), style: .date)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(Color(hex:"7C6AF7"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color(hex:"7C6AF7").opacity(0.15))
                    .clipShape(Capsule())

                    // Daily Focus Card
                    DailyFocusCard()
                        .offset(y: cardAppear ? 0 : 30)
                        .opacity(cardAppear ? 1 : 0)

                    // Quick Stats Row
                    HStack(spacing: 14) {
                        StatCard(icon: "checkmark.circle.fill", value: "\(store.completedToday)", label: "Done today", color: Color(hex:"34D399"))
                        StatCard(icon: "flame.fill", value: "\(store.streak)", label: "Day streak", color: Color(hex:"F97316"))
                        StatCard(icon: "moon.fill", value: store.moodEmoji, label: "Today's mood", color: Color(hex:"A78BFA"))
                    }
                    .offset(y: cardAppear ? 0 : 30)
                    .opacity(cardAppear ? 1 : 0)

                    // Recent tasks
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Up next")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Spacer()
                            Text("See all")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex:"7C6AF7"))
                        }

                        ForEach(store.tasks.prefix(3)) { task in
                            HomeTaskRow(task: task)
                        }
                    }
                    .padding(.bottom, 100)
                }
                .padding(.horizontal, 24)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) { showGreeting = true }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.3)) { cardAppear = true }
            pulseAnim = true
        }
    }
}

// MARK: - Daily Focus Card
struct DailyFocusCard: View {
    @State private var progress: Double = 0.65

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color(hex:"1E1B3A"), Color(hex:"1A1728")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Color(hex:"7C6AF7").opacity(0.25), lineWidth: 1)

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(Color(hex:"F7C26A"))
                    Text("Daily Focus")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Text("65%")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex:"7C6AF7"))
                }

                Text("Ship the Zenit app")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // Progress bar
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 6)
                    Capsule()
                        .fill(LinearGradient(colors: [Color(hex:"7C6AF7"), Color(hex:"A78BFA")], startPoint: .leading, endPoint: .trailing))
                        .frame(width: progress * (UIScreen.main.bounds.width - 96), height: 6)
                        .animation(.spring(response: 1.2, dampingFraction: 0.8).delay(0.5), value: progress)
                }

                HStack {
                    Label("2h 30m left", systemImage: "clock")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.45))
                    Spacer()
                }
            }
            .padding(20)
        }
        .onAppear { progress = 0.65 }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(color.opacity(0.2), lineWidth: 1))
        )
    }
}

// MARK: - Home Task Row
struct HomeTaskRow: View {
    let task: ZenitTask
    @State private var checked = false

    var body: some View {
        HStack(spacing: 14) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { checked.toggle() }
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(checked ? Color(hex:"7C6AF7") : Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 26, height: 26)
                    if checked {
                        Circle().fill(Color(hex:"7C6AF7")).frame(width: 26, height: 26)
                        Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(checked ? .white.opacity(0.35) : .white)
                    .strikethrough(checked, color: .white.opacity(0.35))
                if let subtitle = task.subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.35))
                }
            }
            Spacer()
            // Priority dot
            Circle()
                .fill(task.priorityColor)
                .frame(width: 8, height: 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.white.opacity(0.07), lineWidth: 1))
        )
    }
}
