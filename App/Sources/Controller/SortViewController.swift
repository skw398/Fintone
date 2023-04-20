import UIKit

final class SortViewController: UITableViewController {
    var stocks: [Stock]!

    var rowDidMoveHandler: (@MainActor (_ sourceIndexPath: IndexPath, _ destinationIndexPath: IndexPath) -> Void)!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setEditing(true, animated: false)
    }
}

extension SortViewController {
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        stocks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SortTableViewCell", for: indexPath)
        cell.textLabel?.text = stocks[indexPath.row].symbol
        cell.detailTextLabel?.text = stocks[indexPath.row].name
        return cell
    }

    override func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }

    override func tableView(_: UITableView, shouldIndentWhileEditingRowAt _: IndexPath) -> Bool {
        false
    }

    override func tableView(_: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        rowDidMoveHandler(sourceIndexPath, destinationIndexPath)
    }
}
