//
//  NewsViewController.swift
//  SimpleNewsReader
//
//  Created by Abhinav Kalva on 10/5/16.
//  Copyright © 2016 edu. All rights reserved.
//

import UIKit
import Foundation


extension URLSessionConfiguration {
    
    class func NewsReaderSessionConfiguration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        
        // Send some specfic headers.
        
        return config
    }
}

struct NewsDetails {
    let id:String
    let title:String
    let description:String
    let thumbnailURL:String
    var thumbnailImageData:Data?
}

class NewsViewController: UITableViewController {
    
    // MARK: Data
    var url:URL!
    let downloadQueue = DispatchQueue(label: Constants.DownloadQueue)
    var newsList = [NewsDetails]()
    lazy var session:URLSession = { [unowned self] in
        return URLSession(configuration: URLSessionConfiguration.NewsReaderSessionConfiguration())
    }()
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchResults()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier, identifier == StoryboardIdentifier.ShowDetailNewsViewController else {
            print("Invalid segue")
            return
        }
        
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
            print("Invalid segue")
            return
        }
        
        guard let destinationVC = segue.destination as? DetailNewsViewController else {
            print("Invalid destination viewcontroller")
            return
        }
        
        destinationVC.newsDetail = newsList[indexPath.row]
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardIdentifier.ThumbnailCellReuseIdentifier, for: indexPath)
        cell.textLabel!.text = newsList[indexPath.row].title
        
        cell.imageView?.image = nil
        if let data = self.newsList[indexPath.row].thumbnailImageData {
            cell.imageView?.image = UIImage(data: data)
        } else {
            cell.imageView?.image = UIImage(named: Constants.PlaceHolderImage)
            asynchronousDownload(index: indexPath.row)
        }
        
        return cell
    }
    
    // MARK: Private methods
    private func fetchResults() {
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            guard nil == error else {
                self.displayError(text: "\(error?.localizedDescription)")
                return
            }
            
            guard let response = response as?  HTTPURLResponse , response.statusCode == 200 else {
                self.displayError(text: "Failed to download Flickr photos!!")
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                if let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    if let newsArray = result["Items"] as? [Any] {
                        for newsDict in newsArray {
                            if let newsDict = newsDict as? [String:String] {
                                
 
                                // Assumption: We are assuming all the entries are always present.
                                let id = newsDict["Id"]
                                let description =  newsDict["Description"]
                                let title = newsDict["Title"]
                                let thumbnailUrl = newsDict["ThumbnailUrl"]
                                
                                let newsDetail = NewsDetails(id: id!, title: title!,
                                                             description: description!,
                                                             thumbnailURL: thumbnailUrl!,
                                                             thumbnailImageData: nil)
                                self.newsList.append(newsDetail)
                            }
                        }
                    } else {
                        print("Error: Unexpected Json format!")
                    }
                } else {
                    print("Error: Unexpected Json format!")
                }
                
                DispatchQueue.main.async { [unowned self] in
                    self.tableView.reloadData()
                }
            } catch {
                self.displayError(text: "\(error)")
            }
        }
        task.resume()
    }
    
    private func displayError(text: String) {
        
        DispatchQueue.main.async { [unowned self] in
            let errorAlert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel) { action in
                // Nothing
            }
            errorAlert.addAction(okAction)
            self.present(errorAlert, animated: true, completion: nil)
        }
    }
    
    private func asynchronousDownload(index: Int) {
        
        downloadQueue.async {
            let url = URL(string: self.newsList[index].thumbnailURL)
            let imgData = try! Data(contentsOf: url!)
            
            DispatchQueue.main.async {
                self.newsList[index].thumbnailImageData = imgData
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.top)
            }
        }
    }
    
}
