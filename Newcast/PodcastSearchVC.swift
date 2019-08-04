//
//  PodcastSearchVC.swift
//  Newcast
//
//  Created by Nikhil Bolar on 8/1/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa
import Alamofire
import Network

var feedURL : [String]!

class PodcastSearchVC: NSViewController {
    
    @IBOutlet weak var customURLField: NSTextField!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var podcastSearchField: NSSearchField!
    var selectedIndex : Int!
    let networkIndicator = NSProgressIndicator()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        collectionView.dataSource = self
        collectionView.delegate = self
        podcastsNumber = 0
        networkIndicator.style = .spinning
        customURLField.alphaValue = 0
        
        let labelXPostion:CGFloat = view.bounds.midX
        let labelYPostion:CGFloat = view.bounds.midY
        let labelWidth:CGFloat = 30
        let labelHeight:CGFloat = 30
        
        
        networkIndicator.frame = CGRect(x: labelXPostion, y: labelYPostion, width: labelWidth, height: labelHeight)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name(rawValue: "updateSearchUI"), object: nil)
        
    }
    
    @objc func updateUI(){
        collectionView.reloadData()
        networkIndicator.removeFromSuperview()
    }
    
    @IBAction func searchPodcast(_ sender: Any){
        podcastsNumber = 0
        networkIndicator.startAnimation(Any?.self)
        view.addSubview(networkIndicator)
        //        let url = URL(string: "https://atp.fm/episodes?format=rss")
        
        let editedURL = podcastSearchField.stringValue.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let url = URL(string: "https://itunes.apple.com/search?term=\(editedURL)&entity=podcast&limit=50")
        //
        AF.request(url!).responseData { (response) in
            let parser = Parser()
            parser.parsePodcastMetaData(response.data!)
        }
        collectionView.reloadData()
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        if feedsURL.count != 0{
            if !podcasts.contains(feedsURL[selectedIndex]){
                podcasts.append(feedsURL[selectedIndex])
            }
        }

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateUI"), object: nil)
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
    func highlightItems(selected: Bool, atIndexPaths: Set<NSIndexPath>) {
        for indexPath in atIndexPaths {
            selectedIndex = indexPath.item
            podcastListing(podcastFeedURL: feedsURL[selectedIndex])
            guard let item = collectionView.item(at: indexPath as IndexPath) else {continue}
            (item as! PodcastCellView).setHighlight(selected: selected)
            
        }
        
    }
    @IBAction func addURLButtonClicked(_ sender: Any) {
        
        if customURLField.stringValue.count == 0{
            customURLField.alphaValue = 0.0
            NSAnimationContext.runAnimationGroup({_ in
                //Indicate the duration of the animation
                NSAnimationContext.current.duration = 0.5
                //            customURLField.layer?.transform = rotationTransform
                //            customURLField.animator().layer?.transform = CATransform3DIdentity
                customURLField.animator().alphaValue = 1.0
            }, completionHandler:{
                print("Animation completed")
            })
        }else{
            let editedURL = customURLField.stringValue.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
            podcastListing(podcastFeedURL: editedURL)
            customURLField.stringValue = ""
            customURLField.placeholderString = "Podcast Added!"
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateUI"), object: nil)
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
        return podcastsNumber ?? 0
        
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
