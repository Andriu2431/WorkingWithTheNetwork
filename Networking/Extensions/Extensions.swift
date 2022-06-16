//
//  Extensions.swift
//  Networking
//
//  Created by Andriy on 12.06.2022.
//  Copyright © 2022 Alexey Efimov. All rights reserved.
//

import UIKit

//Настроїмо view, зробимо йому колір градіенту 

extension UIView {
    //Градіент для фона
    func addVerticalGradientLayer(topColor:UIColor, bottomColor:UIColor) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [topColor.cgColor, bottomColor.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        self.layer.insertSublayer(gradient, at: 0)
    }
}

extension UIColor {
    //Задаємо колір кастомний
    convenience init? (hexValue: String, alpha: CGFloat) {
        if hexValue.hasPrefix("#") {
            let scanner = Scanner(string: hexValue)
            scanner.currentIndex = scanner.string.index(after: scanner.currentIndex)
            
            var hexInt64: UInt64 = 0
            if hexValue.count == 7 {
                if scanner.scanHexInt64(&hexInt64) {
                    let red = CGFloat((hexInt64 & 0xFF0000) >> 16) / 255
                    let green = CGFloat((hexInt64 & 0x00FF00) >> 8) / 255
                    let blue = CGFloat(hexInt64 & 0x0000FF) / 255
                    self.init(red: red, green: green, blue: blue, alpha: alpha)
                    return
                }
            }
        }
        return nil
    }
}
