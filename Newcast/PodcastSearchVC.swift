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
import CircularProgressMac

var feedURL : [String]!
var customPodcastURL : String!

class PodcastSearchVC: NSViewController {
    
    
    @IBOutlet weak var noResultsLabel: NSTextField!
    @IBOutlet weak var addPodcastButton: NSButton!
    @IBOutlet weak var customURLField: NSTextField!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var podcastSearchField: NSSearchField!
    var selectedIndex : Int!
    let networkIndicator = NSProgressIndicator()
    let circularProgress = CircularProgress(size: 40)
    static let instance = PodcastSearchVC()
    fileprivate var _podcastSearch = [Parser]()
    
    var podcastSearch: [Parser]{
        get{
            return _podcastSearch
        } set {
            _podcastSearch = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        collectionView.dataSource = self
        collectionView.delegate = self
        podcastsNumber = 0
        networkIndicator.style = .spinning
        customURLField.alphaValue = 0
        noResultsLabel.isHidden = true
//        let labelXPostion:CGFloat = view.bounds.midX
//        let labelYPostion:CGFloat = view.bounds.midY
//        let labelWidth:CGFloat = 30
//        let labelHeight:CGFloat = 30
//        addPodcastButton.isHidden = false
//
//        networkIndicator.frame = CGRect(x: labelXPostion, y: labelYPostion, width: labelWidth, height: labelHeight)
        circularProgress.isIndeterminate = true
        circularProgress.color = .white
        let labelXPostion:CGFloat = view.bounds.midX - 30
        let labelYPostion:CGFloat = view.bounds.midY
        let labelWidth:CGFloat = 40
        let labelHeight:CGFloat = 40
        circularProgress.frame = CGRect(x: labelXPostion, y: labelYPostion, width: labelWidth, height: labelHeight)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name(rawValue: "updateSearchUI"), object: nil)
        
    }
    
    @objc func updateUI(){
        collectionView.reloadData()
        circularProgress.removeFromSuperview()
        collectionView.reloadData()
        if podcastsNumber == 0 && podcastSearchField.stringValue.count != 0 {
            noResultsLabel.isHidden = false
        }
    }
    
    @IBAction func searchPodcast(_ sender: Any){
        addPodcastButton.isHidden = false
        noResultsLabel.isHidden = true
        podcastsNumber = 0
        collectionView.deselectAll(Any?.self)
//        networkIndicator.startAnimation(Any?.self)
//        view.addSubview(networkIndicator)
        view.addSubview(circularProgress)
        //        let url = URL(string: "https://atp.fm/episodes?format=rss")
        
        let editedURL = podcastSearchField.stringValue.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let url = URL(string: "https://itunes.apple.com/search?term=\(editedURL)&entity=podcast&limit=100")
        //
        AF.request(url!).responseData { (response) in
            if response.data != nil{
                let parser = Parser()
                self.podcastSearch = parser.parsePodcastMetaData(response.data!)
            }
            
        }
        collectionView.reloadData()
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        if feedsURL.count != 0{
            if !podcasts.contains(feedsURL[selectedIndex]){
                podcasts.append(feedsURL[selectedIndex])
                podcastsImageURL.append(imagesURL[selectedIndex])
                podcastsTitle.append(titles[selectedIndex])
                UserDefaults.standard.set(podcasts, forKey: "podcasts")
                UserDefaults.standard.set(podcastsTitle, forKey: "podcastsTitle")
                UserDefaults.standard.set(podcastsImageURL, forKey: "podcastImagesURL")
            }
        }
        podcastSearchField.stringValue = ""
        podcastSearchField.placeholderString = "Podcast Added!"
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateUI"), object: nil)
    }

    func highlightItems(selected: Bool, atIndexPaths: Set<NSIndexPath>) {
        for indexPath in atIndexPaths {
            selectedIndex = indexPath.item
            guard let item = collectionView.item(at: indexPath as IndexPath) else {continue}
            (item as! PodcastCellView).setHighlight(selected: selected)
            
        }
        
    }
    @IBAction func addURLButtonClicked(_ sender: Any) {
        
        addPodcastButton.isHidden = true
        if customURLField.stringValue.count == 0{
            customURLField.alphaValue = 0.0
            NSAnimationContext.runAnimationGroup({_ in
                NSAnimationContext.current.duration = 0.5
                customURLField.animator().alphaValue = 1.0
            }, completionHandler:{
            })
        }else{
            customPodcastURL = customURLField.stringValue.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
            customURLField.stringValue = ""
            customURLField.placeholderString = "Podcast Added!"
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateUI"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "customURL"), object: nil)
        }

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}


extension PodcastSearchVC: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let forecastItem = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "PodcastCellView"), for: indexPath)
        
        guard let forecastCell = forecastItem as? PodcastCellView else { return forecastItem}
        forecastCell.configurePodcastSearchCell(podcastCell: self.podcastSearch[indexPath.item] )
        
        
        return forecastCell
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
