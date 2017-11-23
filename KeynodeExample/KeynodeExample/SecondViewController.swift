//
//  SecondViewController.swift
//  KeynodeExample
//
//  Created by Kyohei Ito on 2014/12/14.
//  Copyright (c) 2014年 kyohei_ito. All rights reserved.
//

import UIKit
import Keynode

class SecondViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    var keynode: Keynode!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        keynode = Keynode(view: textView)
    }
}
