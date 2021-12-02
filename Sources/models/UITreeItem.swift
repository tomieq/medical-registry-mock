//
//  UITreeItem.swift
//  
//
//  Created by Tomasz Kucharski on 27/09/2021.
//

import Foundation

struct UITreeItem {
    let project: Project
    let group: ProjectGroup
    let nestLevel: Int
    let isActive: Bool
    let hasChildren: Bool
    
    func getTemplateVariables() -> [String:String] {
        var data: [String:String] = [:]
        data["onclick"] = JSCode.editorLoadGroup(projectID: project.id, groupID: group.id).js
        data["name"] = self.group.name
        data["css"] = self.isActive ? "treeItemActive" : "treeItemInactive"
        data["margin"] = "\(self.nestLevel * 20)"
        data["side"] = self.hasChildren ? "down" : "right"
        data["icon"] = self.hasChildren ? "layers" : "file-text"
        return data
    }
}
