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
var feedsURL = [String]()
class Parser {
    
    
    fileprivate var _date: String!
    fileprivate var _title: String!
    fileprivate var _rssURL: String!
    fileprivate var _imageURL: String!
    
    
    var date: String {
        get{
            return _date
        } set {
            _date = newValue
        }
    }
    
    var title: String {
        get{
            return _title
        } set {
            _title = newValue
        }
    }
    
    var rssURL: String {
        get{
            return _rssURL
        } set {
            _rssURL = newValue
        }
    }
    var imageURL: String {
        get{
            return _imageURL
        } set {
            _imageURL = newValue
        }
    }
    
    
    func parsePodcastMetaData(_ APIData: Data) -> [Parser]{
        feedsURL.removeAll()
        var podcastSearch = [Parser]()
        let json = try! JSON(data: APIData)
        print(json)
        
        if let list = json["results"].array{
            for podcast in list
            {
                let podcastsearchItem = Parser()
                podcastsearchItem.imageURL = podcast["artworkUrl100"].stringValue
                podcastSearch.append(podcastsearchItem)
                feedsURL.append(podcast["feedUrl"].stringValue)
            }
            
        }
        
        //        let feedURL = json["results"][0]["feedUrl"].stringValue
        podcastsNumber = json["resultCount"].intValue
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateSearchUI"), object: nil)
        return podcastSearch
    }
    func getPodcastMetaData(_ APIData: Data){
        let xml = SWXMLHash.parse(APIData)
        if let title = (xml["rss"]["channel"]["itunes:image"].element?.attribute(by: "href")?.text){
            print(title)
        }
    }
}
