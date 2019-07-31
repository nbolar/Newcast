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

class PodcastVC: NSViewController {

    @IBOutlet weak var podcastTextField: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func addPodcastClicked(_ sender: Any) {
        let url = URL(string: "https://atp.fm/episodes?format=rss")
        let parser = FeedParser(URL: url!)
        let result = parser.parse()
        let feed = result.rssFeed
        
        for i in 0..<feed!.items!.count{
            let item = feed!.items?[i]
            print("\(item!.title!) --  \(item!.pubDate!)")
            
        }
        
//        guard let feed = result.rssFeed, result.isSuccess else {
//            print(feed.title)
//            return
//        }
        
////        let url = URL(string: "https://itunes.apple.com/search?term=\(podcastTextField.stringValue)&media=podcast&limit=15")
//        AF.request(url!).response { (response) in
////            print(response)
//            let xml = SWXMLHash.parse(response.data!)
//
////            print(xml)
//        }
    }
}
