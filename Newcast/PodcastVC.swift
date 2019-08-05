//
//  PodcastVC.swift
//  Newcast
//
//  Created by Nikhil Bolar on 7/31/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa
import Alamofire
import SWXMLHash
import FeedKit

var podcasts : [String]! = []
var podcastsImageURL : [String]! = []

class PodcastVC: NSViewController {

    @IBOutlet weak var backgroundImage: NSImageView!
    @IBOutlet weak var addPodcastButton: NSButton!
    @IBOutlet weak var collectionView: NSCollectionView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
//        UserDefaults.standard.removeObject(forKey: "podcasts")
//        UserDefaults.standard.removeObject(forKey: "podcastImagesURL")
        
        if UserDefaults.standard.array(forKey: "podcasts") == nil{
            podcasts = []
            podcastsImageURL = []
        }else{
            podcasts = UserDefaults.standard.array(forKey: "podcasts") as! [String]
            podcastsImageURL = UserDefaults.standard.array(forKey: "podcastImagesURL") as! [String]
        }
//        podcasts = UserDefaults.standard.array(forKey: "podcasts") as! [String]
        backgroundImage.alphaValue = 0.6
        addPodcastButton.alphaValue = 0.8
        collectionView.dataSource = self
        collectionView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name(rawValue: "updateUI"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(customURL), name: NSNotification.Name(rawValue: "customURL"), object: nil)
    }
    
    @objc func updateUI(){
        collectionView.reloadData()
    }
    @objc func customURL(){
        podcasts.append(customPodcastURL)
        let url = URL(string: customPodcastURL)
        AF.request(url!).responseData(completionHandler: { (response) in
            let parser = Parser()
            if response.data != nil{
                parser.getPodcastMetaData(response.data!)
            }
        })
        collectionView.reloadData()
    }
    
    func podcastListing(podcastFeedURL : String){
        let url = URL(string: podcastFeedURL)
        AF.request(url!).responseData(completionHandler: { (response) in
            let parser = Parser()
            if response.data != nil{
                parser.getPodcastMetaData(response.data!)
            }
        })
    }
    
    func selectedPodcast(atIndexPaths: Set<NSIndexPath>){
        for indexPath in atIndexPaths{
            podcastListing(podcastFeedURL: podcasts![indexPath.item])
        }
    }
    
    func highlightItems(selected: Bool, atIndexPaths: Set<NSIndexPath>) {
        for indexPath in atIndexPaths {
            guard let item = collectionView.item(at: indexPath as IndexPath) else {continue}
            (item as! PodcastCellView).setHighlight(selected: selected)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

extension PodcastVC: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let forecastItem = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "PodcastCellView"), for: indexPath)
        
        guard let forecastCell = forecastItem as? PodcastCellView else { return forecastItem}
        forecastCell.configurePodcastAddedCell(podcastCell: podcastsImageURL[indexPath.item])
        
        
        return forecastItem
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        selectedPodcast(atIndexPaths: indexPaths as Set<NSIndexPath>)
        highlightItems(selected: true, atIndexPaths: indexPaths as Set<NSIndexPath>)
    }
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        highlightItems(selected: false, atIndexPaths: indexPaths as Set<NSIndexPath>)
    }
    
    
}
