//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by quentin picard on 10/12/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var endpoint: String!
    
    // NetworkLabel
    let networkLabel = UILabel()
    
    // Refresh
    let refreshControl = UIRefreshControl()
    var isMoreDataLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        // Network Error label
        networkLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 26)
        networkLabel.center.x = self.view.center.x
        networkLabel.center.y = 75
        networkLabel.textAlignment = .center
        networkLabel.text = "Network Error"
        networkLabel.backgroundColor = UIColor.darkGray
        networkLabel.textColor = UIColor.white
        networkLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        networkLabel.alpha = 0.96
        
        self.view.addSubview(networkLabel)
        self.view.bringSubview(toFront: networkLabel)
    
        networkRequest()
        
        // Refresh
        refreshControl.addTarget(self, action: #selector(MoviesViewController.refresh), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        networkRequest()
        // table is reloaded in networkRequest
        refreshControl.endRefreshing()
        print("I just refreshed the tab")
    }
    
    func networkRequest() {
        // API
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        print("endpoint: \(endpoint)")
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        // Add progress indicator with MBProgressHUD CocoaPod
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            // Dismiss progress indicator
            MBProgressHUD.hide(for: self.view, animated: true)
            if let data = dataOrNil {
                self.networkLabel.isHidden = true
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    NSLog("response: \(responseDictionary)")
                    
                    self.movies = (responseDictionary["results"] as! [NSDictionary])
                    
                    // reload after the network has returned the data
                    self.tableView.reloadData()
                }
            } else {
                self.networkLabel.isHidden = false
            }
        });
        task.resume()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
  
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // downcast to MovieCell class
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        let baseUrl = "https://image.tmdb.org/t/p/w342"
        // Use if declaration to safely unwrap poster_path
        if let poster_path = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + poster_path)
            cell.posterView.setImageWith(imageUrl as! URL)
        }
        
        //print("row \(indexPath.row)")
        return cell
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //send current cell using sender
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        
        // Get the new view controller using segue.destinationViewController.
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
        
        // Pass the selected object to the new view controller.
    }
    

}
