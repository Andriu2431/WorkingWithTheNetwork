//
//  ImageViewController.swift
//  Networking
//
//  Created by Alexey Efimov on 27.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import Alamofire

class ImageViewController: UIViewController {
    
    private let url = "https://applelives.com/wp-content/uploads/2016/03/iPhone-SE-11.jpeg"
    private let largeImageUrl = "https://i.imgur.com/3416rvI.jpg"
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var progresView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        completedLabel.isHidden = true
        progresView.isHidden = true
    }
    
    //Метод грузить фото через NetworkManager
    func fetchImage() {
        
        NetworkManager.dowloadImage(url: url) { image in
            
            self.activityIndicator.stopAnimating()
            self.imageView.image = image
        }
    }
    
    //Метод грузить фото через Alamofire
    func fetchDataWithAlamofire() {
        AF.request(url).responseData { responseData in
            switch responseData.result {
            case .success(let data):
                //Получаємо фото
                guard let image = UIImage(data: data) else { return }
                self.activityIndicator.stopAnimating()
                self.imageView.image = image
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //Метод грузить велике фото з progresView
    func downloadImageWithProgress() {
        
        AlamofireNetworkRequest.onProgress = { progress in
            self.progresView.isHidden = false
            //Передаємо значення прогресу в progresView
            self.progresView.progress = Float(progress)
        }
        
        AlamofireNetworkRequest.completed = { completed in
            self.completedLabel.isHidden = false
            self.completedLabel.text = completed
        }
        
        AlamofireNetworkRequest.downloadImageWithProgress(url: largeImageUrl) { image in
            self.activityIndicator.stopAnimating()
            self.completedLabel.isHidden = true
            self.progresView.isHidden = true
            self.imageView.image = image
        }
    }
    
}
