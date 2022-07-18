import Foundation
struct Subtitle {
    public var language: String
    public var code: String?
    public var isSelected: Bool

    init(language: String, code: String?, isSelected: Bool = false) {
        self.language = language
        self.code = code
        self.isSelected = isSelected
    }
}
