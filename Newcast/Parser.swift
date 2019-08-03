//
//  Parser.swift
//  Newcast
//
//  Created by Nikhil Bolar on 7/31/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Foundation
import SWXMLHash
import SwiftyJSON
var podcastsNumber : Int!

class Parser {
    
    func parsePodcastMetaData(_ APIData: Data) -> String{
        let json = try! JSON(data: APIData)
        print(json)
        
//        if let list = json["results"].array{
//            for podcast in list
//            {
//                print(podcast["trackCensoredName"])
//            }
//        }
        
        let feedURL = json["results"][0]["feedUrl"].stringValue
        podcastsNumber = json["resultCount"].intValue
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateSearchUI"), object: nil)
        return feedURL

    }
    func getPodcastMetaData(_ APIData: Data){
        let xml = SWXMLHash.parse(APIData)
        if let title = (xml["rss"]["channel"]["itunes:image"].element?.attribute(by: "href")?.text){
            print(title)
        }
    }
}
