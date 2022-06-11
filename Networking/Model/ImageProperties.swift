//
//  ImagesPropertis.swift
//  Networking
//
//  Created by Andriy on 05.06.2022.
//  Copyright © 2022 Alexey Efimov. All rights reserved.
//

import UIKit

//Структура яку будемо передавати на сервер як фото
struct ImageProperties {
    
    let key: String
    let data: Data
    
    init?(withImage image: UIImage, forKey kay: String) {
        self.key = kay
        //Форматуєм зображення png в тип Data
        guard let data = image.pngData() else { return nil }
        self.data = data
    }
}
