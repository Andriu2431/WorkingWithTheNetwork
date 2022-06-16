//
//  UserProfile.swift
//  Networking
//
//  Created by Andriy on 15.06.2022.
//  Copyright © 2022 Alexey Efimov. All rights reserved.
//

import Foundation

//Тут будемо зберігати данні користувача з фейсбуку
struct UserProfile {
    
    let id: Int?
    let name: String?
    let email: String?
    
    init(data: [String: Any]) {
        let id = data["id"] as? Int
        let name = data["name"] as? String
        let email = data["email"] as? String
     
        self.id = id
        self.name = name
        self.email = email
    }
}
