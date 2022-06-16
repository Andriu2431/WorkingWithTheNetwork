//
//  MainViewController.swift
//  Networking
//
//  Created by Andriy on 05.06.2022.
//  Copyright © 2022 Alexey Efimov. All rights reserved.
//

import UIKit
import UserNotifications
import FBSDKLoginKit

enum Actions: String, CaseIterable {
    case downloadImage = "Download Image"
    case get = "GET"
    case post = "POST"
    case ourCourses = "Our Courses"
    case uploadImage = "Upload Image"
    case downloadFile = "Download File"
    case ourCoursesAlamofire = "Our Courses (Alamofire)"
    case responseData = "Response Data"
    case responseString = "Response String"
    case response = "Response"
    case downloadLargeImage = "Download Large Image"
    case postAlamofire = "POST with alamofire"
    case putRequest = "PUT request with alamofire"
    case uploadImageAlamofire = "Upload Image Alamofire"
}

private let reuseIdentifier = "Cell"
private let url = "https://jsonplaceholder.typicode.com/posts"
private let swiftBookApi = "https://swiftbook.ru//wp-content/uploads/api/api_courses"
private let uploadImage = "https://api.imgur.com/3/image"

class MainViewController: UICollectionViewController {
    
    //Вертає масив всіх значень даного перечислення, для того і потрібно підписати enum під CaseIterable
    let actionsArray = Actions.allCases
    private var alert: UIAlertController!
    private let dataProvider = DataProvider()
    //Лінка на файл
    private var filePath: String?
    
    
    //Після того коли скачається файл ми отримуємо силку на файл. В цей момент апка перезапускається в фоні та викликає viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        registerForNotification()
        
        //Присвоїмо силку на файл в властивість
        dataProvider.fileLocation = { location in
            //Зберігяємо файл для подальшого використання
            print(location.absoluteString)
            self.filePath = location.absoluteString
            //Вимикаємо алерт
            self.alert.dismiss(animated: false)
            self.postNotification()
        }
        checkLoggedIn()
    }
    
    //Метод для арелт контроллера
    private func showAlert() {
        
        alert = UIAlertController(title: "Downloading...", message: "0%", preferredStyle: .alert)
        
        //Створимо констрейн по висоті для алерт
        let height = NSLayoutConstraint(item: alert.view!,
                                       attribute: .height,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 0,
                                       constant: 170)
        //Добавим його на наш алерт
        alert.view.addConstraint(height)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { action in
            //Відміняюмо загрузку фала
            self.dataProvider.stopDownload()
        }
        
        alert.addAction(cancelAction)
        present(alert, animated: true) {
            
            //Добавим activityIndicator на alert
            let size = CGSize(width: 40, height: 40)
            let point = CGPoint(x: self.alert.view.frame.width / 2 - size.width / 2,
                                y: self.alert.view.frame.height / 2 - size.height / 2)
            //Створюємо activityIndicator з розміром size
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(origin: point, size: size))
            activityIndicator.color = .gray
            activityIndicator.startAnimating()
            
            //Добавим progressView на alert
            let progressView = UIProgressView(frame: CGRect(x: 0, y: self.alert.view.frame.height - 44, width: self.alert.view.frame.width, height: 2))
            progressView.tintColor = .blue
            
            //Передаємо дані прогресу загрузки в наш прогрес view
            self.dataProvider.onProgress = { progress in
                progressView.progress = Float(progress)
                //ПРиводимо до нормального вигляду
                self.alert.message = String(Int(progress * 100)) + "%"
            }
            
            //Добавляємо створені обєкти на alert
            self.alert.view.addSubview(activityIndicator)
            self.alert.view.addSubview(progressView)
        }
    }


    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actionsArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        //Присвоюємо стрінгове значення для label, по indexPath
        cell.label.text = actionsArray[indexPath.row].rawValue
        return cell
    }

    // MARK: UICollectionViewDelegateʼ
    //Метод для визначення по якому контейнеру тапає юзер
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Фіксуємо вибір користувача в цю властивість
        let actions = actionsArray[indexPath.row]
        
        //Виконаємо дію в залежності куди тапнув юзер
        switch actions {
        case .downloadImage:
            //Переходимо на ImageViewController
            performSegue(withIdentifier: "ShowImage", sender: self)
        case .get:
            //Робимо запит через інтернет менеджера
            NetworkManager.getRequest(url: url)
        case .post:
            NetworkManager.postRequest(url: url)
        case .ourCourses:
            //Переходимо на CoursesViewController
            performSegue(withIdentifier: "OurCourses", sender: self)
        case .uploadImage:
            NetworkManager.uploadImage(url: uploadImage)
        case .downloadFile:
            showAlert()
            dataProvider.startDownload()
        case .ourCoursesAlamofire:
            //Переходимо на CoursesViewController
            performSegue(withIdentifier: "OurCoursesWithAlamofire", sender: self)
        case .responseData:
            performSegue(withIdentifier: "ResponseData", sender: self)
            AlamofireNetworkRequest.responsData(url: swiftBookApi)
        case .responseString:
            AlamofireNetworkRequest.responseString(url: swiftBookApi)
        case .response:
            AlamofireNetworkRequest.response(url: swiftBookApi)
        case .downloadLargeImage:
            performSegue(withIdentifier: "LargeImage", sender: self)
        case .postAlamofire:
            performSegue(withIdentifier: "PostRequest", sender: self)
        case .putRequest:
            performSegue(withIdentifier: "PutRequest", sender: self)
        case .uploadImageAlamofire:
            AlamofireNetworkRequest.uploadImage(url: uploadImage)
        }
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let coursesVC = segue.destination as? CoursesViewController
        let imageVC = segue.destination as? ImageViewController
        
        //По ідентифікатору переходів будемо викликати той чи інший метод
        switch segue.identifier {
        case "OurCourses":
            coursesVC?.fetchData()
        case "OurCoursesWithAlamofire":
            coursesVC?.fetchDataWithAlamofire()
        case "ShowImage":
            imageVC?.fetchImage()
        case "ResponseData":
            imageVC?.fetchDataWithAlamofire()
        case "LargeImage":
            imageVC?.downloadImageWithProgress()
        case "PostRequest":
            coursesVC?.postRequest()
        case "PutRequest":
            coursesVC?.putRequest()
        default:
            break
        }
    }
    
}

//Розширення для відправки пуш повідомлення
extension MainViewController {
    
    //Робим запит в користувача чи можна відправляти повідомлення
    private func registerForNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in
            
        }
    }
    
    private func postNotification() {
        let content = UNMutableNotificationContent()
        //Заголовок повідомлення
        content.title = "Download complete!"
        //Текст повідомлення
        content.body = "Your background transfer has completed. File path: \(filePath ?? "")"
        
        //Приходити буде через 3 сек після загрузки файла
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        //Запит
        let request = UNNotificationRequest(identifier: "TransferComplete", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

//MARK: Facebook SDK

extension MainViewController {
    
    //Для перевірки чи користувач зарейстрований чи ні
    private func checkLoggedIn() {
        
        //Якщо токена немає, то презентуєм екран рейстрації
        if AccessToken.current == nil {
            DispatchQueue.main.async {
                //Екземпляр сторіборда
                let storyBord = UIStoryboard(name: "Main", bundle: nil)
                //Контролер по ідентифікатору
                let logitVC = storyBord.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                
                self.present(logitVC, animated: true)
                return
            }
        }
    }
}
