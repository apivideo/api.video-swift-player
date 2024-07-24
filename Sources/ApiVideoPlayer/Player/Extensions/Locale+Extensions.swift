import Foundation

extension Locale {
    /// Returns the language code of the locale.
    func toSubtitleLanguage() -> SubtitleLanguage {
        SubtitleLanguage(
            language: localizedString(forIdentifier: identifier) ?? "Unknown",
            code: languageCode
        )
    }
}
