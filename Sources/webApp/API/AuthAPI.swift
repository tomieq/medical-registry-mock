//
//  AuthAPI.swift
//  
//
//  Created by Tomasz Kucharski on 01/12/2021.
//

import Foundation
import Swifter

class AuthAPI: BaseAPI {
    
    
    private let dataStore: DataStore
    
    required init(_ server: HttpServer, dataStore: DataStore) {
        self.dataStore = dataStore

        // MARK: welcome
        server.GET["/"] = { request, responseHeaders in

            return .movedTemporarily("/login")
        }
        
        // MARK: login
        server["/login"] = { request, responseHeaders in

            let formData = request.flatFormData()
            if formData["email"] == "user.one@example.com", formData["password"] == "user1" {
                return .movedTemporarily("/dashboard")
            }
            let template = Template(raw: Resource.getAppResource(relativePath: "templates/main.tpl"))
            let loginView = Template(raw: Resource.getAppResource(relativePath: "templates/loginView.tpl"))
            
            template.assign("page", loginView.output())
            return template.asResponse()
        }
        
        // MARK: dashboard
        server["/dashboard"] = { request, responseHeaders in
            let template = self.getMainTemplate(request)
            let container = Template(raw: Resource.getAppResource(relativePath: "templates/containerView.tpl"))
            container.assign(variables: ["title" : "Strona główna"])
            container.assign(variables: ["title" : "Strona główna"], inNest: "item")
            let cardView = Template(raw: Resource.getAppResource(relativePath: "templates/dashboardCardView.tpl"))
            
            var cardProjects: [String:String] = [:]
            cardProjects["title"] = "Projekty"
            cardProjects["desc"] = "Dodawaj lub modyfikuj dodane przez siebie dane, w swoich projektach lub w projektach innych użytkowników, w których bierzesz udział."
            cardProjects["href"] = "/projects"
            
            var cardUsers: [String:String] = [:]
            cardUsers["title"] = "Użytkownicy"
            cardUsers["desc"] = "Zarządzanie użytkownikami w systemie."
            cardUsers["url"] = "#"
            
            
            cardView.assign(variables: cardProjects, inNest: "card")
            cardView.assign(variables: cardUsers, inNest: "card")
            
            container.assign("page", cardView.output())
            template.assign("page", container.output())
            return template.asResponse()
        }
        
        // MARK: projects
        server["/projects"] = { request, responseHeaders in
            let template = self.getMainTemplate(request)
            let container = Template(raw: Resource.getAppResource(relativePath: "templates/containerView.tpl"))
            container.assign(variables: ["title" : "Projekty"])
            container.assign(variables: ["title" : "Projekty"], inNest: "item")
 
            let list = Template(raw: Resource.getAppResource(relativePath: "templates/projectList.tpl"))

            self.dataStore.projects.forEach { project in
                var data = [String:String]()
                data["name"] = project.name
                data["onclick"] = JSCode.loadBody(url: EditProjectAPI.EditorUrl.editor.url.append("projectID", project.id)).js
                data["status"] = project.status.title
                list.assign(variables: data, inNest: "project")
            }
            
            container.assign("page", list.output())
            template.assign("page", container.output())
            return template.asResponse()
        }
        
        // MARK: add project
        server.GET["/addProject"] = { request, responseHeaders in
            let template = self.getMainTemplate(request)
            let container = Template(raw: Resource.getAppResource(relativePath: "templates/containerView.tpl"))
            container.assign(variables: ["title" : "Projekty"])
            container.assign(variables: ["title" : Template.htmlNode(type: "a", attributes: ["href":"/projects"], content: "Projekty")], inNest: "item")
            container.assign(variables: ["title" : "Dodaj projekt"], inNest: "item")
 
            let wrapper = Template(raw: Resource.getAppResource(relativePath: "templates/projectAddView.tpl"))

            
            let form = Form(url: "/addProject", method: "POST")
                .addInputText(name: "name", label: "Podaj nazwę projektu", labelCSSClass: "text-gray font-22")
                .addSubmit(name: "submit", label: "Dodaj")
            wrapper.assign("form", form.output())
            container.assign("page", wrapper.output())
            template.assign("page", container.output())
            return template.asResponse()
        }
        
        // MARK: add project action
        server.POST["/addProject"]  = { request, responseHeaders in
            let formData = request.flatFormData()
            
            let project = Project()
            project.name = formData["name"] ?? "brak nazwy"
            self.dataStore.projects.append(project)
            return .movedPermanently("/projects")
        }
        
        // MARK: delete project action
        server.GET["/deleteProject"]  = { request, responseHeaders in
            if let id = request.queryParam("projectID") {
                self.dataStore.projects.removeAll{ $0.id != id }
            }
            return .movedPermanently("/projectList")
        }
        
    }
}
