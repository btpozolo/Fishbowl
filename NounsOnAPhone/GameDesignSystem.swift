import SwiftUI

// MARK: - Design Tokens
struct GameDesignTokens {
    // Colors
    static let primaryColor = Color.blue
    static let successColor = Color.green
    static let warningColor = Color.orange
    static let dangerColor = Color.red
    static let secondaryColor = Color.gray
    
    // Spacing
    static let cornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 12
    static let largeCornerRadius: CGFloat = 20
    
    // Padding
    static let buttonPadding: CGFloat = 16
    static let smallButtonPadding: CGFloat = 12
    static let largeButtonPadding: CGFloat = 20
    
    // Shadows
    static let shadowRadius: CGFloat = 8
    static let shadowOpacity: Double = 0.3
    
    // Animations
    static let animationDuration: Double = 0.3
    static let springAnimation = Animation.spring(response: 0.6, dampingFraction: 0.8)
}

// MARK: - Button Styles
enum GameButtonStyle {
    case primary
    case secondary
    case success
    case danger
    case disabled
    
    var colors: (primary: Color, secondary: Color) {
        switch self {
        case .primary:
            return (GameDesignTokens.primaryColor, GameDesignTokens.primaryColor.opacity(0.8))
        case .secondary:
            return (GameDesignTokens.secondaryColor, GameDesignTokens.secondaryColor.opacity(0.8))
        case .success:
            return (GameDesignTokens.successColor, GameDesignTokens.successColor.opacity(0.8))
        case .danger:
            return (GameDesignTokens.dangerColor, GameDesignTokens.dangerColor.opacity(0.8))
        case .disabled:
            return (GameDesignTokens.secondaryColor, GameDesignTokens.secondaryColor.opacity(0.8))
        }
    }
    
    var shadowColor: Color {
        switch self {
        case .primary:
            return GameDesignTokens.primaryColor.opacity(GameDesignTokens.shadowOpacity)
        case .secondary:
            return GameDesignTokens.secondaryColor.opacity(GameDesignTokens.shadowOpacity)
        case .success:
            return GameDesignTokens.successColor.opacity(GameDesignTokens.shadowOpacity)
        case .danger:
            return GameDesignTokens.dangerColor.opacity(GameDesignTokens.shadowOpacity)
        case .disabled:
            return GameDesignTokens.secondaryColor.opacity(GameDesignTokens.shadowOpacity)
        }
    }
    
    var isEnabled: Bool {
        return self != .disabled
    }
}

// MARK: - Reusable Button Components
struct GameButton: View {
    let title: String
    let icon: String?
    let style: GameButtonStyle
    let size: ButtonSize
    let action: () -> Void
    
    init(
        title: String,
        icon: String? = nil,
        style: GameButtonStyle = .primary,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: size.iconSpacing) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(size.iconFont)
                }
                Text(title)
                    .font(size.textFont)
                    .fontWeight(size.fontWeight)
            }
            .foregroundColor(.white)
            .frame(maxWidth: size.maxWidth)
            .padding(.vertical, size.verticalPadding)
            .padding(.horizontal, size.horizontalPadding)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [style.colors.primary, style.colors.secondary]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(size.cornerRadius)
            .shadow(color: style.shadowColor, radius: GameDesignTokens.shadowRadius, x: 0, y: 4)
        }
        .disabled(!style.isEnabled)
        .scaleEffect(style.isEnabled ? 1.0 : 0.98)
        .animation(GameDesignTokens.springAnimation, value: style.isEnabled)
    }
}

// MARK: - Button Sizes
enum ButtonSize {
    case small
    case medium
    case large
    
    var textFont: Font {
        switch self {
        case .small:
            return .headline
        case .medium:
            return .title3
        case .large:
            return .title2
        }
    }
    
    var iconFont: Font {
        switch self {
        case .small:
            return .title3
        case .medium:
            return .title2
        case .large:
            return .title
        }
    }
    
    var fontWeight: Font.Weight {
        switch self {
        case .small:
            return .medium
        case .medium:
            return .semibold
        case .large:
            return .semibold
        }
    }
    
    var verticalPadding: CGFloat {
        switch self {
        case .small:
            return GameDesignTokens.smallButtonPadding
        case .medium:
            return GameDesignTokens.buttonPadding
        case .large:
            return GameDesignTokens.largeButtonPadding
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small:
            return 16
        case .medium:
            return 20
        case .large:
            return 24
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .small:
            return GameDesignTokens.smallCornerRadius
        case .medium:
            return GameDesignTokens.cornerRadius
        case .large:
            return GameDesignTokens.largeCornerRadius
        }
    }
    
    var iconSpacing: CGFloat {
        switch self {
        case .small:
            return 8
        case .medium:
            return 12
        case .large:
            return 16
        }
    }
    
    var maxWidth: CGFloat? {
        switch self {
        case .small:
            return nil
        case .medium:
            return nil
        case .large:
            return .infinity
        }
    }
}

// MARK: - Convenience Button Creators
extension GameButton {
    // Primary action buttons
    static func primary(
        title: String,
        icon: String? = nil,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) -> GameButton {
        GameButton(title: title, icon: icon, style: .primary, size: size, action: action)
    }
    
    // Success/confirmation buttons
    static func success(
        title: String,
        icon: String? = nil,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) -> GameButton {
        GameButton(title: title, icon: icon, style: .success, size: size, action: action)
    }
    
    // Secondary/alternative buttons
    static func secondary(
        title: String,
        icon: String? = nil,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) -> GameButton {
        GameButton(title: title, icon: icon, style: .secondary, size: size, action: action)
    }
    
    // Danger/destructive buttons
    static func danger(
        title: String,
        icon: String? = nil,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) -> GameButton {
        GameButton(title: title, icon: icon, style: .danger, size: size, action: action)
    }
    
    // Disabled buttons
    static func disabled(
        title: String,
        icon: String? = nil,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) -> GameButton {
        GameButton(title: title, icon: icon, style: .disabled, size: size, action: action)
    }
}

// MARK: - View Modifiers for Consistent Styling
struct GameButtonModifier: ViewModifier {
    let style: GameButtonStyle
    let size: ButtonSize
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .frame(maxWidth: size.maxWidth)
            .padding(.vertical, size.verticalPadding)
            .padding(.horizontal, size.horizontalPadding)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [style.colors.primary, style.colors.secondary]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(size.cornerRadius)
            .shadow(color: style.shadowColor, radius: GameDesignTokens.shadowRadius, x: 0, y: 4)
    }
}

extension View {
    func gameButtonStyle(_ style: GameButtonStyle, size: ButtonSize = .medium) -> some View {
        modifier(GameButtonModifier(style: style, size: size))
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        GameButton.primary(title: "Start Game", icon: "play.circle.fill", size: .large) {
            print("Primary button tapped")
        }
        
        GameButton.success(title: "Correct!", icon: "checkmark.circle.fill") {
            print("Success button tapped")
        }
        
        GameButton.secondary(title: "Add Sample Words", icon: "wand.and.stars") {
            print("Secondary button tapped")
        }
        
        GameButton.danger(title: "Reset Game", icon: "trash") {
            print("Danger button tapped")
        }
        
        GameButton.disabled(title: "Disabled Button", icon: "lock") {
            print("Disabled button tapped")
        }
    }
    .padding()
} 