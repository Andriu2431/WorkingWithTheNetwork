//
//  DataProvider.swift
//  Networking
//
//  Created by Andriy on 06.06.2022.
//  Copyright © 2022 Alexey Efimov. All rights reserved.
//

import UIKit

//Тут реалізуємо виконання в фоні
class DataProvider: NSObject {

    //Будемо використовувати для наствройки задачі
    private var downloadTask: URLSessionDownloadTask!
    //Будемо тримати силку на файл
    var fileLocation: ((URL) -> ())?
    //Прогрес загрузки
    var onProgress: ((Double) -> ())?
    
    //Тут будемо настроювати сесію
    private lazy var backgroundSesion: URLSession = {
        //Ставимо фаонову задачу
        let config = URLSessionConfiguration.background(withIdentifier: "Networking.com")
        //Запуск задачі в оптимальний час для системи
        //config.isDiscretionary = true
        //Час скільки ми можемо чекати підключення до мережі
        //config.timeoutIntervalForResource = 300
        //Позволяє системі почекати для підключення до мережі
        //config.waitsForConnectivity = true
        //Після завершення загрузки данних апка впаде в фоновий режим
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    //Створюємо задачу після загрузки данних
    func startDownload() {
        
        if let url = URL(string: "https://speed.hetzner.de/100MB.bin") {
            //Передаємо сесію
            downloadTask = backgroundSesion.downloadTask(with: url)
            //Гарантує що загрузка загрузка почнеться не раніше заданого часу від того коли створиться задача
            downloadTask.earliestBeginDate = Date().addingTimeInterval(3)
            //Верхня границя числа байтів яку клієнт хоче відправити
            downloadTask.countOfBytesClientExpectsToSend = 522
            //Верхня границя числа байтів яку клієнт очікує получити
            downloadTask.countOfBytesClientExpectsToReceive = 100 * 1024 * 1024
            //Запустимо загрузка
            downloadTask.resume()
        }
    }
    
    //Метод для зупинки загрузки
    func stopDownload() {
        downloadTask.cancel()
    }
}

extension DataProvider: URLSessionDelegate {
    
    //Спрацьовує по завершенню всіх фонових задач
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                  //Передаємо ідентифікатоп програми
                  let completionHandler = appDelegate.bgSesioncompletionHandler else { return }
            
            //Скажемо шо значення ідентифікатора є пустим
            appDelegate.bgSesioncompletionHandler = nil
            //Повідомляємо систему, що загрузка завершилась, тут є UIKit, тому все в main потоці
            completionHandler()
        }
    }
}


extension DataProvider: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("did finish download: \(location.absoluteString)")
        DispatchQueue.main.async {
            //Передамо силку на файл
            self.fileLocation?(location)
        }
    }

    
    //Для того щоб бачити прогрес загрузки
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        //Очікуємий розмір файла ==
        guard totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown else { return }
        
        //Присвоюємо результат ділення кількості байт на загальну кількість байт
        let progress = Double(Double(totalBytesWritten)/Double(totalBytesExpectedToWrite))
        print("Download progress: \(progress)")
        
        //Передаємо прогрес загрузки в властівість
        DispatchQueue.main.async {
            self.onProgress?(progress)
        }
    }
}


extension DataProvider: URLSessionDataDelegate {
    
    //Метод спрацює тоді коли відновиться мережа
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        
    }
}
