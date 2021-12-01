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
    case loadScript(url: String)
    case loadAsLayer(url: String)
    case closeLayer
    case changeGroupContext(projectID: String, groupID: String)
    case loadEditProjectTreeMenu(projectID: String, groupID: String)
    case loadEditProjectGroupList(projectID: String, groupID: String)
    case loadEditProjectCardsMenu(projectID: String, groupID: String)
    case loadEditProjectDictionaryList(projectID: String)
}

extension JSCode {
    var js: String {
        switch self {
        case .loadScript(let url):
            return "$.getScript('\(url)');"
        case .loadAsLayer(let url):
            return "openLayer('\(url)');"
        case .closeLayer:
            return "closeLayer();";
        case .changeGroupContext(let projectID, let groupID):
            return [
                JSCode.loadEditProjectTreeMenu(projectID: projectID, groupID: groupID),
                JSCode.loadEditProjectGroupList(projectID: projectID, groupID: groupID),
                JSCode.loadEditProjectCardsMenu(projectID: projectID, groupID: groupID)
            ].map{$0.js}.joined(separator: "")
        case .loadEditProjectTreeMenu(let projectID, let groupID):
            return "$('#tree').load('/editTreeMenu?projectID=\(projectID)&groupID=\(groupID)');";
        case .loadEditProjectGroupList(let projectID, let groupID):
            return "$('#contentTable').load('/groupList?projectID=\(projectID)&groupID=\(groupID)');";
        case .loadEditProjectCardsMenu(let projectID, let groupID):
            return "$('#cards').load('/editCardsMenu?projectID=\(projectID)&groupID=\(groupID)');";
        case .loadEditProjectDictionaryList(let projectID):
            return "$('#contentTable').load('/dictionaryList?projectID=\(projectID)');";
        }
    }
}
