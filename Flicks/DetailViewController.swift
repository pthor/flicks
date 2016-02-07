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
    @IBOutlet weak var networkErrorNotificationView: UIView!
    @IBOutlet weak var trailerWebView: UIWebView!
    
    
    let posterBaseUrl = "http://image.tmdb.org/t/p/w780"
    let posterSmallBaseUrl = "http://image.tmdb.org/t/p/w92"
    
    var movie: Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkErrorNotificationView.hidden = true
        print(movie.title)
        overviewLabel.text = movie.overview!
        titleLabel.text = movie.title
        
        if let posterPath = movie.posterPath{
            
            loadPostImageAtPath(posterPath)
            
            movie.getPreviewUrl({ (youtubeUrl) -> Void in
                print("got youtube url \(youtubeUrl)")
                self.trailerWebView.allowsInlineMediaPlayback = true
                self.trailerWebView.opaque = false;
                self.trailerWebView.backgroundColor = UIColor.clearColor()
                
                let embedText = "<html><head><style>body, html, iframe { margin: 0; padding: 0; background-color: black; }</style></head><body><iframe width=\"\(self.trailerWebView.frame.width)\" height=\"\(self.trailerWebView.frame.height)\" src=\"\(youtubeUrl!)?playsinline=1\" frameborder=\"0\" allowfullscreen></iframe></body></html>"
                print(embedText)
                self.trailerWebView.loadHTMLString(embedText, baseURL: nil)
                

            }, error: { (error) -> Void in
                print("did not get youtube url")
            })
            
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
                    self.networkErrorNotificationView.hidden = false
                    // do something for the failure condition
            })
        }

    }
    
    func loadPostImageAtPath(posterPath: String){
        
        let smallImageRequest = NSURLRequest(URL: NSURL(string: posterSmallBaseUrl + posterPath)!)
        let largeImageRequest = NSURLRequest(URL: NSURL(string: posterBaseUrl + posterPath)!)
        let myImageView = posterimageView
        
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

}
