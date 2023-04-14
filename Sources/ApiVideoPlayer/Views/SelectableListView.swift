#if !os(macOS)
import AVFoundation
import Foundation
import UIKit

class SelectableListView<T: Equatable>: UIView, UITableViewDataSource, UITableViewDelegate {
    private var tableview = UITableView()
    private let cellReuseIdentifier = "CellWithTextField"

    private let listAny: [T]
    private var selectedAny: T?

    public weak var delegate: SelectableViewDelegate?

    public init(frame: CGRect, list: [T], selectedElement: T?) {

        self.listAny = list
        self.selectedAny = selectedElement
        super.init(frame: frame)
        if let sub = self.selectedAny as? SubtitleLanguage {
            print(sub.language)
        }

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

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        listAny.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(
            withIdentifier: cellReuseIdentifier,
            for: indexPath
        )

        let rowElement = listAny[indexPath.row]

        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            // do if T is Float
            if let rowElementIsFloat = rowElement as? Float {
                content.text = rowElementIsFloat.description
            }
            // do if T is Locale
            if let rowElementIsFloat = rowElement as? SubtitleLanguage {
                content.text = rowElementIsFloat.language
            }
            cell.contentConfiguration = content
        } else {
            if let rowElementIsFloat = rowElement as? Float {
                cell.textLabel?.text = rowElementIsFloat.description
            }
            // do if T is SubtitleLanguage
            if let rowElementIsFloat = rowElement as? SubtitleLanguage {
                cell.textLabel?.text = rowElementIsFloat.language
            }
        }

        if let notOptionaleSelectedAny = selectedAny {
            if type(of: rowElement) == type(of: notOptionaleSelectedAny) {
                if rowElement == notOptionaleSelectedAny {
                    cell.accessoryType = .checkmark
                }
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let selectedRowElement = listAny[indexPath.row]
        if selectedRowElement != selectedAny {
            // Uncheck previous selected element
            if let selected = selectedAny {
                if let previousSelectedElementIndex = getRowForElement(selected) {
                    if let previousCell = tableView
                        .cellForRow(at: IndexPath(row: previousSelectedElementIndex, section: indexPath.section))
                    {
                        previousCell.accessoryType = .none
                    }
                }
            }
            selectedAny = selectedRowElement
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
            }
        }

        if let selectedRowIsSubtitle = selectedRowElement as? SubtitleLanguage {
            delegate?.newElementSelected(element: selectedRowIsSubtitle.toLocale())
        } else {
            delegate?.newElementSelected(element: selectedRowElement)
        }

    }

    private func getRowForElement(_ element: T) -> Int? {
        listAny.firstIndex(of: element)
    }

    private func convertToString<T: LosslessStringConvertible>(value: T) -> String {
        return String(value)
    }

}

public protocol SelectableViewDelegate: AnyObject {
    func newElementSelected(element: Any)
}
#endif
