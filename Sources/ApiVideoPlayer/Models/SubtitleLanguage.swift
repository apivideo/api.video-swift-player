import Foundation

public struct SubtitleLanguage: Equatable {
    public let language: String
    public let code: String?

    public static let off: SubtitleLanguage = .init(language: "Off", code: nil)

    init(language: String, code: String?) {
        self.language = language
        self.code = code
    }

    public static func == (lhs: SubtitleLanguage, rhs: SubtitleLanguage) -> Bool {
        (lhs.language == rhs.language) && (lhs.code == rhs.code)
    }

    /// Converts the language code to a Locale object.
    public func toLocale() -> Locale? {
        if let code = code {
            return Locale(identifier: code)
        } else {
            return nil
        }
    }
}
