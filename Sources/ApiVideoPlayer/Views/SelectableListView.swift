#if !os(macOS)
import AVFoundation
import Foundation
import UIKit

class SelectableListView<T: Equatable & CustomStringConvertible>: UIView, UITableViewDataSource, UITableViewDelegate {
    private var tableview = UITableView()
    private let cellReuseIdentifier = "CellWithTextField"

    private let elements: [T]
    private var selectedElement: T

    public weak var delegate: SelectableListViewDelegate?

    public init(frame: CGRect, elements: [T], selectedElement: T) {
        self.elements = elements
        self.selectedElement = selectedElement
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

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        elements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(
            withIdentifier: cellReuseIdentifier,
            for: indexPath
        )

        let rowElement = elements[indexPath.row]

        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = String(describing: rowElement)
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = String(describing: rowElement)
        }

        if type(of: rowElement) == type(of: selectedElement) {
            if rowElement == selectedElement {
                cell.accessoryType = .checkmark
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let selectedRowElement = elements[indexPath.row]
        if selectedRowElement != selectedElement {
            // Uncheck previous selected element
            if let previousSelectedElementIndex = getRowForElement(selectedElement) {
                if let previousCell = tableView
                    .cellForRow(at: IndexPath(row: previousSelectedElementIndex, section: indexPath.section))
                {
                    previousCell.accessoryType = .none
                }
            }
            selectedElement = selectedRowElement
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
            }
        }

        delegate?.newElementSelected(view: self, element: selectedRowElement)
    }

    private func getRowForElement(_ element: T) -> Int? {
        elements.firstIndex(of: element)
    }
}

protocol SelectableListViewDelegate: AnyObject {
    func newElementSelected(
        view: SelectableListView<some Equatable & CustomStringConvertible>,
        element: some Equatable & CustomStringConvertible
    )
}
#endif
