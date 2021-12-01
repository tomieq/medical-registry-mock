//
//  JSCode.swift
//  
//
//  Created by Tomasz Kucharski on 01/12/2021.
//

import Foundation
import Swifter

class JSResponse {
    private var jsCodeList: [JSCode] = []
    var response: HttpResponse {
        return .ok(.javaScript(self.jsCodeList.map{ $0.js }.joined(separator: "\n")))
    }
    
    @discardableResult
    func add(_ code: JSCode) -> JSResponse {
        self.jsCodeList.append(code)
        return self
    }
}

enum JSCode {
    case loadAsLayer(url: String)
    case closeLayer
    case loadEditProjectTreeMenu(projectID: String, groupID: String)
    case loadEditProjectGroupList(projectID: String, groupID: String)
}

extension JSCode {
    var js: String {
        switch self {
        case .loadAsLayer(let url):
            return "openLayer('\(url)');"
        case .closeLayer:
            return "closeLayer();";
        case .loadEditProjectTreeMenu(let projectID, let groupID):
            return "$('#tree').load('/editTreeMenu?projectID=\(projectID)&groupID=\(groupID)');";
        case .loadEditProjectGroupList(let projectID, let groupID):
            return "$('#contentTable').load('/groupList?projectID=\(projectID)&groupID=\(groupID)');";
        }
    }
}
