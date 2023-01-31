import Foundation

public protocol SubtitleViewDelegate: AnyObject {
    func languageSelected(language: SubtitleLanguage)
}
