//
//  ListViewController.swift
//  SimpleNewsReader
//
//  Created by Abhinav Kalva on 10/5/16.
//  Copyright © 2016 edu. All rights reserved.
//

import Foundation
import UIKit

class ListViewController: UITableViewController {
    
    private let newsSources = [
        "Business News": "http://104.236.218.197/business.json",
        "Top Stories": "http://104.236.218.197/top-stories.json",
        "Entertainment News" : "http://104.236.218.197/entertainment.json"
        
    ]
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Constants.Title
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier, identifier == StoryboardIdentifier.ShowNewsViewController else {
            print("Invalid segue")
            return
        }
        
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
            print("Invalid segue")
            return
        }
        
        guard let destinationVC = segue.destination as? NewsViewController else {
            print("Invalid destination viewcontroller")
            return
        }
        
        let url = Array(newsSources.values)[indexPath.row]
        destinationVC.title = Array(newsSources.keys)[indexPath.row]
        destinationVC.url = URL(string: url)
    }

    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsSources.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardIdentifier.ListViewCellReuseIdentifier, for: indexPath)
        cell.textLabel!.text = Array(newsSources.keys)[indexPath.row]
        return cell
    }
}
