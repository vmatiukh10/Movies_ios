//
//  Movie.swift
//  Movies
//
//  Created by Volodymyr Matiukh on 14.12.2023.
//

import Foundation

struct Movie: Identifiable, Codable {
    enum CodingKeys: String, CodingKey {
        case adult, 
             id,
             title,
             overview,
             poster = "poster_path"
    }
    
//    "adult": false,
//          "backdrop_path": "/evxXVJtomJJbAXcDxF6wsCJzVDe.jpg",
//          "genre_ids": [
//            27
//          ],
//          "id": 1019836,
//          "original_language": "en",
//          "original_title": "Christmas Bloody Christmas",
//          "overview": "It's Christmas Eve and Tori just wants to get drunk and party, but when a robotic Santa Claus at a nearby toy store goes haywire and begins a rampant killing spree through her small town, she's forced into a battle for survival.",
//          "popularity": 554.678,
//          "poster_path": "/97PaQ7r4H3y0x9RTXusfedmzf86.jpg",
//          "release_date": "2022-10-05",
//          "title": "Christmas Bloody Christmas",
//          "video": false,
//          "vote_average": 5.642,
//          "vote_count": 14
    let adult: Bool
    let id: Int
    let title: String
    let overview: String
    let poster: String
}
