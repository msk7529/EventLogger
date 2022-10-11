//
//  LogConsoleTableSection.swift
//  EventLogger
//
//

import UIKit

enum LogConsoleTableSection: Int {
    case main
}

typealias LogConsoleTableViewSnapShot = NSDiffableDataSourceSnapshot<LogConsoleTableSection, LogConsoleMessage>
typealias LogConsoleTableViewDataSourceType = UITableViewDiffableDataSource<LogConsoleTableSection, LogConsoleMessage>

final class LogConsoleTableViewDataSource: LogConsoleTableViewDataSourceType {
    
    init(tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LogConsoleTableViewCell.identifier, for: indexPath) as? LogConsoleTableViewCell else {
                return UITableViewCell()
            }
            cell.message = itemIdentifier
            return cell
        }
    }
}
