//
//  BaseAPI.swift
//  
//
//  Created by Tomasz Kucharski on 01/12/2021.
//

import Foundation
import Swifter

protocol BaseAPI {
    
    init(_ server: HttpServer, dataStore: DataStore)
}

extension BaseAPI {
    func getMainTemplate(_ request: HttpRequest) -> Template {
        let template = Template(raw: Resource.getAppResource(relativePath: "templates/main.tpl"))
        let userBadge = Template(raw: Resource.getAppResource(relativePath: "templates/userBadgeView.tpl"))
        let avatarUrl = "https://www.gravatar.com/avatar/5ede5914f659676c0295d5282c1c9df9"
        userBadge.assign("avatarUrl", avatarUrl)
        template.assign("userBadge", userBadge.output())
        return template
    }
}
