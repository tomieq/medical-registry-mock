//
//  WebApplication.swift
//  
//
//  Created by Tomasz Kucharski on 12/03/2021.
//

import Foundation
import Swifter

class WebApplication {
    
    private let dataStore = DataStore()
    var handlers: [BaseAPI] = []
    
    init(_ server: HttpServer) {
        
        self.handlers.append(AuthAPI(server, dataStore: self.dataStore))
        self.handlers.append(EditProjectAPI(server, dataStore: self.dataStore))
        self.initConfiguration()
        
        
        server.middleware.append { request, responseHeaders in
            request.disableKeepAlive = true
            //responseHeaders.addHeader("Cache-Control", "max-age=1, must-revalidate")
            Logger.debug("Incoming", request.path)
            return nil
        }
        
        
        server.notFoundHandler = { request, responseHeaders in

            let filePath = Resource.absolutePath(forPublicResource: request.path)
            if FileManager.default.fileExists(atPath: filePath) {

                guard let file = try? filePath.openForReading() else {
                    Logger.error("File", "Could not open `\(filePath)`")
                    return .notFound
                }
                let mimeType = filePath.mimeType()
                responseHeaders.addHeader("Content-Type", mimeType)

                if let attr = try? FileManager.default.attributesOfItem(atPath: filePath),
                    let fileSize = attr[FileAttributeKey.size] as? UInt64 {
                    responseHeaders.addHeader("Content-Length", String(fileSize))
                }

                return .raw(200, "OK", { writer in
                    try writer.write(file)
                    file.close()
                })
            }
            Logger.error("Unhandled request", "File `\(filePath)` doesn't exist")
            return .notFound
        }
    }
    
    
    private func initConfiguration() {
        let sampleProject = Project()
        sampleProject.name = "Badanie testowe"
        
        let dict = ProjectDictionary()
        dict.name = "Prosta decyzja"
        
        let option1 = ProjectDictionaryOption()
        option1.title = "Tak"
        dict.options.append(option1)
        
        
        let option2 = ProjectDictionaryOption()
        option2.title = "Nie"
        dict.options.append(option2)
        
        let option3 = ProjectDictionaryOption()
        option3.title = "Nie wiem"
        dict.options.append(option3)
        
        sampleProject.dictionaries.append(dict)
        
        let dict2 = ProjectDictionary()
        dict2.name = "Województwo"
        
        let list = ["dolnośląskie", "kujawsko-pomorskie", "lubelskie", "lubuskie", "łódzkie",
                    "małopolskie", "mazowieckie", "opolskie", "podkarpackie", "podlaskie",
                    "pomorskie", "śląskie", "świętokrzyskie", "warmińsko-mazurskie", "wielkopolskie", "zachodniopomorskie"]
        
        list.forEach {
            let option = ProjectDictionaryOption()
            option.title = $0
            dict2.options.append(option)
        }
        sampleProject.dictionaries.append(dict2)
        
        
        self.dataStore.projects.append(sampleProject)
    }
}
