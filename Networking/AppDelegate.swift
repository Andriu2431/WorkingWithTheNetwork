//
//  AppDelegate.swift
//  Networking
//
//  Created by Alexey Efimov on 25/07/2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var bgSesioncompletionHandler: (() -> ())?
    
    //В completionHandler буде приходити ідентифікатоп програми
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        //Злапаємо його, та передамо в властивість
        bgSesioncompletionHandler = completionHandler
    }

}
