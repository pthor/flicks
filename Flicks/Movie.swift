//
//  Movie.swift
//  Ficks
//
//  Created by Paul Thormahlen on 2/3/16.
//  Copyright © 2016 Paul Thormahlen. All rights reserved.
//
import Foundation
import AFNetworking

//private let params = ["api-key": "53eb9541b4374660d6f3c0001d6249ca:19:70900879"]
private let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
private let nowPlyaingUrl = "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)"
private let searchMoviesUrl = "http://api.themoviedb.org/3/search/movie?api_key=\(apiKey)"


class Movie {
    var title: String?
    var overview: String?
    var posterPath: String?
    var backdropPath: String?
    var rating: Double?
    
    init(jsonResult: NSDictionary) {
        title = jsonResult["title"] as? String
        overview = jsonResult["overview"] as? String
        posterPath = jsonResult["poster_path"] as? String
        backdropPath = jsonResult["backdrop_path"] as? String
        rating = jsonResult["vote_average"] as? Double
        print(rating)
    }
    
    class func fetchNowPlaying(successCallback: ([Movie]) -> Void, error: ((NSError?) -> Void)?) {
        let manager = AFHTTPRequestOperationManager()
        manager.GET(nowPlyaingUrl, parameters: [], success: { (operation ,responseObject) -> Void in
            if let results = responseObject["results"] as? NSArray {
                var movies: [Movie] = []
                for result in results as! [NSDictionary] {
                    movies.append(Movie(jsonResult: result))
                }
                successCallback(movies)
            }
            }, failure: { (operation, requestError) -> Void in
                if let errorCallback = error {
                    errorCallback(requestError)
                }
        })
    }
    
    class func searchMovies(searchText:String,successCallback: ([Movie]) -> Void,
        error: ((NSError?) -> Void)?) {
        let queryParam = searchText.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        let searchUrl = searchMoviesUrl + "&query=\(queryParam)"
            print(searchUrl)
        let manager = AFHTTPRequestOperationManager()
        manager.GET(searchUrl, parameters: [], success: { (operation ,responseObject) -> Void in
            if let results = responseObject["results"] as? NSArray {
                var movies: [Movie] = []
                for result in results as! [NSDictionary] {
                    movies.append(Movie(jsonResult: result))
                }
                successCallback(movies)
            }
            }, failure: { (operation, requestError) -> Void in
                if let errorCallback = error {
                    errorCallback(requestError)
                }
        })
    }
    
    
}