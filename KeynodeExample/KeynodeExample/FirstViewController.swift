//
//  FirstViewController.swift
//  KeynodeExample
//
//  Created by Kyohei Ito on 2014/12/14.
//  Copyright (c) 2014年 kyohei_ito. All rights reserved.
//

import UIKit
import Keynode

class FirstViewController: UIViewController {
    let tableSourceList: [[String]] = [[Int](1...20).map{ "cell \($0)" }]
    
    @IBOutlet weak var toolbar: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbarBottomSpaceConstraint: NSLayoutConstraint!
    lazy var keynode: Keynode.Connector = Keynode.Connector(view: self.tableView)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        keynode.defaultInsetBottom = toolbar.bounds.height
        keynode.willAnimationHandler = { [weak self] show, rect in
            if let me = self {
                me.toolbarBottomSpaceConstraint.constant = show ? rect.size.height : 0
            }
        }
        
        keynode.animationsHandler = { [weak self] show, rect in
            if let me = self {
                me.toolbarBottomSpaceConstraint.constant = max(me.tableView.bounds.height - rect.origin.y, 0)
                me.view.layoutIfNeeded()
            }
        }
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
}

extension FirstViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableSourceList.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSourceList[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = tableSourceList[indexPath.section][indexPath.row]
        
        return cell
    }
}