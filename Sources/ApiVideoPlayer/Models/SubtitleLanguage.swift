import Foundation

/// Represents a subtitle language.
/// There are used by ``ApiVideoPlayerView`` to list the subtitles languages.
struct SubtitleLanguage: Equatable {
    let language: String
    let code: String?

    /// The language is not set.
    static let off: SubtitleLanguage = .init(language: "Off", code: nil)

    /// Initializes a subtitle language.
    init(language: String, code: String?) {
        self.language = language
        self.code = code
    }

    static func == (lhs: SubtitleLanguage, rhs: SubtitleLanguage) -> Bool {
        (lhs.language == rhs.language) && (lhs.code == rhs.code)
    }

    /// Converts the language code to a Locale object.
    func toLocale() -> Locale? {
        if let code = code {
            return Locale(identifier: code)
        } else {
            return nil
        }
    }
}
