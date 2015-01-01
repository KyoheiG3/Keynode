//
//  ViewController.swift
//  KeynodeExample
//
//  Created by Kyohei Ito on 2014/12/11.
//  Copyright (c) 2014年 kyohei_ito. All rights reserved.
//

import UIKit
import Keynode

class ViewController: UIViewController, Keynode.ControllerDelegate {
    let tableSourceList: [[String]] = [[Int](0..<20).map{ "cell \($0)" }]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbar: UIView!
    @IBOutlet weak var toolbarBottomSpaceConstraint: NSLayoutConstraint!
    lazy var keynode: Controller = Controller(view: self.tableView)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        keynode.defaultInsetBottom = toolbar.bounds.height
        keynode.willAnimationHandler = { [weak self] show, keyboardRect in
            if let me = self {
                me.toolbarBottomSpaceConstraint.constant = show ? keyboardRect.size.height : 0
            }
        }
        
        keynode.animationsHandler = { [weak self] show, keyboardRect in
            if let me = self {
                me.toolbarBottomSpaceConstraint.constant = me.view.bounds.height - keyboardRect.origin.y
                me.view.layoutIfNeeded()
            }
        }
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
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