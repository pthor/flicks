//
//  ViewController.swift
//  Flicks
//
//  Created by Paul Thormahlen on 2/2/16.
//  Copyright © 2016 Paul Thormahlen. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var movies = [Movie]()

    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var networkErrorNotificationView: UIView!
    
    @IBOutlet weak var movieSearchBar: UISearchBar!
    var searchActive : Bool = false
    
    let posterBaseUrl = "http://image.tmdb.org/t/p/w780"
    let posterSmallBaseUrl = "http://image.tmdb.org/t/p/w92"
    var endPoint = "now_playing"
    let movieRefreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkErrorNotificationView.hidden = true
        movieSearchBar.delegate = self
        moviesTableView.rowHeight = 200.0
        self.networkErrorNotificationView.hidden = true
        movieRefreshControl.addTarget(self, action: "refetchMoviesFromNetowrk:", forControlEvents: UIControlEvents.ValueChanged)
        moviesTableView.insertSubview(movieRefreshControl, atIndex: 0)
        loadMoviesFromNetowrk()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        movieSearchBar.resignFirstResponder()
        print("hide the keyboard yo")
    }
    
    func tableView(tableView: UITableView, didselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.moviesTableView.cellForRowAtIndexPath(indexPath) as! MyCell
        cell.blurEffectView.alpha = 1.0
        cell.highlighted = true
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.moviesTableView.cellForRowAtIndexPath(indexPath) as! MyCell
        cell.blurEffectView.alpha = 0.8
        cell.highlighted = false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
        "com.codepath.exampleCell")! as! MyCell
        //clear out any old junk
        cell.postImageView.image = nil
        cell.postThumbnailView.image = nil
        let movie = movies[indexPath.row]
        if let backdropPath = movie.backdropPath{
            loadImageForCell(cell.postImageView,posterPath: backdropPath)
        }
        if let posterPath = movie.posterPath{
            loadImageForCell(cell.postThumbnailView,posterPath: posterPath)
        }
        print(" set cell rating = \(movie.rating) out of 1-")
        if let rating = movie.rating {
            cell.ratingLabel.text = "Rating: \(rating)/10"
        }
        else{
            cell.ratingLabel.text = ""
        }
        cell.myCustomLabel.text = "\(movie.title!)"
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = moviesTableView.indexPathForCell(cell)
        let movie = movies[indexPath!.row]
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
    }
    
    func loadImageForCell(myImageView: UIImageView, posterPath: String){
        
        let smallImageRequest = NSURLRequest(URL: NSURL(string: posterSmallBaseUrl + posterPath)!)
        let largeImageRequest = NSURLRequest(URL: NSURL(string: posterBaseUrl + posterPath)!)
        
        myImageView.setImageWithURLRequest(
            smallImageRequest,
            placeholderImage: nil,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                myImageView.alpha = 0.0
                myImageView.image = smallImage;
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    myImageView.alpha = 1.0
                    
                    }, completion: { (sucess) -> Void in
                        myImageView.setImageWithURLRequest(
                            largeImageRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                myImageView.image = largeImage;
                                
                            },
                            failure: { (request, response, error) -> Void in
                                //this is causing issues when it shouldnt
                                //self.networkErrorNotificationView.hidden = false
                        })
                })
            },
            failure: { (request, response, error) -> Void in
                //this is causing issues when it shouldnt
                //self.networkErrorNotificationView.hidden = false
        })
    }
    
    func loadMoviesFromNetowrk()
    {
        refetchMoviesFromNetowrk(movieRefreshControl)
    }
    
    func onMovieFetchError(error: NSError?) -> Void{
        print("Error getting movies")
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        self.networkErrorNotificationView.hidden = false
    }
    
    func onMovieFetchSuccess(movies: [Movie]) -> Void{
        self.movies = movies
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        self.networkErrorNotificationView.hidden = true
        self.movieRefreshControl.endRefreshing()
        self.moviesTableView.reloadData()
        if(self.movies.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
    }
    
    func refetchMoviesFromNetowrk(refreshControl: UIRefreshControl)
    {
        // Display HUD right before the request is made
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Fetching flicks";
        if(self.endPoint == "top_rated"){
            Movie.fetchTopRated(onMovieFetchSuccess, error: onMovieFetchError)

        }else{
            Movie.fetchNowPlaying(onMovieFetchSuccess, error: onMovieFetchError)
        }
    }
    
    func searchMovies(searchText:String)
    {
        // Display HUD right before the request is made
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Fetching flicks";
        Movie.searchMovies(searchText, successCallback: onMovieFetchSuccess, error: onMovieFetchError)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        if(searchText != ""){
            searchMovies(searchText)
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }

    }


}

class MyCell: UITableViewCell{

    @IBOutlet weak var postThumbnailView: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var myCustomLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
}



