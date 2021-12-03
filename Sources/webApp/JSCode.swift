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
    case loadBody(url: String)
    case loadPage(url: String)
    case loadScript(url: String)
    case loadAsLayer(url: String)
    case closeLayer
    case editorLoadGroup(projectID: String, groupID: String)
    case editorLoadTreeMenu(projectID: String, groupID: String)
    case editorLoadGroupTable(projectID: String, groupID: String)
    case editorLoadCardsMenu(projectID: String, groupID: String)
    case editorLoadDictionaryList(projectID: String)
}

extension JSCode {
    var js: String {
        switch self {
        case .loadBody(let url):
            return "$('body').load('\(url)');"
        case .loadPage(let url):
            return "$('#page').load('\(url)');"
        case .loadScript(let url):
            return "$.getScript('\(url)');"
        case .loadAsLayer(let url):
            return "openLayer('\(url)');"
        case .closeLayer:
            return "closeLayer();";
        case .editorLoadGroup(let projectID, let groupID):
            return [
                JSCode.editorLoadTreeMenu(projectID: projectID, groupID: groupID),
                JSCode.editorLoadGroupTable(projectID: projectID, groupID: groupID),
                JSCode.editorLoadCardsMenu(projectID: projectID, groupID: groupID)
            ].map{$0.js}.joined(separator: "")
        case .editorLoadTreeMenu(let projectID, let groupID):
            return "$('#tree').load('/editTreeMenu?projectID=\(projectID)&groupID=\(groupID)');";
        case .editorLoadGroupTable(let projectID, let groupID):
            return "$('#contentTable').load('/editorTable?projectID=\(projectID)&groupID=\(groupID)');";
        case .editorLoadCardsMenu(let projectID, let groupID):
            return "$('#cards').load('/editCardsMenu?projectID=\(projectID)&groupID=\(groupID)');";
        case .editorLoadDictionaryList(let projectID):
            return "$('#contentTable').load('/dictionaryList?projectID=\(projectID)');";
        }
    }
}
