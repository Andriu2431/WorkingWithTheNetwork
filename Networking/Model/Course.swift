//
//  Course.swift
//  Networking
//
//  Created by Alexey Efimov on 07.09.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import Foundation

//Це для URLSesion
//struct Course: Decodable {
//
//    let id: Int?
//    let name: String?
//    let link: String?
//    let imageUrl: String?
//    let numberOfLessons: Int?
//    let numberOfTests: Int?
//}

//Це для Alamofire та URLSesion
struct Course: Decodable {
    
    let id: Int?
    let name: String?
    let link: String?
    let imageUrl: String?
    let numberOfLessons: Int?
    let numberOfTests: Int?
    
    init?(json: [String: Any]) {
        let id = json["id"] as? Int
        let name = json["name"] as? String
        let link = json["link"] as? String
        let imageUrl = json["imageUrl"] as? String
        let numberOfLessons = json["number_of_lessons"] as? Int
        let numberOfTests = json["number_of_tests"] as? Int
        
        self.id = id
        self.name = name
        self.link = link
        self.imageUrl = imageUrl
        self.numberOfLessons = numberOfLessons
        self.numberOfTests = numberOfTests
    }
    
    //Метод обробки масива
    static func getArray(from jsonArray: Any) -> [Course]? {
        
        //Кастим масив який приймемо до масиву з словниками
        guard let jsonArray = jsonArray as? Array<[String: Any]> else { return nil }
        
        var courses: [Course] = []
        
        //Розкладаємо масив
        for jsonObject in jsonArray {
            if let course = Course(json: jsonObject) {
                courses.append(course)
            }
        }
        return courses
//        return courses.compactMap { Course(json: $0)}
    }
}
