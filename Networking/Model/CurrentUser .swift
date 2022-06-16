//
//  CurrentUser .swift
//  Networking
//
//  Created by Andriy on 16.06.2022.
//  Copyright © 2022 Alexey Efimov. All rights reserved.
//

import Foundation

//Модель яка тримає в собі дані користувача з firebase
struct CurrentUser {
    let uid: String
    let name: String
    let email: String
    
    init?(uid: String, data: [String: Any]) {
        
        guard let name = data["name"] as? String,
              let email = data["email"] as? String
        else { return nil }
        
        self.uid = uid
        self.name = name
        self.email = email
    }
}
