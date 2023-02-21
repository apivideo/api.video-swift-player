#if !os(macOS)
import AVFoundation
import Foundation
import UIKit

class SubtitleView: UIView, UITableViewDelegate, UITableViewDataSource {
    private var selectedRow = 0
    private var subtitles: [SubtitleLanguage] = []
    private var tableview = UITableView()
    private let cellReuseIdentifier = "cell"
    public var selectedLanguage: SubtitleLanguage? {
        didSet {
            self.tableview.reloadData()
        }
    }

    public weak var delegate: SubtitleViewDelegate?

    public init(frame: CGRect, _ languages: [SubtitleLanguage]) {
        self.subtitles = languages
        super.init(frame: frame)
        layer.cornerRadius = 15
        self.tableview.layer.cornerRadius = 15
        if self.subtitles.count < 3 {
            var posY = frame.origin.y
            if self.subtitles.count > 1 {
                posY -= 25 * CGFloat(self.subtitles.count)
            }
            self.frame = CGRect(
                x: frame.origin.x,
                y: posY,
                width: frame.width,
                height: 45 * CGFloat(self.subtitles.count)
            )
            self.tableview.frame = CGRect(
                x: 0,
                y: 0,
                width: frame.width,
                height: 45 * CGFloat(self.subtitles.count)
            )
        } else {
            self.frame = CGRect(x: frame.origin.x, y: frame.origin.y - 90, width: frame.width, height: frame.height)
            self.tableview.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        }
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.register(UITableViewCell.self, forCellReuseIdentifier: self.cellReuseIdentifier)
        addSubview(self.tableview)
        bringSubviewToFront(self.tableview)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func dismissView() {
        removeFromSuperview()
    }

    private func isCurrentSubtitleLanguage(subtitleLanguage: SubtitleLanguage) -> Bool {
        return self.selectedLanguage?.code == subtitleLanguage.code
    }

    // MARK: TableView

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        self.subtitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(
            withIdentifier: self.cellReuseIdentifier,
            for: indexPath
        ) as UITableViewCell
        let selectedSubtitleRow = self.subtitles[indexPath.row]
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = selectedSubtitleRow.language
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = selectedSubtitleRow.language
        }
        if self.isCurrentSubtitleLanguage(subtitleLanguage: selectedSubtitleRow) {
            cell.accessoryType = .checkmark
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let selectedSubtitleRow = self.subtitles[indexPath.row]

        if self.isCurrentSubtitleLanguage(subtitleLanguage: selectedSubtitleRow) {
            return
        }

        if let previousCell = tableView.cellForRow(at: IndexPath(row: selectedRow, section: indexPath.section)) {
            previousCell.accessoryType = .none
        }

        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }

        self.selectedRow = indexPath.row
        self.delegate?.languageSelected(language: selectedSubtitleRow)

        self.dismissView()
    }
}

public protocol SubtitleViewDelegate: AnyObject {
    func languageSelected(language: SubtitleLanguage)
}
#endif
