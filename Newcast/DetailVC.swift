//
//  DetailVC.swift
//  Newcast
//
//  Created by Nikhil Bolar on 7/31/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa
import SDWebImage
import AVFoundation

var podcastSelecetedIndex : Int!

class DetailVC: NSViewController {

    @IBOutlet weak var playPauseButton: NSButton!
    @IBOutlet weak var skip30ForwardButton: NSButton!
    @IBOutlet weak var skip30BackButton: NSButton!
    @IBOutlet weak var playerSlider: NSSlider!
    @IBOutlet weak var episodesPlaceholderField: NSTextField!
    @IBOutlet weak var podcastImageView: SDAnimatedImageView!
    @IBOutlet weak var podcastTitleField: NSTextField!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var playerCustomView: NSView!
    @IBOutlet weak var backgroundImageView: NSImageView!
    var playPauseCheck: Int! = 0
    let networkIndicator = NSProgressIndicator()
    let popoverView = NSPopover()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        collectionView.deselectAll(Any?.self)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTitle), name: NSNotification.Name(rawValue: "updateTitle"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateEpisodes), name: NSNotification.Name(rawValue: "updateEpisodes"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deletedPodcast), name: NSNotification.Name(rawValue: "deletedPodcast"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deletedPodcast), name: NSNotification.Name(rawValue: "clearPodcastEpisodes"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveSlider), name: NSNotification.Name(rawValue: "moveSlider"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playPausePass), name: NSNotification.Name(rawValue: "playPausePass"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideUI), name: NSNotification.Name(rawValue: "hide"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unhideUI), name: NSNotification.Name(rawValue: "unhide"), object: nil)
        
        setupUI()
        playPauseCheck = 0
    }
    
    func setupUI(){
        networkIndicator.style = .spinning
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.wantsLayer = true
        collectionView.layer?.cornerRadius = 8
        backgroundImageView.alphaValue = 0.6
        playerCustomView.wantsLayer = true
        playerCustomView.layer?.backgroundColor = CGColor.init(gray: 0.9, alpha: 0.2)
        playerCustomView.layer?.cornerRadius = 8
        playerCustomView.layer?.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        podcastImageView.image = nil
        podcastImageView.wantsLayer = true
        podcastImageView.layer?.cornerRadius = 8
        podcastImageView.alphaValue = 0.9
        podcastImageView.layer?.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        podcastTitleField.stringValue = ""
        episodesPlaceholderField.alphaValue = 0
        playerSlider.isHidden = true
        playPauseButton.isHidden = true
        skip30BackButton.isHidden = true
        skip30ForwardButton.isHidden = true
        
        
        
        
        let labelXPostion:CGFloat = view.bounds.midX
        let labelYPostion:CGFloat = view.bounds.midY
        let labelWidth:CGFloat = 30
        let labelHeight:CGFloat = 30
        networkIndicator.frame = CGRect(x: labelXPostion, y: labelYPostion, width: labelWidth, height: labelHeight)
    }
    
    @objc func hideUI(){
        playerSlider.isHidden = true
        playPauseButton.isHidden = true
        skip30BackButton.isHidden = true
        skip30ForwardButton.isHidden = true
    }
    @objc func unhideUI(){
        playerSlider.isHidden = false
        playPauseButton.isHidden = false
        skip30BackButton.isHidden = false
        skip30ForwardButton.isHidden = false
    }
    @objc func moveSlider(){
        if playerDuration != nil && playerSeconds != nil{
            playerSlider.maxValue = Double(playerDuration)
            playerSlider.floatValue = playerSeconds
        }
        
    }
    @objc func playPausePass(){
        if playPauseButton.image?.name() == "play"{
            playPauseButton.image = NSImage(named: "pause")
        }else{
            playPauseButton.image = NSImage(named: "play")
        }
    }
    
    @IBAction func playPauseButtonClicked(_ sender: Any) {
        if playPauseButton.image?.name() == "play"{
//            playPauseButton.image = NSImage(named: "pause")
            playCount = 0
//            playPauseButton.image = NSImage(named: "pause")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "playButton"), object: nil)
        }else{
            pauseCount = 0
//            playPauseButton.image = NSImage(named: "play")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pauseButton"), object: nil)
        }
    }
    func highlightItems(selected: Bool, atIndexPaths: Set<NSIndexPath>) {
        for indexPath in atIndexPaths {
            guard let item = collectionView.item(at: indexPath as IndexPath) else {continue}
            (item as! EpisodeCellView).setHighlight(selected: selected)
            if selected == true{
                (item as! EpisodeCellView).showButton(atIndexPaths: indexPath.item)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "podcastChanged"), object: nil)
                unhideUI()
            }
            if selected == false{
                (item as! EpisodeCellView).hideButton(atIndexPaths: indexPath.item)
            }
            
        }
    }
    
    @objc func updateEpisodes(){
        let area = NSTrackingArea.init(rect: podcastImageView.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        podcastImageView.addTrackingArea(area)
        collectionView.reloadData()
        networkIndicator.removeFromSuperview()
        episodesPlaceholderField.alphaValue = 1.0
        collectionView.deselectAll(Any?.self)
        collectionView.reloadData()
    }
    @objc func updateTitle(){
        let area = NSTrackingArea.init(rect: podcastImageView.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        podcastImageView.addTrackingArea(area)
        podcastTitleField.stringValue = "\(podcastsTitle[podcastSelecetedIndex])"
        podcastImageView.sd_setImage(with: URL(string: podcastsImageURL[podcastSelecetedIndex]), placeholderImage: NSImage(named: "placeholder"), options: .init(), context: nil)
        collectionView.reloadData()
        networkIndicator.startAnimation(Any?.self)
        view.addSubview(networkIndicator)
    }
    
    @objc func deletedPodcast(){
        let area = NSTrackingArea.init(rect: podcastImageView.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        podcastImageView.removeTrackingArea(area)
        collectionView.deselectAll(Any?.self)
        podcastImageView.image = nil
        podcastTitleField.stringValue = ""
        episodesPlaceholderField.alphaValue = 0
        playerSlider.isHidden = true
        playPauseButton.isHidden = true
        skip30BackButton.isHidden = true
        skip30ForwardButton.isHidden = true
        episodes.removeAll()
        collectionView.reloadData()
    }
    
    override func mouseEntered(with event: NSEvent) {
        displayPopUp()
//        print("Entered")
        
    }
    
    override func mouseExited(with event: NSEvent) {
//        print("Exited")
        if popoverView.isShown{
            popoverView.close()

        }
    }
    
    func displayPopUp(){
//        print(podcastDescription)
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc =  storyboard.instantiateController(withIdentifier: "PodcastDescriptionVC") as? NSViewController else { return }
        popoverView.contentViewController = vc
        popoverView.behavior = .transient
        popoverView.show(relativeTo: podcastImageView.bounds, of: podcastImageView, preferredEdge: .maxX)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
//        player = AVPlayer
        highlightItems(selected: true, atIndexPaths: indexPaths as Set<NSIndexPath>)
    }
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        collectionView.deselectAll(Any?.self)
        highlightItems(selected: false, atIndexPaths: indexPaths as Set<NSIndexPath>)
    }

    
    
}
