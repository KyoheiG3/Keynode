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
    
    lazy fileprivate var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = UIColor.white
        picker.delegate = self
        picker.dataSource = self
        return picker
        }()
    
    lazy fileprivate var accessoryToolbar: UIView = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.sizeToFit()
        toolbar.frame.size.height = 44
        
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(RespondButton.buttonAction(_:)))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [spacer, button]
        return toolbar
        }()
    
    func buttonAction(_ sender: AnyObject) {
        self.resignFirstResponder()
    }
    
    override var inputView: UIView? {
        return pickerView
    }
    
    override var inputAccessoryView: UIView? {
        return accessoryToolbar
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        return super.becomeFirstResponder()
    }
}

extension RespondButton: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return contents.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(contents[row])
    }
}

