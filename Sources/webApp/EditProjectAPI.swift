//
//  EditProjectAPI.swift
//  
//
//  Created by Tomasz Kucharski on 01/12/2021.
//

import Foundation
import Swifter

class EditProjectAPI {
    
    private let dataStore: DataStore
    
    init(_ server: HttpServer, dataStore: DataStore) {
        self.dataStore = dataStore

        // MARK: /toggleGroupCanBeCopied
        server.GET["/toggleGroupCanBeCopied"] = { request, responseHeaders in
            guard let project = (self.dataStore.projects.filter{ $0.id == request.queryParam("projectID") }.first) else {
                return .notFound
            }
            guard let groupID = request.queryParam("groupID"), let group = project.findGroup(id: groupID) else { return .notFound }
            group.canBeCopied = Bool(request.queryParam("value") ?? "false") ?? false
            return .noContent
        }
        
        // MARK: /confirmGroupRemoval
        server.GET["/confirmGroupRemoval"]  = { request, responseHeaders in
            guard let projectID = request.queryParam("projectID") else { return .badRequest(nil) }
            guard let groupID = request.queryParam("groupID") else { return .badRequest(nil) }
            let name = self.dataStore.projects.first{ $0.id == projectID }?.findGroup(id: groupID)?.name ?? ""

            var html = "Czy na pewno chcesz usunąć grupę <b>\(name)</b>?<br><br>"
            html.append("<a href='/editProject?projectID=\(projectID)&action=deleteGroup&groupID=\(groupID)' class='btn btn-purple'>Potwierdzam</a> ")
            html.append("<a href='#' onclick='closeLayer()' class='btn btn-purple-negative'>Anuluj</a>")
            return .ok(.html(self.wrapAsLayer(width: 500, title: "Usuwanie grupy", content: html)))
        }
        
        // MARK: /addGroup
        server.GET["/addGroup"]  = { request, responseHeaders in
            guard let projectID = request.queryParam("projectID") else { return .badRequest(nil) }
            guard let activeGroupID = request.queryParam("activeGroupID") else { return .badRequest(nil) }

            let form = Form(url: "/addGroup", method: "POST")
                .addInputText(name: "name", label: "Nazwa Grupy", labelCSSClass: "text-gray font-13")
                .addHidden(name: "projectID", value: projectID)
                .addHidden(name: "groupID", value: activeGroupID)
                .addSubmit(name: "submit", label: "Dodaj")
                .addRaw(html: "<a href='#' onclick='closeLayer()' class='btn btn-purple-negative'>Anuluj</a>")
            return .ok(.html(self.wrapAsLayer(width: 500, title: "Dodaj grupę", content: form.output())))
        }
        
        server.POST["/addGroup"] = { request, responseHeaders in
            let formData = request.flatFormData()
            guard let project = (self.dataStore.projects.filter{ $0.id == formData["projectID"] }.first) else {
                return .notFound
            }
            var activeGroup: ProjectGroup?
            if let groupID = formData["groupID"] {
                activeGroup = project.findGroup(id: groupID)
            }
            
            let group = ProjectGroup()
            group.name = "bez nazwy"
            if let name = formData["name"], !name.isEmpty {
                group.name = name
            }
            if let parentGroup = activeGroup {
                parentGroup.groups.append(group)
            } else {
                project.groups.append(group)
            }
            
            return .movedTemporarily("/editProject?projectID=\(project.id)&groupID=\(activeGroup?.id ?? group.id)")
        }
        
        // MARK: /renameGroup
        server.GET["/renameGroup"]  = { request, responseHeaders in
            guard let projectID = request.queryParam("projectID") else { return .badRequest(nil) }
            guard let groupID = request.queryParam("groupID") else { return .badRequest(nil) }
            let name = self.dataStore.projects.first{ $0.id == projectID }?.findGroup(id: groupID)?.name ?? ""

            let form = Form(url: "/renameGroup", method: "POST")
                .addInputText(name: "name", label: "Nazwa Grupy", value: name, labelCSSClass: "text-gray font-13")
                .addHidden(name: "projectID", value: projectID)
                .addHidden(name: "groupID", value: groupID)
                .addSubmit(name: "submit", label: "Zmień")
                .addRaw(html: "<a href='#' onclick='closeLayer()' class='btn btn-purple-negative'>Anuluj</a>")

            return .ok(.html(self.wrapAsLayer(width: 500, title: "Zmień nazwę grupy", content: form.output())))
        }
        
        server.POST["/renameGroup"] = { request, responseHeaders in
            let formData = request.flatFormData()
            guard let project = (self.dataStore.projects.filter{ $0.id == formData["projectID"] }.first) else {
                return .notFound
            }
            guard let groupID = formData["groupID"], let group = project.findGroup(id: groupID) else { return .notFound }
            
            group.name = "bez nazwy"
            if let name = formData["name"], !name.isEmpty {
                group.name = name
            }
            return .movedTemporarily("/editProject?projectID=\(project.id)&groupID=\(group.id)")
        }
    }
    
    
    
    private func wrapAsLayer(width: Int, title: String, content: String) -> String {
        let template = Template(raw: Resource.getAppResource(relativePath: "templates/layer.tpl"))
        template.assign(variables: ["title": title, "content": content, "width": "\(width)"])
        return template.output()
    }
}
