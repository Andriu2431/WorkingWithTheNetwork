//
//  AlamofireNetworkRequest.swift
//  Networking
//
//  Created by Andriy on 09.06.2022.
//  Copyright © 2022 Alexey Efimov. All rights reserved.
//

import Foundation
import Alamofire

//Мережеві запити через бібліотеку Alamofire
class AlamofireNetworkRequest {
    
    static var onProgress: ((Double) -> ())?
    static var completed: ((String) -> ())?
    
    static func sendRequest(url: String, complititon: @escaping (_ courses: [Course]) -> ())  {
        
        guard let url = URL(string: url) else { return }
        
        AF.request(url).validate().responseJSON { response in
            
            //response.result - Скаже, чи прийшов результат з помилкою чи з данними
            switch response.result {
            case .success(let value):
                var courses = [Course]()
                courses = Course.getArray(from: value)!
                //Мисив з данними передаємо далі
                complititon(courses)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //Загружаємо курси через json
    static func responsData(url: String) {
        AF.request(url).responseData { responseData in
            switch responseData.result {
            case .success(let data):
                //Получаємо строку з типу Data
                guard let string = String(data: data, encoding: .utf8) else { return }
                print(string)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //Загружаємо через String - відповідь прийде в String(Json)
    static func responseString(url: String) {
        AF.request(url).responseString { responseString in
            
            switch responseString.result {
            case .success(let string):
                print(string)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //Метод видає данні в тому виді в якому приходять
    static func response(url: String) {
        AF.request(url).response { response in
            guard let data = response.data,
                  let string = String(data: data, encoding: .utf8)
            else { return }
            
            print(string)
        }
    }
    
    //Зaгрузка фото з progressView
    static func downloadImageWithProgress(url: String, completion: @escaping (_ image: UIImage) -> ()) {
        
        guard let url = URL(string: url) else { return }
        
        AF.request(url).validate().downloadProgress { (progress) in
            
            print("totalUnitCount: \(progress.totalUnitCount)\n")
            print("completedUnitCount:\(progress.completedUnitCount)\n")
            print("fractionCompleted:\(progress.fractionCompleted)\n")
            print("loclizedDescription:\(progress.localizedDescription!)\n")
            print("---------------------------------------------------------")

            self.onProgress?(progress.fractionCompleted)
            self.completed?(progress.localizedDescription)
            
            //Получаємо данні
            }.response { (response) in
                
                //Створюємо фото по даті
                guard let data = response.data, let image = UIImage(data: data) else { return }
                
                DispatchQueue.main.async {
                    completion(image)
                }
        }
    }
    
    //Метод для відпраки данних на сервер - тут буде бага по структурі, тому що сайт нам видає трохи іншу структуру ніж те, що нам видавав API курсів
    static func postRequest(url: String, completion: @escaping (_ courses: [Course]) -> ()) {
        
        guard let url = URL(string: url) else { return }
        
        //Створимо словник який відправимо
        let userData: [String: Any] = [
            "name": "Network Requests",
            "link": "https://swiftbook.ru/contents/our-first-applications/",
            "imageUrl": "https://swiftbook.ru/wp-content/uploads/sites/2/2018/08/notifications-course-with-background.png",
            "numberOfLessons": 18,
            "numberOfTests": 10
        ]
        
        AF.request(url, method: .post, parameters: userData).responseData { responseData in
            
            guard let statusCode = responseData.response?.statusCode else { return }
            print("statusCode:", statusCode)
            
            switch responseData.result {
            case .success(let data):
                //З дати робимо json, який приводимо до словника який передамо в екземплям моделі
                do {
                    guard let jsonObject =
                            try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let course = Course(json: jsonObject) else { return }
                    var couses = [Course]()
                    couses.append(course)
                    completion(couses)
                }
                catch {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //Метод оновляє дані на сервері
    static func putRequest(url: String, completion: @escaping (_ courses: [Course]) -> ()) {
        
        guard let url = URL(string: url) else { return }
        
        //Створимо словник який відправимо
        let userData: [String: Any] = [
            "name": "Network Requests with Alamofire",
            "link": "https://swiftbook.ru/contents/our-first-applications/",
            "imageUrl": "https://swiftbook.ru/wp-content/uploads/sites/2/2018/08/notifications-course-with-background.png",
            "numberOfLessons": 18,
            "numberOfTests": 10
        ]
        
        AF.request(url, method: .put, parameters: userData).responseData { responseData in
            
            guard let statusCode = responseData.response?.statusCode else { return }
            print("statusCode:", statusCode)
            
            switch responseData.result {
            case .success(let data):
                //З дати робимо json, який приводимо до словника який передамо в екземплям моделі
                do {
                    guard let jsonObject =
                            try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let course = Course(json: jsonObject) else { return }
                    var couses = [Course]()
                    couses.append(course)
                    completion(couses)
                }
                catch {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //Відправляє фото на сервер черезAlamofire
    static func uploadImage(url: String) {
        guard let url = URL(string: url) else { return }
        
        let image = UIImage(named: "Notification")!
        //Фото типу Data
        let data = image.pngData()!
        
        //Параметри для авторизації на сервері
        let httpHeaders: HTTPHeaders = ["Authorization": "Client-ID ee38363eb0eb734"]
        
        //Для передачі малих данних
        AF.upload(
            multipartFormData: { multipartFormData in
                //Передаємо фото типу дата, та ключ з сайту
                multipartFormData.append(data, withName: "image")
            }, to: url, headers: httpHeaders).responseData { responseData in
                
                //responseData - це вже відповідь з сайту куди закидуємо фото
                
                //Перевіримо результат
                switch responseData.result {
                    
                case .success(let data):
                    //З дати робимо json, який приводимо до словника який передамо в екземплям моделі
                    do {
                        //Зробимо результат в форматі json а не Data
                        let jsonObject = try JSONSerialization.jsonObject(with: data)
                        print(jsonObject)
                    }
                    catch {
                        print(error)
                    }
                case .failure(let error):
                    print(error)
                }
            }
    }
    
}


//        //Скажемо що посилаємо запит, та вертаємо його в json
//        AF.request(url, method: .get).responseJSON { response in
//
//            guard let statusCode = response.response?.statusCode else { return }
//
//            print("statusCode:", statusCode)
//
//            //Якщо код прийде від 200 до 299 виведемо результат, якщо ні, то помилку
//            if (200..<300).contains(statusCode) {
//
//                let value = response.value
//                print("value:", value ?? "nil")
//            } else {
//                let error = response.error
//                print(error ?? "error")
//            }
//        }
