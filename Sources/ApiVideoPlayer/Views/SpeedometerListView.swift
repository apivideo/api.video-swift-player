#if !os(macOS)
import AVFoundation
import Foundation
import UIKit

class SpeedometerListView: UIView {
    private var tableview = UITableView()
    private let cellReuseIdentifier = "CellWithTextField"

    private let speeds = [0.5, 1.0, 1.25, 1.5, 2.0]
    private var selectedSpeed: Double

    public weak var delegate: SpeedometerViewDelegate?

    public init(frame: CGRect, selectedSpeed: Double?) {

        self.selectedSpeed = selectedSpeed ?? 1.0

        super.init(frame: frame)

        layer.cornerRadius = 15
        tableview.layer.cornerRadius = 15

        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y - 90, width: frame.width, height: frame.height)
        tableview.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)

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

extension SpeedometerListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        speeds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(
            withIdentifier: cellReuseIdentifier,
            for: indexPath
        )

        let rowLanguage = speeds[indexPath.row]

        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = rowLanguage.description
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = rowLanguage.description
        }

        if rowLanguage == selectedSpeed {
            cell.accessoryType = .checkmark
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let selectedRowSpeed = speeds[indexPath.row]

        if selectedRowSpeed != selectedSpeed {
            // Uncheck previous selected speed
            if let previousSelectedSpeedIndex = getRowForSpeed(selectedSpeed) {
                if let previousCell = tableView
                    .cellForRow(at: IndexPath(row: previousSelectedSpeedIndex, section: indexPath.section))
                {
                    previousCell.accessoryType = .none
                }
            }

            selectedSpeed = selectedRowSpeed
            // Check new selected speed
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
            }
        }

        delegate?.speedSelected(speed: selectedRowSpeed)
    }

    private func getRowForSpeed(_ speed: Double) -> Int? {
        speeds.firstIndex(of: speed)
    }
}

public protocol SpeedometerViewDelegate: AnyObject {
    func speedSelected(speed: Double?)
}
#endif
