import Foundation

public struct SubtitleLanguage {
    public let language: String
    public let code: String?

    init(language: String, code: String?) {
        self.language = language
        self.code = code
    }
}
