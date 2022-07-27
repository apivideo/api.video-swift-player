#if !os(macOS)
    import AVFoundation
    import Foundation
    import UIKit

    @available(iOS 14.0, *)
    class SubtitleView: UIView, UITableViewDelegate, UITableViewDataSource {
        private var selectedRow = 0
        private var subtitles: [Subtitle] = []
        private var tableview = UITableView()
        private let cellReuseIdentifier = "cell"
        private let playerController: PlayerController

        public init(frame: CGRect, playerController: PlayerController) {
            self.playerController = playerController
            super.init(frame: frame)
            subtitles = playerController.getSubtitlesFromVideo()

            layer.cornerRadius = 15
            tableview.layer.cornerRadius = 15
            if subtitles.count < 3 {
                var posY = frame.origin.y
                if subtitles.count > 1 {
                    posY = posY - 25 * CGFloat(subtitles.count)
                }
                self.frame = CGRect(x: frame.origin.x, y: posY, width: frame.width, height: 45 * CGFloat(subtitles.count))
                tableview.frame = CGRect(x: 0, y: 0, width: frame.width, height: 45 * CGFloat(subtitles.count))
            } else {
                self.frame = CGRect(x: frame.origin.x, y: frame.origin.y - 90, width: frame.width, height: frame.height)
                tableview.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            }
            tableview.delegate = self
            tableview.dataSource = self
            tableview.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
            addSubview(tableview)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        public func dismissView() {
            if let viewWithTag = viewWithTag(101) {
                viewWithTag.removeFromSuperview()
            } else {
                print("something went wrong when removing the view")
                return
            }
        }

        private func unselectPreviousLanguages() {
            for var subtitle in subtitles {
                subtitle.isSelected = false
            }
        }

        // MARK: TableView

        func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
            subtitles.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as UITableViewCell
            var content = cell.defaultContentConfiguration()
            content.text = subtitles[indexPath.item].language
            if subtitles[indexPath.row].isSelected {
                cell.accessoryType = .checkmark
            }
            cell.contentConfiguration = content
            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: false)

            let selectedSubtitleRow = subtitles[indexPath.row]

            if selectedSubtitleRow.isSelected {
                return
            }
            if let previousCell = tableView.cellForRow(at: IndexPath(row: selectedRow, section: indexPath.section)) {
                subtitles[selectedRow].isSelected.toggle()
                previousCell.accessoryType = .none
            }
            if let cell = tableView.cellForRow(at: indexPath) {
                subtitles[indexPath.row].isSelected.toggle()
                cell.accessoryType = .checkmark
            }

            selectedRow = indexPath.row
            if let language = subtitles[indexPath.row].code {
                playerController.selectSubtitle(language)
            } else {
                playerController.hideSubtitle()
            }
            dismissView()
        }
    }
#endif
