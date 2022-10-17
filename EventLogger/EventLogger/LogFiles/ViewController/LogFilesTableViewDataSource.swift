//
//  LogFilesTableSection.swift
//  EventLogger
//
//  Created on 2022/10/18.
//

import UIKit

enum LogFilesTableSection: Int {
    case main
}

typealias LogFilesTableViewSnapShot = NSDiffableDataSourceSnapshot<LogFilesTableSection, String>
typealias LogFilesTableSectionDataSourceType = UITableViewDiffableDataSource<LogFilesTableSection, String>

final class LogFilesTableViewDataSource: LogFilesTableSectionDataSourceType {
    
    init(tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LogFilesTableViewCell.identifier, for: indexPath) as? LogFilesTableViewCell else {
                return UITableViewCell()
            }
            cell.fileName = itemIdentifier
            return cell
        }
    }
}
