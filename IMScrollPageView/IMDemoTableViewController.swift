//
//  IMDemoTableViewController.swift
//  IMScrollPageView
//
//  Created by Mazy on 2019/7/26.
//  Copyright © 2019 Mazy. All rights reserved.
//

import UIKit

class IMDemoTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "IMScrollPageView"
        
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        let demoVC = ViewController()
        switch indexPath.row {
        case 0:
            demoVC.pageType = .scale_gradient
            self.navigationController?.show(demoVC, sender: nil)
        case 1:
            demoVC.pageType = .cover_gradient
            self.navigationController?.show(demoVC, sender: nil)
        case 2:
            demoVC.pageType = .scrollbar_gradient
            self.navigationController?.show(demoVC, sender: nil)
        case 3:
            demoVC.pageType = .cover_scale_no_gradient
            self.navigationController?.show(demoVC, sender: nil)
        default:
            break
        }
    }
}
