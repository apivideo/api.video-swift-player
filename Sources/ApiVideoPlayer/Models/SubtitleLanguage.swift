import Foundation

public struct SubtitleLanguage: Equatable {
    public let language: String
    public let code: String?

    init(language: String, code: String?) {
        self.language = language
        self.code = code
    }

    public static func == (lhs: SubtitleLanguage, rhs: SubtitleLanguage) -> Bool {
        (lhs.language == rhs.language) && (lhs.code == rhs.code)
    }
}
