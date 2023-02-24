#if !os(macOS)
import AVFoundation
import Foundation
import UIKit

class SubtitleListView: UIView {
    private var tableview = UITableView()
    private let cellReuseIdentifier = "CellWithTextField"

    private var languages: [SubtitleLanguage] = []
    private var selectedLanguage: SubtitleLanguage

    public weak var delegate: SubtitleViewDelegate?

    public init(frame: CGRect, languages: [SubtitleLanguage], selectedLanguage: SubtitleLanguage) {
        self.languages = languages
        self.selectedLanguage = selectedLanguage
        super.init(frame: frame)

        layer.cornerRadius = 15
        tableview.layer.cornerRadius = 15

        if self.languages.count < 3 {
            var posY = frame.origin.y
            if self.languages.count > 1 {
                posY -= 25 * CGFloat(self.languages.count)
            }
            self.frame = CGRect(
                    x: frame.origin.x,
                    y: posY,
                    width: frame.width,
                    height: 45 * CGFloat(self.languages.count)
            )
            tableview.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: frame.width,
                    height: 45 * CGFloat(self.languages.count)
            )
        } else {
            self.frame = CGRect(x: frame.origin.x, y: frame.origin.y - 90, width: frame.width, height: frame.height)
            tableview.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        }

        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        addSubview(tableview)
        bringSubviewToFront(tableview)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: TableView
extension SubtitleListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        languages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(
                withIdentifier: cellReuseIdentifier,
                for: indexPath
        )

        let rowLanguage = languages[indexPath.row]

        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = rowLanguage.language
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = rowLanguage.language
        }

        if rowLanguage == selectedLanguage {
            cell.accessoryType = .checkmark
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let selectedRowLanguage = languages[indexPath.row]

        if selectedRowLanguage == selectedLanguage {
            return
        }

        // Uncheck previous selected language
        if let previousSelectedLanguageIndex = getRowForLanguage(selectedLanguage) {
            if let previousCell = tableView.cellForRow(at: IndexPath(row: previousSelectedLanguageIndex, section: indexPath.section)) {
                previousCell.accessoryType = .none
            }
        }

        // Check new selected language
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }

        delegate?.languageSelected(language: selectedRowLanguage)

        removeFromSuperview()
    }

    private func getRowForLanguage(_ language: SubtitleLanguage) -> Int? {
        languages.firstIndex(of: selectedLanguage)
    }
}

public protocol SubtitleViewDelegate: AnyObject {
    func languageSelected(language: SubtitleLanguage)
}
#endif
