import SwiftUI

enum AppTheme {
    // Primary accent - dark blue-green/teal
    static let accent = Color(red: 0.2, green: 0.45, blue: 0.5)

    // Lighter tint for backgrounds
    static let accentLight = Color(red: 0.2, green: 0.45, blue: 0.5).opacity(0.1)

    // Border color
    static let accentBorder = Color(red: 0.2, green: 0.45, blue: 0.5).opacity(0.5)

    // Secondary grey tones
    static let secondary = Color.gray
    static let secondaryLight = Color.gray.opacity(0.1)
    static let secondaryBorder = Color.gray.opacity(0.4)

    // Compass arrow color
    static let compass = Color(red: 0.2, green: 0.45, blue: 0.5)

    // Success/arrival - mint green #3DB489
    static let success = Color(red: 0.24, green: 0.71, blue: 0.54)
    static let successLight = Color(red: 0.24, green: 0.71, blue: 0.54).opacity(0.1)
    static let successBorder = Color(red: 0.24, green: 0.71, blue: 0.54).opacity(0.5)

    // Info/hints - cobalt blue #1338BE
    static let info = Color(red: 0.07, green: 0.22, blue: 0.75)
    static let infoLight = Color(red: 0.07, green: 0.22, blue: 0.75).opacity(0.1)
    static let infoBorder = Color(red: 0.07, green: 0.22, blue: 0.75).opacity(0.5)
}
