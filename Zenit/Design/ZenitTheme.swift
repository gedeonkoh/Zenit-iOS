import SwiftUI

// ─────────────────────────────────────────────
//  ZENIT Design System — "Illegal Design" tier
// ─────────────────────────────────────────────

struct ZenitTheme {

    // MARK: – Typography
    struct Font {
        static let displayLarge  = SwiftUI.Font.system(size: 56, weight: .black,   design: .rounded)
        static let displayMedium = SwiftUI.Font.system(size: 36, weight: .bold,    design: .rounded)
        static let title         = SwiftUI.Font.system(size: 24, weight: .bold,    design: .rounded)
        static let headline      = SwiftUI.Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body          = SwiftUI.Font.system(size: 15, weight: .regular,  design: .rounded)
        static let caption       = SwiftUI.Font.system(size: 12, weight: .medium,   design: .rounded)
        static let mono          = SwiftUI.Font.system(size: 14, weight: .medium,   design: .monospaced)
    }

    // MARK: – Spacing
    struct Spacing {
        static let xs:  CGFloat = 4
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 24
        static let xl:  CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: – Corner Radius
    struct Radius {
        static let sm:   CGFloat = 12
        static let md:   CGFloat = 20
        static let lg:   CGFloat = 28
        static let pill: CGFloat = 999
    }

    // MARK: – Aura Palettes
    enum Aura: String, CaseIterable, Identifiable {
        case midnight, aurora, ember, sage, void
        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .midnight: return "Midnight"
            case .aurora:   return "Aurora"
            case .ember:    return "Ember"
            case .sage:     return "Sage"
            case .void:     return "Void"
            }
        }

        var accent: Color {
            switch self {
            case .midnight: return Color(hex: "6C6EF5")
            case .aurora:   return Color(hex: "00F5D4")
            case .ember:    return Color(hex: "FF6B35")
            case .sage:     return Color(hex: "7BC67E")
            case .void:     return Color(hex: "C77DFF")
            }
        }

        var secondary: Color {
            switch self {
            case .midnight: return Color(hex: "B76EFA")
            case .aurora:   return Color(hex: "0096C7")
            case .ember:    return Color(hex: "FFB347")
            case .sage:     return Color(hex: "52B788")
            case .void:     return Color(hex: "7B2FBE")
            }
        }

        var orb1: Color { accent.opacity(0.35) }
        var orb2: Color { secondary.opacity(0.22) }

        var gradient: LinearGradient {
            LinearGradient(
                colors: [accent, secondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        var icon: String {
            switch self {
            case .midnight: return "moon.stars.fill"
            case .aurora:   return "sparkles"
            case .ember:    return "flame.fill"
            case .sage:     return "leaf.fill"
            case .void:     return "circle.hexagongrid.fill"
            }
        }
    }

    // MARK: – Glass
    static let glassBorder  = Color.white.opacity(0.15)
    static let glassStroke: CGFloat = 1.0
    static let glassBg      = Color.white.opacity(0.08)
}

// MARK: – Color Hex init
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8)  & 0xFF) / 255
        let b = Double( rgb        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: – View Modifier: Glass Card
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = ZenitTheme.Radius.md
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(ZenitTheme.glassBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(ZenitTheme.glassBorder, lineWidth: ZenitTheme.glassStroke)
                    )
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = ZenitTheme.Radius.md) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}
