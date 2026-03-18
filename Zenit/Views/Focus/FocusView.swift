import SwiftUI

struct FocusView: View {
    @EnvironmentObject var store: AppStore
    @State private var pulseRing = false
    @State private var selectedDuration = 25
    let durations = [5, 15, 25, 45, 60]

    var progress: CGFloat {
        let total = CGFloat(selectedDuration * 60)
        return 1.0 - (CGFloat(store.timerSecondsLeft) / total)
    }

    var body: some View {
        ZStack {
            // Background
            Color.zenitBlack.ignoresSafeArea()

            // Breathing glow ring behind timer
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.zenitAccent.opacity(store.timerActive ? 0.25 : 0.08), .clear],
                        center: .center, startRadius: 0, endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .scaleEffect(pulseRing ? 1.06 : 0.94)
                .animation(
                    store.timerActive
                        ? .easeInOut(duration: 2).repeatForever(autoreverses: true)
                        : .default,
                    value: pulseRing
                )
                .onAppear { pulseRing = true }

            VStack(spacing: 40) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Focus")
                            .font(ZFont.title1).foregroundColor(.zenitText)
                        Text(store.timerActive ? "Stay in the zone" : "Ready when you are")
                            .font(ZFont.caption).foregroundColor(.zenitSubtext)
                    }
                    Spacer()
                    // Sessions today badge
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill").foregroundColor(.zenitGold).font(.system(size: 12))
                        Text("\(store.focusSessions.count) today")
                            .font(ZFont.caption).foregroundColor(.zenitGold)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.zenitGold.opacity(0.12))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                // Duration Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(durations, id: \.self) { d in
                            Button { if !store.timerActive { selectedDuration = d; store.timerSecondsLeft = d * 60 } } label: {
                                Text("\(d)m")
                                    .font(ZFont.caption)
                                    .foregroundColor(selectedDuration == d ? .white : .zenitSubtext)
                                    .padding(.horizontal, 16).padding(.vertical, 8)
                                    .background(selectedDuration == d ? Color.zenitAccent : Color.zenitSurface)
                                    .clipShape(Capsule())
                            }.buttonStyle(.plain)
                        }
                    }.padding(.horizontal, 20)
                }

                // Main Timer Ring
                ZStack {
                    // Track
                    Circle()
                        .stroke(Color.zenitBorder, lineWidth: 8)
                        .frame(width: 260, height: 260)

                    // Progress arc
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [.zenitAccent, .zenitAccent2, .zenitMint]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 260, height: 260)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: progress)

                    // Time display
                    VStack(spacing: 4) {
                        Text(store.timerDisplay())
                            .font(ZFont.monoLarge)
                            .foregroundColor(.zenitText)
                            .contentTransition(.numericText())
                        Text(store.timerLabel)
                            .font(ZFont.caption)
                            .foregroundColor(.zenitSubtext)
                            .textCase(.uppercase)
                            .tracking(2)
                    }
                }

                // Label edit
                HStack {
                    Image(systemName: "tag").foregroundColor(.zenitSubtext).font(.system(size: 14))
                    TextField("Session label", text: $store.timerLabel)
                        .font(ZFont.bodyMed).foregroundColor(.zenitText).tint(.zenitAccent)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20).padding(.vertical, 12)
                .background(Color.zenitSurface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.zenitBorder.opacity(0.5), lineWidth: 0.5))
                .frame(maxWidth: 280)

                // Controls
                HStack(spacing: 20) {
                    // Reset
                    Button { store.stopTimer() } label: {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.zenitSubtext)
                            .frame(width: 54, height: 54)
                            .background(Color.zenitSurface)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.zenitBorder.opacity(0.5), lineWidth: 0.5))
                    }.buttonStyle(.plain)

                    // Play / Pause
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            store.timerActive ? store.pauseTimer() : store.startTimer()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.zenitAccent, .zenitAccent2], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 80, height: 80)
                                .shadow(color: .zenitAccent.opacity(0.5), radius: 20, y: 10)
                            Image(systemName: store.timerActive ? "pause.fill" : "play.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                                .offset(x: store.timerActive ? 0 : 2)
                        }
                    }.buttonStyle(.plain)

                    // Skip
                    Button {
                        store.stopTimer()
                        let session = FocusSession(duration: (selectedDuration * 60) - store.timerSecondsLeft, label: store.timerLabel)
                        store.focusSessions.append(session)
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.zenitSubtext)
                            .frame(width: 54, height: 54)
                            .background(Color.zenitSurface)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.zenitBorder.opacity(0.5), lineWidth: 0.5))
                    }.buttonStyle(.plain)
                }

                // Sessions history strip
                if !store.focusSessions.isEmpty {
                    VStack(spacing: 12) {
                        ZSectionHeader("Recent sessions")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(store.focusSessions.suffix(5).reversed()) { s in
                                    VStack(spacing: 4) {
                                        Text("\(s.duration / 60)m")
                                            .font(ZFont.bodyMed).foregroundColor(.zenitText)
                                        Text(s.label.isEmpty ? "Focus" : s.label)
                                            .font(ZFont.micro).foregroundColor(.zenitSubtext)
                                    }
                                    .frame(width: 72)
                                    .glassCard(padding: 12)
                                }
                            }.padding(.horizontal, 20)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer(minLength: 120)
            }
        }
    }
}
