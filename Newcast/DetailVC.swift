//
//  DetailVC.swift
//  Newcast
//
//  Created by Nikhil Bolar on 7/31/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa
import SDWebImage

var podcastSelecetedIndex : Int!

class DetailVC: NSViewController {

    @IBOutlet weak var podcastImageView: SDAnimatedImageView!
    @IBOutlet weak var podcastTitleField: NSTextField!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var playerCustomView: NSView!
    @IBOutlet weak var backgroundImageView: NSImageView!
    let networkIndicator = NSProgressIndicator()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        networkIndicator.style = .spinning
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.wantsLayer = true
        collectionView.layer?.cornerRadius = 8
        backgroundImageView.alphaValue = 0.6
        playerCustomView.wantsLayer = true
        playerCustomView.layer?.backgroundColor = CGColor.init(gray: 0.9, alpha: 0.2)
        playerCustomView.layer?.cornerRadius = 8
        podcastImageView.image = nil
        podcastImageView.wantsLayer = true
        podcastImageView.layer?.cornerRadius = 8
        podcastImageView.alphaValue = 0.9
        podcastTitleField.stringValue = ""
        
        let labelXPostion:CGFloat = view.bounds.midX
        let labelYPostion:CGFloat = view.bounds.midY
        let labelWidth:CGFloat = 30
        let labelHeight:CGFloat = 30
        networkIndicator.frame = CGRect(x: labelXPostion, y: labelYPostion, width: labelWidth, height: labelHeight)
        collectionView.deselectAll(Any?.self)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTitle), name: NSNotification.Name(rawValue: "updateTitle"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateEpisodes), name: NSNotification.Name(rawValue: "updateEpisodes"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deletedPodcast), name: NSNotification.Name(rawValue: "deletedPodcast"), object: nil)
    }
    
    func highlightItems(selected: Bool, atIndexPaths: Set<NSIndexPath>) {
        for indexPath in atIndexPaths {
            guard let item = collectionView.item(at: indexPath as IndexPath) else {continue}
            (item as! EpisodeCellView).setHighlight(selected: selected)
            if selected == true{
                (item as! EpisodeCellView).showButton(atIndexPaths: indexPath.item)
            }
            if selected == false{
                (item as! EpisodeCellView).hideButton()
            }
            
        }
    }
    
    @objc func updateEpisodes(){
        
        collectionView.reloadData()
        networkIndicator.removeFromSuperview()
        collectionView.deselectAll(Any?.self)
        collectionView.reloadData()
    }
    @objc func updateTitle(){
//        podcastImageView.isHidden = false
        podcastTitleField.stringValue = "\(podcastsTitle[podcastSelecetedIndex])"
        podcastImageView.sd_setImage(with: URL(string: podcastsImageURL[podcastSelecetedIndex]), placeholderImage: NSImage(named: "placeholder"), options: .init(), context: nil)
        collectionView.reloadData()
        networkIndicator.startAnimation(Any?.self)
        view.addSubview(networkIndicator)
    }
    
    @objc func deletedPodcast(){
        collectionView.deselectAll(Any?.self)
        podcastImageView.image = nil
        podcastTitleField.stringValue = ""
        episodes.removeAll()
        collectionView.reloadData()
    }
    
}

extension DetailVC: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let forecastItem = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "EpisodeCellView"), for: indexPath)
        
        guard let forecastCell = forecastItem as? EpisodeCellView else { return forecastItem}
        forecastCell.configureEpisodeCell(episodeCell: episodes[indexPath.item])
        
        return forecastCell
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: 680, height: 150)
    }
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        highlightItems(selected: true, atIndexPaths: indexPaths as Set<NSIndexPath>)
    }
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        collectionView.deselectAll(Any?.self)
        highlightItems(selected: false, atIndexPaths: indexPaths as Set<NSIndexPath>)
    }

    
    
}
