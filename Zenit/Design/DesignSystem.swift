import SwiftUI

// MARK: - Color Palette
extension Color {
    static let zenitBlack    = Color(hex: "0A0A0F")   // near-black with violet tint
    static let zenitSurface  = Color(hex: "12121A")   // card surface
    static let zenitElevated = Color(hex: "1C1C28")   // elevated cards
    static let zenitBorder   = Color(hex: "2A2A3C")   // subtle borders
    static let zenitAccent   = Color(hex: "7C6AF7")   // electric violet
    static let zenitAccent2  = Color(hex: "A855F7")   // vivid purple
    static let zenitMint     = Color(hex: "34D399")   // emerald
    static let zenitRose     = Color(hex: "F87171")   // soft red
    static let zenitGold     = Color(hex: "FBBF24")   // amber
    static let zenitSky      = Color(hex: "38BDF8")   // sky blue
    static let zenitText     = Color(hex: "F0EDFF")   // near-white with warmth
    static let zenitSubtext  = Color(hex: "7B7A9A")   // muted lavender

    init(hex: String) {
        let r, g, b: Double
        let start = hex.hasPrefix("#") ? hex.index(hex.startIndex, offsetBy: 1) : hex.startIndex
        let hexColor = String(hex[start...])
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        scanner.scanHexInt64(&hexNumber)
        r = Double((hexNumber & 0xff0000) >> 16) / 255
        g = Double((hexNumber & 0x00ff00) >> 8)  / 255
        b = Double( hexNumber & 0x0000ff)         / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Typography
struct ZFont {
    // Display
    static let hero       = Font.system(size: 48, weight: .black, design: .rounded)
    static let title1     = Font.system(size: 32, weight: .bold,  design: .rounded)
    static let title2     = Font.system(size: 24, weight: .bold,  design: .rounded)
    static let title3     = Font.system(size: 20, weight: .semibold, design: .rounded)
    // Body
    static let body       = Font.system(size: 16, weight: .regular, design: .rounded)
    static let bodyMed    = Font.system(size: 16, weight: .medium,  design: .rounded)
    static let bodySemi   = Font.system(size: 16, weight: .semibold, design: .rounded)
    // Small
    static let caption    = Font.system(size: 13, weight: .medium,  design: .rounded)
    static let micro      = Font.system(size: 11, weight: .semibold, design: .rounded)
    // Mono (for timer)
    static let monoLarge  = Font.system(size: 72, weight: .thin, design: .monospaced)
    static let monoMed    = Font.system(size: 28, weight: .light, design: .monospaced)
}

// MARK: - Glass Card
struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    Color.zenitSurface
                    Color.zenitAccent.opacity(0.03)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.zenitAccent.opacity(0.4), Color.zenitBorder.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.6
                    )
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20, padding: CGFloat = 20) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, padding: padding))
    }
}

// MARK: - Glowing Capsule Button
struct GlowButton: View {
    let title: String
    let icon: String?
    let color: Color
    let action: () -> Void
    @State private var pressed = false

    init(_ title: String, icon: String? = nil, color: Color = .zenitAccent, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) { pressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) { pressed = false }
            }
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(title)
                    .font(ZFont.bodySemi)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    color
                    color.opacity(0.5).blur(radius: 16).offset(y: 6)
                }
            )
            .clipShape(Capsule())
            .shadow(color: color.opacity(0.55), radius: pressed ? 4 : 16, x: 0, y: pressed ? 2 : 8)
            .scaleEffect(pressed ? 0.94 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Custom Tab Bar
struct ZenitTabBar: View {
    @Binding var selectedTab: Int

    private let items: [(icon: String, label: String)] = [
        ("house.fill",        "Home"),
        ("checkmark.square.fill", "Tasks"),
        ("timer",             "Focus"),
        ("book.closed.fill",  "Journal"),
        ("chart.bar.fill",    "Insights")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<items.count, id: \.self) { i in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedTab = i
                    }
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            if selectedTab == i {
                                Capsule()
                                    .fill(Color.zenitAccent.opacity(0.18))
                                    .frame(width: 48, height: 32)
                            }
                            Image(systemName: items[i].icon)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(selectedTab == i ? .zenitAccent : .zenitSubtext)
                                .scaleEffect(selectedTab == i ? 1.1 : 1.0)
                                .symbolEffect(.bounce, value: selectedTab == i)
                        }
                        Text(items[i].label)
                            .font(ZFont.micro)
                            .foregroundColor(selectedTab == i ? .zenitAccent : .zenitSubtext)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            ZStack {
                Color.zenitSurface.opacity(0.92)
                Color.zenitAccent.opacity(0.04)
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.zenitBorder.opacity(0.5), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.4), radius: 24, y: -4)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Animated Gradient Orb Background
struct OrbBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Color.zenitBlack.ignoresSafeArea()

            // Orb 1 - violet
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color.zenitAccent.opacity(0.35), .clear],
                        center: .center, startRadius: 0, endRadius: 200
                    )
                )
                .frame(width: 380, height: 380)
                .offset(x: animate ? -60 : -100, y: animate ? -200 : -160)
                .blur(radius: 60)
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animate)

            // Orb 2 - rose
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color.zenitRose.opacity(0.18), .clear],
                        center: .center, startRadius: 0, endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: animate ? 120 : 80, y: animate ? 300 : 260)
                .blur(radius: 50)
                .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animate)

            // Orb 3 - mint
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color.zenitMint.opacity(0.12), .clear],
                        center: .center, startRadius: 0, endRadius: 120
                    )
                )
                .frame(width: 250, height: 250)
                .offset(x: animate ? 150 : 110, y: animate ? -80 : -120)
                .blur(radius: 45)
                .animation(.easeInOut(duration: 7).repeatForever(autoreverses: true), value: animate)
        }
        .onAppear { animate = true }
    }
}

// MARK: - Section Header
struct ZSectionHeader: View {
    let title: String
    let subtitle: String?
    let trailingLabel: String?
    let trailingAction: (() -> Void)?

    init(_ title: String, subtitle: String? = nil, trailing: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.trailingLabel = trailing
        self.trailingAction = action
    }

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(ZFont.title3)
                    .foregroundColor(.zenitText)
                if let sub = subtitle {
                    Text(sub)
                        .font(ZFont.caption)
                        .foregroundColor(.zenitSubtext)
                }
            }
            Spacer()
            if let label = trailingLabel {
                Button { trailingAction?() } label: {
                    Text(label)
                        .font(ZFont.caption)
                        .foregroundColor(.zenitAccent)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
