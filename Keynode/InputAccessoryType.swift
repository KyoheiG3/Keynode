//
//  InputAccessoryType.swift
//  Keynode
//
//  Created by Kyohei Ito on 2017/11/23.
//  Copyright © 2017年 kyohei_ito. All rights reserved.
//

protocol InputAccessoryType: class {
    var inputAccessoryView: UIView? { get set }
}

extension UITextView: InputAccessoryType {}
extension UITextField: InputAccessoryType {}
