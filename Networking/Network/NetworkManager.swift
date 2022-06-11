//
//  NetworkManager.swift
//  Networking
//
//  Created by Andriy on 05.06.2022.
//  Copyright © 2022 Alexey Efimov. All rights reserved.
//

import UIKit

class NetworkManager {
 
    //Получаємо
    static func getRequest(url: String) {
        
        guard let url = URL(string: url) else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            
            guard let response = response, let data = data else { return }
            
            print(response)
            print(data)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print(error)
            }
        }.resume()
    }
    
    //Відправляємо
    static func postRequest(url: String) {
        
        guard let url = URL(string: url) else { return }
        
        let userData = ["Course": "Networking", "Lesson": "GET and POST"]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: userData, options: []) else { return }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            guard let response = response, let data = data else { return }
            
            print(response)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print(error)
            }
        } .resume()
    }
    
    //Загружаємо фото
    static func dowloadImage(url: String, complititon: @escaping (_ image: UIImage) -> ()) {
        guard let url = URL(string: url) else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    //Передамо фото яке ортимали далі
                    complititon(image)
                }
            }
        } .resume()
    }
    
    //Загрузка курсів
    static func fetchData(url: String, complititon: @escaping (_ courses: [Course]) -> ()) {
        guard let url = URL(string: url) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let courses = try decoder.decode([Course].self, from: data)
                
                //Передаємо далі дасив типу моделі
                complititon(courses)
                
            } catch let error {
                print("Error serialization json", error)
            }
            
        }.resume()
    }
    
    //Метод який позволяє нам відправляти фото на сервер (POST)
    static func uploadImage(url: String) {
        
        let image = UIImage(named: "Notification")!
        //Створимо параметри які будемо передавати на сервер - беремо з сайту ключ та значення
        let httpHeaders = ["Authorization": "Client-ID ee38363eb0eb734"]
        guard let imageProperties = ImageProperties(withImage: image, forKey: "image") else { return }
        
        guard let url = URL(string: url) else { return }
        
        var request = URLRequest(url: url)
        //Скажемо, що буде відправка данних
        request.httpMethod = "POST"
        //Передаємо цей словник в якості параметрів заголовка запиту
        request.allHTTPHeaderFields = httpHeaders
        //В запит поміщаємо дані які відправимо на сервер - наше фото типу Data
        request.httpBody = imageProperties.data
        
        //Відправляємо запит на сервер - та через замикання получаємо анзад його
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print("error")
                }
            }
        }.resume()
    }
    
}

