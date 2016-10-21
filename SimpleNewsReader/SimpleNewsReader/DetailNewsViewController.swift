//
//  DetailNewsViewController.swift
//  SimpleNewsReader
//
//  Created by Abhinav Kalva on 10/5/16.
//  Copyright © 2016 edu. All rights reserved.
//

import Foundation
import UIKit

class DetailNewsViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    var newsDetail:NewsDetails!

    var descriptionText: String?
    
    // MARK: - UIViewController
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        imageView?.image = UIImage(data: newsDetail.thumbnailImageData!)
        imageView?.contentMode = .scaleAspectFit
        titleLabel.text = newsDetail.title
        descriptionTextView.insertText(newsDetail.description)
    }
}
