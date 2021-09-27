//
//  UITreeItem.swift
//  
//
//  Created by Tomasz Kucharski on 27/09/2021.
//

import Foundation

struct UITreeItem {
    let name: String
    let nestLevel: Int
    let isActive: Bool
    let url: String
    let hasChildren: Bool
    
    func getTemplateVariables() -> [String:String] {
        var data: [String:String] = [:]
        data["url"] = self.url
        data["name"] = self.name
        data["css"] = self.isActive ? "treeItemActive" : "treeItemInactive"
        data["margin"] = "\(self.nestLevel * 20)"
        data["side"] = self.hasChildren ? "down" : "right"
        data["icon"] = self.hasChildren ? "layers" : "file-text"
        return data
    }
}
