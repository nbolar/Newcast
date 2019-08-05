//
//  DetailVC.swift
//  Newcast
//
//  Created by Nikhil Bolar on 7/31/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa

var podcastSelecetedIndex : Int!

class DetailVC: NSViewController {

    @IBOutlet weak var podcastTitleField: NSTextField!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var playerCustomView: NSView!
    @IBOutlet weak var backgroundImageView: NSImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.wantsLayer = true
        collectionView.layer?.cornerRadius = 8
        backgroundImageView.alphaValue = 0.6
        playerCustomView.wantsLayer = true
        playerCustomView.layer?.backgroundColor = CGColor.init(gray: 0.9, alpha: 0.2)
        playerCustomView.layer?.cornerRadius = 8
        podcastTitleField.stringValue = ""
        NotificationCenter.default.addObserver(self, selector: #selector(updateTitle), name: NSNotification.Name(rawValue: "updateTitle"), object: nil)
    }
    
    func highlightItems(selected: Bool, atIndexPaths: Set<NSIndexPath>) {
        for indexPath in atIndexPaths {
            guard let item = collectionView.item(at: indexPath as IndexPath) else {continue}
            (item as! EpisodeCellView).setHighlight(selected: selected)
            
        }
    }
    @objc func updateTitle(){
        podcastTitleField.stringValue = "\(podcastsTitle[podcastSelecetedIndex])"
    }
    
}

extension DetailVC: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let forecastItem = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "EpisodeCellView"), for: indexPath)
        
        //        guard let forecastCell = forecastItem as? PodcastCellView else { return forecastItem}
        //        forecastCell.configureCell(weatherCell: WeatherService.instance.forecast[indexPath.item])
        
        
        return forecastItem
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: 680, height: 150)
    }
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        highlightItems(selected: true, atIndexPaths: indexPaths as Set<NSIndexPath>)
    }
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        highlightItems(selected: false, atIndexPaths: indexPaths as Set<NSIndexPath>)
    }
    
}
