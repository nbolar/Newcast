//
//  PodcastSearchVC.swift
//  Newcast
//
//  Created by Nikhil Bolar on 8/1/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa
import Alamofire

class PodcastSearchVC: NSViewController {
    
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var podcastSearchField: NSSearchField!
    var feedURL : String!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        collectionView.dataSource = self
        collectionView.delegate = self
        
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        podcasts.append("Hello")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateUI"), object: nil)
//        let url = URL(string: "https://atp.fm/episodes?format=rss")
        
//        let url = URL(string: "https://itunes.apple.com/search?term=\(podcastSearchField.stringValue)&media=podcast&limit=15")
//
//        AF.request(url!).responseData { (response) in
//            let parser = Parser()
//            self.feedURL = parser.parsePodcastMetaData(response.data!)
//            self.podcastListing()
//
//        }
    }
    func podcastListing(){
        let url = URL(string: feedURL)
        AF.request(url!).responseData(completionHandler: { (response) in
            let parser = Parser()
            parser.getPodcastMetaData(response.data!)
        })
    }
    func highlightItems(selected: Bool, atIndexPaths: Set<NSIndexPath>) {
        for indexPath in atIndexPaths {
            guard let item = collectionView.item(at: indexPath as IndexPath) else {continue}
            (item as! PodcastCellView).setHighlight(selected: selected)
            
        }
    }
}


extension PodcastSearchVC: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let forecastItem = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "PodcastCellView"), for: indexPath)
        
        //        guard let forecastCell = forecastItem as? PodcastCellView else { return forecastItem}
        //        forecastCell.configureCell(weatherCell: WeatherService.instance.forecast[indexPath.item])
        
        
        return forecastItem
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        highlightItems(selected: true, atIndexPaths: indexPaths as Set<NSIndexPath>)
    }
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        highlightItems(selected: false, atIndexPaths: indexPaths as Set<NSIndexPath>)
    }
    
    
}
