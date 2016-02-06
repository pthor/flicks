//
//  DetailViewController.swift
//  Flicks
//
//  Created by Paul Thormahlen on 2/4/16.
//  Copyright © 2016 Paul Thormahlen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var posterimageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movie: Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(movie.title)
        overviewLabel.text = movie.overview!
        titleLabel.text = movie.title
        
        if let posterPath = movie.posterPath{
            let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
            let posterUrl = posterBaseUrl + posterPath
            let imageRequest = NSURLRequest(URL: NSURL(string: posterUrl)!)
            posterimageView.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        self.posterimageView.alpha = 0.0
                        self.posterimageView.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.posterimageView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        self.posterimageView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
        }

    }

}
