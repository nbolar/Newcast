//
//  AlertVC.swift
//  Newcast
//
//  Created by Nikhil Bolar on 8/18/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa

class AlertVC: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        view.wantsLayer = true
        view.layer?.backgroundColor = .clear
        view.layer?.cornerRadius = 4
    }
    
}
