//
//  RespondButton.swift
//  KeynodeExample
//
//  Created by Kyohei Ito on 2015/01/30.
//  Copyright (c) 2015年 kyohei_ito. All rights reserved.
//

import UIKit

class RespondButton: UIButton {
    let contents = [1, 2, 3, 4, 5]
    
    lazy private var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = UIColor.whiteColor()
        picker.delegate = self
        picker.dataSource = self
        return picker
        }()
    
    lazy private var accessoryToolbar: UIView = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .Default
        toolbar.sizeToFit()
        toolbar.frame.size.height = 44
        
        let button = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "buttonAction:")
        let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        toolbar.items = [spacer, button]
        return toolbar
        }()
    
    func buttonAction(sender: AnyObject) {
        self.resignFirstResponder()
    }
    
    override var inputView: UIView? {
        return pickerView
    }
    
    override var inputAccessoryView: UIView? {
        return accessoryToolbar
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        return super.becomeFirstResponder()
    }
}

extension RespondButton: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return contents.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        return String(contents[row])
    }
}

