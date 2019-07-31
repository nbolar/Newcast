//
//  DetailVC.swift
//  Newcast
//
//  Created by Nikhil Bolar on 7/31/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa

class DetailVC: NSViewController {

    @IBOutlet weak var backgroundImageView: NSImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        backgroundImageView.alphaValue = 0.6
    }
    
}
