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
    override func viewDidLoad() {
        super.viewDidLoad()
        moviesTableView.rowHeight = 250.0
        loadMoviesFromNetowrk()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
        "com.codepath.exampleCell")! as! MyCell
        let movie = movies[indexPath.row]
        if let posterPath = movie.backdropPath{
            let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
            let posterUrl = posterBaseUrl + posterPath
            let imageRequest = NSURLRequest(URL: NSURL(string: posterUrl)!)
            cell.postImageView.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.postImageView.alpha = 0.0
                        cell.postImageView.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            cell.postImageView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.postImageView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
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
                print("Error getting movies")
            }
    }


}

class MyCell: UITableViewCell{

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var myCustomLabel: UILabel!
}



