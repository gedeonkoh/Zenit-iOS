import SwiftUI

struct FocusView: View {
    @State private var timeRemaining: Int = 25 * 60
    @State private var isRunning = false
    @State private var sessionType: SessionType = .focus
    @State private var completedSessions = 0
    @State private var ringPulse = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    enum SessionType: String, CaseIterable {
        case focus = "Focus"
        case shortBreak = "Short Break"
        case longBreak = "Long Break"
        var duration: Int {
            switch self {
            case .focus: return 25 * 60
            case .shortBreak: return 5 * 60
            case .longBreak: return 15 * 60
            }
        }
        var color: Color {
            switch self {
            case .focus: return Color(hex: "7C6AF7")
            case .shortBreak: return Color(hex: "34D399")
            case .longBreak: return Color(hex: "60A5FA")
            }
        }
        var icon: String {
            switch self {
            case .focus: return "brain.head.profile"
            case .shortBreak: return "cup.and.saucer.fill"
            case .longBreak: return "figure.walk"
            }
        }
    }

    var progress: Double {
        1.0 - (Double(timeRemaining) / Double(sessionType.duration))
    }

    var timeString: String {
        let m = timeRemaining / 60
        let s = timeRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            // Background
            Color(hex: "0D0D0F").ignoresSafeArea()

            // Ambient glow matching session type
            Circle()
                .fill(sessionType.color.opacity(0.1))
                .frame(width: 400, height: 400)
                .blur(radius: 100)
                .scaleEffect(isRunning && ringPulse ? 1.08 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: ringPulse)

            VStack(spacing: 0) {
                // Title
                Text("Focus Mode")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.45))
                    .padding(.top, 70)

                Spacer()

                // Session type picker
                HStack(spacing: 8) {
                    ForEach(SessionType.allCases, id: \.self) { type in
                        Button {
                            withAnimation(.spring(response: 0.4)) {
                                sessionType = type
                                timeRemaining = type.duration
                                isRunning = false
                            }
                        } label: {
                            Text(type.rawValue)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(sessionType == type ? .white : .white.opacity(0.4))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(sessionType == type ? type.color.opacity(0.25) : Color.clear)
                                        .overlay(Capsule().strokeBorder(sessionType == type ? type.color.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1))
                                )
                        }
                    }
                }

                Spacer()

                // Main Ring Timer
                ZStack {
                    // Outer glow
                    Circle()
                        .stroke(sessionType.color.opacity(0.08), lineWidth: 28)
                        .frame(width: 280, height: 280)

                    // Background ring
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 10)
                        .frame(width: 260, height: 260)

                    // Progress ring
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            AngularGradient(
                                colors: [sessionType.color.opacity(0.3), sessionType.color, sessionType.color.opacity(0.8)],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 260, height: 260)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)

                    // Center content
                    VStack(spacing: 8) {
                        Image(systemName: sessionType.icon)
                            .font(.system(size: 22))
                            .foregroundColor(sessionType.color)

                        Text(timeString)
                            .font(.system(size: 58, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .monospacedDigit()

                        Text(sessionType.rawValue.uppercased())
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(sessionType.color.opacity(0.8))
                            .tracking(2)
                    }
                }

                Spacer()

                // Session dots
                HStack(spacing: 8) {
                    ForEach(0..<4) { i in
                        Circle()
                            .fill(i < completedSessions ? sessionType.color : Color.white.opacity(0.15))
                            .frame(width: 8, height: 8)
                            .scaleEffect(i < completedSessions ? 1.2 : 1.0)
                            .animation(.spring(response: 0.4), value: completedSessions)
                    }
                }

                Spacer()

                // Controls
                HStack(spacing: 28) {
                    // Reset
                    Button {
                        withAnimation(.spring(response: 0.4)) {
                            isRunning = false
                            timeRemaining = sessionType.duration
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white.opacity(0.5))
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(Color.white.opacity(0.06)))
                    }

                    // Play/Pause
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            isRunning.toggle()
                            if isRunning { ringPulse = true }
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [sessionType.color, sessionType.color.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 80, height: 80)
                                .shadow(color: sessionType.color.opacity(0.5), radius: 20, x: 0, y: 8)

                            Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                                .offset(x: isRunning ? 0 : 2)
                        }
                    }

                    // Skip
                    Button {
                        withAnimation(.spring(response: 0.4)) {
                            if sessionType == .focus { completedSessions = min(completedSessions + 1, 4) }
                            let next: SessionType = sessionType == .focus ? .shortBreak : .focus
                            sessionType = next
                            timeRemaining = next.duration
                            isRunning = false
                        }
                    } label: {
                        Image(systemName: "forward.end.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white.opacity(0.5))
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(Color.white.opacity(0.06)))
                    }
                }
                .padding(.bottom, 100)
            }
        }
        .onReceive(timer) { _ in
            guard isRunning else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                isRunning = false
                if sessionType == .focus { completedSessions = min(completedSessions + 1, 4) }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
    }
}
