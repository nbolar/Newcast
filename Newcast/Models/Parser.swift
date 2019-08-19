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
import FeedKit
var podcastsNumber : Int!
var feedsURL = [String]()
var imagesURL = [String]()
var titles = [String]()
var episodeDescriptions = [String]()
var episodeTitles = [String]()
var episodesURL = [String]()
var podcastDescription = String()
class Parser {
    
    fileprivate var _imageURL: String!
    
    var imageURL: String {
        get{
            return _imageURL
        } set {
            _imageURL = newValue
        }
    }
    
    /// Parses the JSON podcast search results from the iTunes API.
    func parsePodcastMetaData(_ APIData: Data) -> [Parser]{
        feedsURL.removeAll()
        imagesURL.removeAll()
        titles.removeAll()
        
        var podcastSearch = [Parser]()
        let json = try! JSON(data: APIData)
        //        print(json)
        
        if let list = json["results"].array{
            for podcast in list
            {
                let podcastsearchItem = Parser()
                podcastsearchItem.imageURL = podcast["artworkUrl600"].stringValue
                podcastSearch.append(podcastsearchItem)
                imagesURL.append(podcast["artworkUrl600"].stringValue)
                feedsURL.append(podcast["feedUrl"].stringValue)
                titles.append(podcast["trackName"].stringValue)
                
            }
            
        }
        podcastsNumber = json["resultCount"].intValue
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateSearchUI"), object: nil)
        return podcastSearch
    }
    
    /// Parses the rss feed of the podcast.
    func getPodcastMetaData(_ APIData: Data) -> [Episodes]{
        episodeDescriptions.removeAll()
        episodeTitles.removeAll()
        podcastDescription.removeAll()
        episodesURL.removeAll()
        let xml = SWXMLHash.parse(APIData)
        podcastDescription = xml["rss"]["channel"]["itunes:summary"].element?.text ?? ""
        var episodes : [Episodes] = []
        for item in xml["rss"]["channel"]["item"].all{
            let episode = Episodes()
            episode.title = item["title"].element?.text ?? ""
            episode.podcastDescription = item["itunes:subtitle"].element?.text ?? ""
            if item["itunes:subtitle"].element == nil || item["itunes:subtitle"].element?.text == ""{
                episode.podcastDescription = item["description"].element?.text ?? ""
            }
            episode.audioURL = item["enclosure"].element?.attribute(by: "url")?.text ?? ""
            episode.episodeDuration = item["itunes:duration"].element?.text ?? ""
            let date = Episodes.formatter.date(from: item["pubDate"].element?.text ?? "")
            episode.pubDate = date ?? Date()
            episodeDescriptions.append(item["description"].element?.text ?? "")
            episodeTitles.append(item["title"].element?.text ?? "")
            episodesURL.append(item["enclosure"].element?.attribute(by: "url")?.text ?? "")
            episodes.append(episode)
        }
        return episodes
    }
}
