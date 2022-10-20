import Foundation

struct SubtitleLanguage {
    public var language: String
    public var code: String?

    init(language: String, code: String?) {
        self.language = language
        self.code = code
    }
}
