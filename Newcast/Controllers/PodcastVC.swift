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

/// Array containing the rss feed URLs of the podcast that has been added by the user
var podcasts : [String]! = []

/// Array containing the image URLs of the podcast that has been added by the user
var podcastsImageURL : [String]! = []

/// Array containing the titles of the podcast that has been added by the user
var podcastsTitle : [String]! = []

/// Array containing episodes of the selected podcast
var episodes : [Episodes] = []

/// Tracks the index of the podcast that has been deleted by the user
var deletedPodcastIndex : Int!

/// Tracks the index of the podcast that has been selected by the user
var podcastSelecetedIndex : Int!

class PodcastVC: NSViewController {
    
    @IBOutlet weak var backgroundImage: NSImageView!
    @IBOutlet weak var addPodcastButton: NSButton!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var removePodcastButton: NSButton!
    @IBOutlet weak var searchSavedPodcastsField: NSSearchField!
    var count: Int!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        UserDefaults.standard.removeObject(forKey: "playingIndex")
        UserDefaults.standard.removeObject(forKey: "currentSelectedPodcastIndex")
        
        // Fix the below stuff properly
//        if UserDefaults.standard.bool(forKey: "playingIndex") == false{
//            playingIndex = nil
//        }else{
//            playingIndex = UserDefaults.standard.integer(forKey: "playingIndex")
//        }
//        if UserDefaults.standard.bool(forKey: "currentSelectedPodcastIndex") == false{
//            currentSelectedPodcastIndex = nil
//        }else{
//            currentSelectedPodcastIndex = UserDefaults.standard.integer(forKey: "currentSelectedPodcastIndex")
//            podcastSelecetedIndex = currentSelectedPodcastIndex
//            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(savedDetails), userInfo: nil, repeats: true)
//
//        }
        
        
        view.insertVibrancyView(material: .hudWindow)
        let fieldBackgroundColor = NSColor(
            calibratedHue: 230/360,
            saturation: 0.35,
            brightness: 0.85,
            alpha: 0.3)
        
        searchSavedPodcastsField.layer?.backgroundColor = fieldBackgroundColor.cgColor
        searchSavedPodcastsField.layer?.borderColor = NSColor.gray.cgColor
        searchSavedPodcastsField.layer?.borderWidth = 1
        searchSavedPodcastsField.layer?.cornerRadius = 8
        episodes.removeAll()
        if UserDefaults.standard.array(forKey: "podcasts") == nil{
            podcasts = []
            podcastsImageURL = []
            podcastsTitle = []
        }else{
            podcasts = UserDefaults.standard.array(forKey: "podcasts") as? [String]
            podcastsImageURL = UserDefaults.standard.array(forKey: "podcastImagesURL") as? [String]
            podcastsTitle = UserDefaults.standard.array(forKey: "podcastsTitle") as? [String]
        }
        backgroundImage.alphaValue = 0.6
        addPodcastButton.alphaValue = 0.8
        collectionView.dataSource = self
        collectionView.delegate = self
        searchSavedPodcastsField.refusesFirstResponder = true
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name(rawValue: "updateUI"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(customURL), name: NSNotification.Name(rawValue: "customURL"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addPodcastButtonClicked(_:)), name: NSNotification.Name(rawValue: "search"), object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(activateSearch), name: NSNotification.Name(rawValue: "searchSavedPodcast"), object: nil)
        
    }
    
    @objc func savedDetails(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateTitle"), object: nil)
    }
    
    @IBAction func searchSavedPodcast(_ sender: Any) {
        count = 0
        if searchSavedPodcastsField.stringValue.count != 0{
            for i in 0..<podcastsTitle.count{
                let editedTitle = podcastsTitle[i].lowercased()
                if editedTitle.contains(searchSavedPodcastsField.stringValue) {
                    scroll(position: count)
                    break
                }else if podcasts[i].description.contains(searchSavedPodcastsField.stringValue.lowercased()){
                    scroll(position: count)
                    break
                }
                count += 1
            }
        }
    }
    
    func scroll(position : Int)
    {
        let itemIndex = NSIndexPath(forItem: position, inSection: 0)
        let ctx = NSAnimationContext.current
        ctx.allowsImplicitAnimation = true
        collectionView.animator().scrollToItems(at: [itemIndex as IndexPath], scrollPosition: .bottom)
        let item = collectionView.item(at: itemIndex as IndexPath)
        (item as! PodcastCellView).setSearchHighlight(selected: true)
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(unhighlight), userInfo: nil, repeats: false)
        
    }
    
    @objc func unhighlight()
    {
        searchSavedPodcastsField.stringValue = ""
        let itemIndex = NSIndexPath(forItem: count, inSection: 0)
        let item = collectionView.item(at: itemIndex as IndexPath)
        (item as! PodcastCellView).setHighlight(selected: false)
    }
    
    @objc func updateUI(){
        collectionView.reloadData()
        let items = collectionView.numberOfItems(inSection: 0)
        let last = IndexPath(item: items - 1, section: 0)
        DispatchQueue.main.async {
            let ctx = NSAnimationContext.current
            ctx.allowsImplicitAnimation = true
            self.collectionView.animator().scrollToItems(at: [last as IndexPath], scrollPosition: .bottom)
            let item = self.collectionView.item(at: last as IndexPath)
            (item as! PodcastCellView).setSearchHighlight(selected: true)
            self.count = items - 1
            Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.unhighlight), userInfo: nil, repeats: false)
        }
                
            
    }
    
    /// This function is yet be completely implemented. This allows the user to add a custom Feed URL.
    @objc func customURL(){
        podcasts.append(customPodcastURL)
        let url = URL(string: customPodcastURL)
        AF.request(url!).responseData(completionHandler: { (response) in
            let parser = Parser()
            if response.data != nil{
                episodes = parser.getPodcastMetaData(response.data!)
            }
        })
        collectionView.reloadData()
    }
    
    /// Function used to call the parser to parse through the xml feed URL
    func podcastListing(podcastFeedURL : String){
        let url = URL(string: podcastFeedURL)
        AF.request(url!).responseData(completionHandler: { (response) in
            let parser = Parser()
            if response.data != nil{
                episodes = parser.getPodcastMetaData(response.data!)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateEpisodes"), object: nil)
            }
        })
    }
    
    func selectedPodcast(atIndexPaths: Set<NSIndexPath>){
        for indexPath in atIndexPaths{
            podcastListing(podcastFeedURL: podcasts![indexPath.item])
            podcastSelecetedIndex = indexPath.item
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateTitle"), object: nil)
        }
    }
    
    @IBAction func addPodcastButtonClicked(_ sender: Any) {
//        collectionView.deselectAll(Any?.self)
        let podcastsearch = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "PodcastSearchVC") as? NSViewController
        presentAsSheet(podcastsearch!)
    }
    func highlightItems(selected: Bool, atIndexPaths: Set<NSIndexPath>) {
        if selected == false{
            if playingIndex != nil || episodeSelectedIndex != nil{
                episodeTitle = episodeTitles[episodeSelectedIndex ?? playingIndex]
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "clearPodcastEpisodes"), object: nil)
        }
        removePodcastButton.isEnabled = !collectionView.selectionIndexPaths.isEmpty
        for indexPath in atIndexPaths {
            guard let item = collectionView.item(at: indexPath as IndexPath) else {continue}
            (item as! PodcastCellView).setHighlight(selected: selected)
        }
    }
    
    @IBAction func removePodcastButtonClicked(_ sender: Any) {
        deletedPodcastIndex = nil
        let selectionIndexPaths = collectionView.selectionIndexPaths
        var selectionArray = Array(selectionIndexPaths)
        selectionArray.sort(by: {path1, path2 in return path1.compare(path2) == .orderedDescending})
        for itemIndexPath in selectionArray {
            // 2
            podcasts.remove(at: itemIndexPath.item)
            podcastsImageURL.remove(at: itemIndexPath.item)
            podcastsTitle.remove(at: itemIndexPath.item)
            pausedTimesDictionary.removeValue(forKey: itemIndexPath.item)
            deletedPodcastIndex = itemIndexPath.item
            UserDefaults.standard.set(podcasts, forKey: "podcasts")
            UserDefaults.standard.set(podcastsImageURL, forKey: "podcastImagesURL")
            UserDefaults.standard.set(podcastsTitle, forKey: "podcastsTitle")
            
        }
        collectionView.deselectAll(Any?.self)
        collectionView.deleteItems(at: selectionIndexPaths)
        collectionView.reloadData()
        editTimeStamps()
    }
    
    func editTimeStamps(){
        for index in deletedPodcastIndex..<podcasts.count{
            pausedTimesDictionary[index] = pausedTimesDictionary[index+1]
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deletedPodcast"), object: nil)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear() {
        if playingIndex != nil && currentSelectedPodcastIndex != nil {
            
            UserDefaults.standard.set(playingIndex!, forKey: "playingIndex")
            UserDefaults.standard.set(currentSelectedPodcastIndex!, forKey: "currentSelectedPodcastIndex")
        }
        
        // Save this in userdefaults and then call this in viewdidload to check if there is any podcast playing and then call update title in detailVC
    }
    
}

extension PodcastVC: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let forecastItem = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "PodcastCellView"), for: indexPath)
        
        if podcastsImageURL.count != 0{
            guard let forecastCell = forecastItem as? PodcastCellView else { return forecastItem}
            forecastCell.configurePodcastAddedCell(podcastCell: podcastsImageURL[indexPath.item])
            return forecastCell
        }else{
            return forecastItem
        }
        
        
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
        episodesCheck = 1
        selectedPodcast(atIndexPaths: indexPaths as Set<NSIndexPath>)
        highlightItems(selected: true, atIndexPaths: indexPaths as Set<NSIndexPath>)
    }
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        highlightItems(selected: false, atIndexPaths: indexPaths as Set<NSIndexPath>)
    }
    
    
}

extension NSView {
    /**
     - Note: You should almost never need to set `appearanceName` as it's done automatically
     */
    @discardableResult
    func insertVibrancyView(
        material: NSVisualEffectView.Material = .appearanceBased,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        appearanceName: NSAppearance.Name? = nil
        ) -> NSVisualEffectView {
        let view = NSVisualEffectView(frame: bounds)
        view.autoresizingMask = [.width, .height]
        view.material = material
        view.blendingMode = blendingMode
        
        if let appearanceName = appearanceName {
            view.appearance = NSAppearance(named: appearanceName)
        }
        
        addSubview(view, positioned: .below, relativeTo: nil)
        
        return view
    }
}


extension NSSearchField{
    @IBInspectable var placeHolderColor: NSColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.placeholderAttributedString = NSAttributedString(string:self.placeholderString != nil ? self.placeholderString! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}
