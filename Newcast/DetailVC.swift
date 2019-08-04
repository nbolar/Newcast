//
//  DetailVC.swift
//  Newcast
//
//  Created by Nikhil Bolar on 7/31/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa

class DetailVC: NSViewController {

    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var playerCustomView: NSView!
    @IBOutlet weak var backgroundImageView: NSImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        collectionView.wantsLayer = true
        collectionView.layer?.borderColor = CGColor.init(gray: 0.9, alpha: 0.2)
        collectionView.layer?.borderWidth = 2
        collectionView.layer?.cornerRadius = 8
        backgroundImageView.alphaValue = 0.6
        playerCustomView.wantsLayer = true
        playerCustomView.layer?.backgroundColor = CGColor.init(gray: 0.9, alpha: 0.2)
        playerCustomView.layer?.cornerRadius = 8
    }
    
}
