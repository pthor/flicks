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

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var movies = [Movie]()

    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var networkErrorNotificationView: UIView!
    
    let posterBaseUrl = "http://image.tmdb.org/t/p/w780"
    let posterSmallBaseUrl = "http://image.tmdb.org/t/p/w92"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkErrorNotificationView.hidden = true
        moviesTableView.rowHeight = 250.0
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refrechMoviesFromNetowrk:", forControlEvents: UIControlEvents.ValueChanged)
        moviesTableView.insertSubview(refreshControl, atIndex: 0)
        loadMoviesFromNetowrk()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
        "com.codepath.exampleCell")! as! MyCell
        //clear out any old junk
        cell.postImageView.image = nil
        let movie = movies[indexPath.row]
        if let posterPath = movie.backdropPath{
            //let posterUrl = posterBaseUrl + posterPath
            loadImageForCell(cell,posterPath:  posterPath)
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
        print("prepare for seque")
    }
    
    func loadImageForCell(cell: MyCell, posterPath: String){
        
        let smallImageRequest = NSURLRequest(URL: NSURL(string: posterSmallBaseUrl + posterPath)!)
        let largeImageRequest = NSURLRequest(URL: NSURL(string: posterBaseUrl + posterPath)!)
        let myImageView = cell.postImageView
        
        myImageView.setImageWithURLRequest(
            smallImageRequest,
            placeholderImage: nil,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                // smallImageResponse will be nil if the smallImage is already available
                // in cache (might want to do something smarter in that case).
                myImageView.alpha = 0.0
                myImageView.image = smallImage;
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    myImageView.alpha = 1.0
                    
                    }, completion: { (sucess) -> Void in
                        
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        myImageView.setImageWithURLRequest(
                            largeImageRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                myImageView.image = largeImage;
                                
                            },
                            failure: { (request, response, error) -> Void in
                                self.networkErrorNotificationView.hidden = false
                        })
                })
            },
            failure: { (request, response, error) -> Void in
                self.networkErrorNotificationView.hidden = false
        })
    }
    
    func loadMoviesFromNetowrk()
    {
        // Display HUD right before the request is made
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Fetching flicks";
        Movie.fetchNowPlaying({ (movies) -> Void in
              self.movies = movies
              print("\(movies)")
              //sad I have to put in a delay just to show the progress indicator
              sleep(1)
              MBProgressHUD.hideHUDForView(self.view, animated: true)
              self.moviesTableView.reloadData()
            })
            { (error) -> Void in
                sleep(1)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.networkErrorNotificationView.hidden = false

                print("Error getting movies")
            }
    }
    
    func refrechMoviesFromNetowrk(refreshControl: UIRefreshControl)
    {
        // Display HUD right before the request is made
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Fetching flicks";
        Movie.fetchNowPlaying({ (movies) -> Void in
            self.movies = movies
            print("\(movies)")
            //sad I have to put in a delay just to show the progress indicator
            sleep(1)
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            refreshControl.endRefreshing()
            self.moviesTableView.reloadData()
            })
            { (error) -> Void in
                sleep(1)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.networkErrorNotificationView.hidden = false
                
                print("Error getting movies")
        }
    }


}

class MyCell: UITableViewCell{

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var myCustomLabel: UILabel!
}



