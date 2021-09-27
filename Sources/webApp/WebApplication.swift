//
//  WebApplication.swift
//  
//
//  Created by Tomasz Kucharski on 12/03/2021.
//

import Foundation
import Swifter

class WebApplication {
    
    var projects: [Project] = []
    
    init(_ server: HttpServer) {
        
        self.initConfiguration()
        
        server.middleware.append { request, responseHeaders in
            request.disableKeepAlive = true
            //responseHeaders.addHeader("Cache-Control", "max-age=1, must-revalidate")
            Logger.debug("Incoming", request.path)
            return nil
        }
        
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
        
        // MARK: reset
        server.GET["/reset"] = { request, responseHeaders in

            self.projects = []
            self.initConfiguration()
            return .movedPermanently("/projectList")
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
            cardProjects["url"] = "/projects"
            
            var cardNewProject: [String:String] = [:]
            cardNewProject["title"] = "Nowy projekt"
            cardNewProject["desc"] = "Stwórz nowy projekt, w którym będziesz mógł zbierać dane o pacjentach i zaprosić innych użytkowników do kontrybuowania w projekcie."
            cardNewProject["url"] = "#"
            
            var cardEditProject: [String:String] = [:]
            cardEditProject["title"] = "Edytuj istniejący projekt"
            cardEditProject["desc"] = "Edytuj istniejący projekt, który jeszcze nie wystartował."
            cardEditProject["url"] = "#"
            
            cardView.assign(variables: cardProjects, inNest: "card")
            cardView.assign(variables: cardNewProject, inNest: "card")
            cardView.assign(variables: cardEditProject, inNest: "card")
            
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

            self.projects.forEach { project in
                var data = [String:String]()
                data["name"] = project.name
                data["projectID"] = project.id
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
            self.projects.append(project)
            return .movedPermanently("/projects")
        }
        
        // MARK: delete project action
        server.GET["/deleteProject"]  = { request, responseHeaders in
            if let id = request.queryParam("projectID") {
                self.projects = self.projects.filter { $0.id != id }
            }
            return .movedPermanently("/projectList")
        }
        
        // MARK: edit project
        server["editProject"] = { request, responseHeaders in
            
            guard let project = (self.projects.filter{ $0.id == request.queryParam("projectID") }.first) else {
                return .notFound
            }
            
            var activeGroup: ProjectGroup?
            if let groupID = request.queryParam("groupID") {
                activeGroup = project.findGroup(id: groupID)
            }
            
            if let deleteGroupID = request.queryParam("deleteGroupID") {
                project.groups = project.groups.filter { $0.id != deleteGroupID }
            }
            
            let url = "/editProject?projectID=\(project.id)"
            let template = self.getMainTemplate(request)
            let userBadge = Template(raw: Resource.getAppResource(relativePath: "templates/userBadgeView.tpl"))
            let avatarUrl = "https://www.gravatar.com/avatar/5ede5914f659676c0295d5282c1c9df9"
            userBadge.assign("avatarUrl", avatarUrl)
            template.assign("userBadge", userBadge.output())
            
            let container = Template(raw: Resource.getAppResource(relativePath: "templates/containerView.tpl"))
            container.assign(variables: ["title" : "Projekty"])
            container.assign(variables: ["title" : Template.htmlNode(type: "a", attributes: ["href":"/projects"], content: "Projekty")], inNest: "item")
            container.assign(variables: ["title" : "Dodaj projekt"], inNest: "item")
            
            let page = Template(raw: Resource.getAppResource(relativePath: "templates/projectEdit.tpl"))

            self.addCardsToProjectEditTemplate(page, activeGroup: activeGroup, editProjectUrl: url)
            
            if let action = request.queryParam("action") {
                switch action {
                case "addGroup":
                    let form = Form(url: "/addGroup", method: "POST")
                        .addInputText(name: "name", label: "Nazwa Grupy", labelCSSClass: "text-gray font-13")
                        .addHidden(name: "projectID", value: project.id)
                        .addHidden(name: "groupID", value: activeGroup?.id ?? "")
                        .addSubmit(name: "submit", label: "Dodaj")
                        .addRaw(html: "<a href='\(url)' class='btn btn-purple-negative'>Anuluj</a>")
                    page.assign(variables: ["form":form.output()], inNest: "addGroup")
                case "renameGroup":
                    guard let group = activeGroup else { return .notFound }
                    let form = Form(url: "/renameGroup", method: "POST")
                        .addInputText(name: "name", label: "Nazwa Grupy", value: group.name, labelCSSClass: "text-gray font-13")
                        .addHidden(name: "projectID", value: project.id)
                        .addHidden(name: "groupID", value: group.id)
                        .addSubmit(name: "submit", label: "Zmień")
                        .addRaw(html: "<a href='\(url)' class='btn btn-purple-negative'>Anuluj</a>")
                    page.assign(variables: ["form":form.output()], inNest: "addGroup")
                default:
                    break
                }
            }
            
            
            for group in project.groups {
                self.addGroupToTreeMenu(page, group: group, activeGroup: activeGroup, editProjectUrl: url)
            }
            
            for group in activeGroup?.groups ?? project.groups {
                var data: [String:String] = [:]
                data["projectID"] = project.id
                data["name"] = group.name
                data["groupID"] = group.id
                data["deleteURL"] = "\(url)&groupID=\(group.id)&action=deleteGroup"
                data["renameURL"] = "\(url)&groupID=\(group.id)&action=renameGroup"
                data["css"] = group.id == activeGroup?.id ? "treeItemActive" : "treeItemInactive"
                page.assign(variables: data, inNest: "groupItem")
            }
            var templateVariables: [String:String] = [:]
            templateVariables["projectName"] = project.name
            templateVariables["projectID"] = project.id
            templateVariables["css"] = activeGroup == nil ? "treeItemActive" : "treeItemInactive"
            page.assign(variables: templateVariables)
            
            container.assign("page", page.output())
            template.assign("page", container.output())
            return template.asResponse()
        }
        
        server.POST["/addGroup"] = { request, responseHeaders in
            let formData = request.flatFormData()
            guard let project = (self.projects.filter{ $0.id == formData["projectID"] }.first) else {
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
        
        server.POST["/renameGroup"] = { request, responseHeaders in
            let formData = request.flatFormData()
            guard let project = (self.projects.filter{ $0.id == formData["projectID"] }.first) else {
                return .notFound
            }
            guard let groupID = formData["groupID"], let group = project.findGroup(id: groupID) else { return .notFound }
            
            group.name = "bez nazwy"
            if let name = formData["name"], !name.isEmpty {
                group.name = name
            }
            return .movedTemporarily("/editProject?projectID=\(project.id)&groupID=\(group.id)")
        }
        
        // MARK: delete question action
        server.GET["/deleteQuestion"] = { request, responseHeaders in
            
            if let project = (self.projects.filter{ $0.id == request.queryParam("projectID") }.first) {
                project.questions = project.questions.filter{ $0.id != request.queryParam("questionID") }
            }
            return .movedPermanently("/editProject?projectID=\(request.queryParam("projectID") ?? "")")
        }
        
        // MARK: edit question form
        server.GET["/editQuestion"] = { request, responseHeaders in
            
            guard let project = (self.projects.filter{ $0.id == request.queryParam("projectID") }.first),
               let question = (project.questions.filter{ $0.id == request.queryParam("questionID") }.first) else {
                return .notFound
            }
            let template = Template(raw: Resource.getAppResource(relativePath: "templates/main.tpl"))
            let navi = Template(raw: Resource.getAppResource(relativePath: "templates/projectConfigNavi.tpl"))

            let form = Form(url: "/editQuestion", method: "POST")
                .addInputText(name: "label", label: "Pytanie", value: question.label ?? "")
                .addSeparator(txt: "Typ: \(question.dataType.title)")
                .addHidden(name: "projectID", value: project.id)
                .addHidden(name: "questionID", value: question.id)
            
            switch question.dataType {
            case .number:
                form.addInputText(name: "minValue", label: "Wartość minimalna", value: question.minValue.toString())
                    .addInputText(name: "maxValue", label: "Wartość maksymalna", value: question.maxValue.toString())
            case .dictionary:
                
                form.addRadio(name: "dictionaryID", label: "Wybierz zbiór danych słownikowych z jakich można wybrać odpowiedź", options: project.dictionaries.map{ FormRadioModel(label: $0.name, value: $0.id) }, checked: question.dictionaryID)
            default:
                break
            }
            form.addSubmit(name: "submit", label: "Zapisz")

            navi.assign("title", "Edycja pytania")
            navi.assign("page", form.output())

            template.assign("page", navi.output())
            return template.asResponse()
        }
        
        // MARK: edit question action
        server.POST["/editQuestion"] = { request, responseHeaders in

            guard let project = (self.projects.filter{ $0.id == request.queryParam("projectID") }.first),
               let question = (project.questions.filter{ $0.id == request.queryParam("questionID") }.first) else {
                return .notFound
            }
            let formData = request.flatFormData()
            question.label = formData["label"]
            question.maxValue = formData["maxValue"]?.toInt()
            question.minValue = formData["minValue"]?.toInt()
            question.dictionaryID = formData["dictionaryID"]
            
            return .movedPermanently("editProject?projectID=\(project.id)")
        }
        
        // MARK: add question form
        server.GET["addQuestion"] = { request, responseHeaders in
            
            guard let project = (self.projects.filter{ $0.id == request.queryParam("projectID") }.first) else {
                return .notFound
            }
            
            let template = Template(raw: Resource.getAppResource(relativePath: "templates/main.tpl"))
            let navi = Template(raw: Resource.getAppResource(relativePath: "templates/projectConfigNavi.tpl"))

            let form = Form(url: "/addQuestion", method: "POST")
                .addInputText(name: "label", label: "Pytanie")
                .addRadio(name: "type", label: "Typ odpowiedzi", options: ProjectQuestionType.allCases.map{ FormRadioModel(label: $0.title, value: $0.rawValue) })
                .addHidden(name: "projectID", value: project.id)
                .addSubmit(name: "submit", label: "Dalej")

            navi.assign("title", "Utwórz nowe pytanie")
            navi.assign("page", form.output())

            template.assign("page", navi.output())
            return template.asResponse()
        }
        
        // MARK: add question action & form step 2
        server.POST["addQuestion"] = { request, responseHeaders in
            
            guard let project = (self.projects.filter{ $0.id == request.queryParam("projectID") }.first) else {
                return .notFound
            }
            let formData = request.flatFormData()
            guard let questionType = ProjectQuestionType(rawValue: formData["type"] ?? "") else {
                return .movedPermanently("editProject?projectID=\(project.id)")
            }
            
            let template = Template(raw: Resource.getAppResource(relativePath: "templates/main.tpl"))
            let navi = Template(raw: Resource.getAppResource(relativePath: "templates/projectConfigNavi.tpl"))
            
            if questionType == .number && formData["step"] != "2" {
                let form = Form(url: "/addQuestion", method: "POST")
                    .addHidden(name: "label", value: formData["label"] ?? "")
                    .addHidden(name: "type", value: formData["type"] ?? "")
                    .addHidden(name: "projectID", value: project.id)
                    .addHidden(name: "step", value: "2")
                    .addInputText(name: "minValue", label: "Wartość minimalna")
                    .addInputText(name: "maxValue", label: "Wartość maksymalna")
                    .addSubmit(name: "submit", label: "Dodaj")

                navi.assign("title", "Utwórz nowe pytanie - Krok 2")
                navi.assign("page", form.output())

                template.assign("page", navi.output())
                return template.asResponse()
            }
            if questionType == .dictionary && formData["step"] != "2" {
                let form = Form(url: "/addQuestion", method: "POST")
                    .addHidden(name: "label", value: formData["label"] ?? "")
                    .addHidden(name: "type", value: formData["type"] ?? "")
                    .addHidden(name: "projectID", value: project.id)
                    .addHidden(name: "step", value: "2")
                    .addRadio(name: "dictionaryID", label: "Wybierz zbiór danych słownikowych z jakich można wybrać odpowiedź", options: project.dictionaries.map{ FormRadioModel(label: $0.name, value: $0.id) })
                    .addSubmit(name: "submit", label: "Dodaj")

                navi.assign("title", "Utwórz nowe pytanie - Krok 2")
                navi.assign("page", form.output())

                template.assign("page", navi.output())
                return template.asResponse()
            }
            
            let question = ProjectQuestion()
            question.label = formData["label"]
            question.dataType = questionType
            question.maxValue = formData["maxValue"]?.toInt()
            question.minValue = formData["minValue"]?.toInt()
            question.dictionaryID = formData["dictionaryID"]

            project.questions.append(question)
            return .movedPermanently("editProject?projectID=\(project.id)")
        }
        
        // MARK: assign users form
        server.GET["/assignUsers"] = { request, responseHeaders in
            
            guard let project = (self.projects.filter{ $0.id == request.queryParam("projectID") }.first) else {
                return .notFound
            }
            
            let template = Template(raw: Resource.getAppResource(relativePath: "templates/main.tpl"))
            let navi = Template(raw: Resource.getAppResource(relativePath: "templates/projectConfigNavi.tpl"))

            let form = Form(url: "/assignUsers", method: "POST")
                .addHidden(name: "projectID", value: project.id)
            
            (1...10).forEach { n in
                form.addCheckbox(name: "user\(n)", value: "1", label: "dr Jan Kowalski \(n)")
            }
            form.addSubmit(name: "submit", label: "Przypisz")

            navi.assign("title", "Przypisz pracowników do projektu")
            navi.assign("page", form.output())

            template.assign("page", navi.output())
            return template.asResponse()
        }
        
        // MARK: assign users action
        server.POST["/assignUsers"] = { request, responseHeaders in

            guard let project = (self.projects.filter{ $0.id == request.queryParam("projectID") }.first) else {
                return .notFound
            }
            // this is just a stub, no implementation for demo
            return .movedPermanently("editProject?projectID=\(project.id)")
        }
        
        // MARK: add dictionary form
        server.GET["/addDictionary"] = { request, responseHeaders in
            
            guard let project = (self.projects.filter{ $0.id == request.queryParam("projectID") }.first) else {
                return .notFound
            }
            
            let template = Template(raw: Resource.getAppResource(relativePath: "templates/main.tpl"))
            let navi = Template(raw: Resource.getAppResource(relativePath: "templates/projectConfigNavi.tpl"))

            let form = Form(url: "/addDictionary", method: "POST")
                .addHidden(name: "projectID", value: project.id)
                .addInputText(name: "name", label: "Nazwa słownika")
                .addSeparator(txt: "Podaj warości, które użytkownik będzie miał do wyboru. Wpisz tyle pól ile trzeba, pozostałe zostaw puste.")
            
            (1...10).forEach { n in
                form.addInputText(name: "option\(n)", label: "Wartość wyboru \(n)")
            }
            form.addSubmit(name: "submit", label: "Dodaj")

            navi.assign("title", "Utwórz nowy słownik")
            navi.assign("page", form.output())
            
            template.assign("page", navi.output())
            return template.asResponse()
        }
        
        // MARK: add dictionary action
        server.POST["/addDictionary"] = { request, responseHeaders in

            guard let project = (self.projects.filter{ $0.id == request.queryParam("projectID") }.first) else {
                return .notFound
            }
            let formData = request.flatFormData()
            let dictionary = ProjectDictionary()
            dictionary.name = formData["name"] ?? "brak nazwy"
            (1...10).forEach { n in
                if let title = formData["option\(n)"]?.trimmingCharacters(in: .whitespaces), !title.isEmpty {
                    let option = ProjectDictionaryOption()
                    option.title = title
                    dictionary.options.append(option)
                }
            }
            project.dictionaries.append(dictionary)
            return .movedPermanently("editProject?projectID=\(project.id)")
        }
        
        // MARK: delete dictionary action
        server.GET["/deleteDictionary"] = { request, responseHeaders in

            guard let project = (self.projects.filter{ $0.id == request.queryParam("projectID") }.first),
                  let dictionary = (project.dictionaries.filter{ $0.id == request.queryParam("dictionaryID") }.first) else {
                return .notFound
            }
            for question in project.questions {
                if question.dictionaryID == dictionary.id {
                    return .movedPermanently("editProject?projectID=\(project.id)")
                }
            }
            project.dictionaries.remove(object: dictionary)
            return .movedPermanently("editProject?projectID=\(project.id)")
        }
        
        // MARK: active projects list
        server.GET["/myProjects"] = { request, responseHeaders in

            let template = Template(raw: Resource.getAppResource(relativePath: "templates/main.tpl"))
            let navi = Template(raw: Resource.getAppResource(relativePath: "templates/myProjectsNavi.tpl"))
            let list = Template(raw: Resource.getAppResource(relativePath: "templates/myProjectsList.tpl"))

            self.projects.forEach { project in
                var data = [String:String]()
                data["name"] = project.name
                data["projectID"] = project.id
                list.assign(variables: data, inNest: "project")
            }

            navi.assign("title", "Moje projekty")
            navi.assign("page", list.output())
            
            template.assign("page", navi.output())
            return template.asResponse()
        }
        
        // MARK: add data to project form
        server.GET["/addDataToProject"] = { request, responseHeaders in
            
            guard let project = (self.projects.filter{ $0.id == request.queryParam("projectID") }.first) else {
                return .notFound
            }
            
            let template = Template(raw: Resource.getAppResource(relativePath: "templates/main.tpl"))
            let navi = Template(raw: Resource.getAppResource(relativePath: "templates/myProjectsNavi.tpl"))

            let form = Form(url: "/addDataToProject", method: "POST")
                .addHidden(name: "projectID", value: project.id)
                
            project.questions.forEach { question in
                switch question.dataType {
                
                case .unknown:
                    return
                case .text:
                    form.addInputText(name: question.id, label: question.label ?? "-")
                case .longText:
                    form.addTextarea(name: question.id, label: question.label ?? "-")
                case .number:
                    form.addInputText(name: question.id, label: question.label ?? "-")
                case .dictionary:
                    guard let dictionary = (project.dictionaries.filter{ $0.id == question.dictionaryID }.first) else { return }
                    form.addRadio(name: question.id, label: question.label ?? "-", options: dictionary.options.map{ FormRadioModel(label: $0.title, value: $0.id) })
                }
            }
            form.addSubmit(name: "submit", label: "Dodaj")

            navi.assign("title", "Dodaj nowe dane w \(project.name)")
            navi.assign("page", form.output())

            template.assign("page", navi.output())
            return template.asResponse()
        }
        
        // MARK: add data to project action
        server.POST["/addDataToProject"] = { request, responseHeaders in
            
            guard let project = (self.projects.filter{ $0.id == request.queryParam("projectID") }.first) else {
                return .notFound
            }
            let formData = request.flatFormData()
            
            let dataEntry = DataEntry(ownerID: "userID")
                
            project.questions.forEach { question in
                
                if let answer = formData[question.id] {
                    let dataEntryAnswer = DataEntryAnswer()
                    dataEntryAnswer.questionID = question.id
                    dataEntryAnswer.value = answer
                    dataEntry.answers.append(dataEntryAnswer)
                }
            }
            project.entries.append(dataEntry)
            
            return .movedPermanently("browseProjectData?projectID=\(project.id)")
        }
        
        // MARK: delete data from project action
        server.GET["/deleteDataFromProject"] = { request, responseHeaders in
            
            guard let project = (self.projects.filter{ $0.id == request.queryParam("projectID") }.first),
                  let data = (project.entries.filter{ $0.id == request.queryParam("dataID") }.first) else {
                return .notFound
            }
            project.entries.remove(object: data)
            
            return .movedPermanently("browseProjectData?projectID=\(project.id)")
            
        }
        
        // MARK: browse data in project - admin
        server.GET["/browseProjectDataAdmin"] = { request, responseHeaders in

            guard let project = (self.projects.filter{ $0.id == request.queryParam("projectID") }.first) else {
                return .notFound
            }
            
            let template = Template(raw: Resource.getAppResource(relativePath: "templates/main.tpl"))
            let navi = Template(raw: Resource.getAppResource(relativePath: "templates/projectConfigNavi.tpl"))
            
            navi.assign("title", "Dane")
            navi.assign("page", self.prepareProjectDataTable(project, withAddButton: false))
            
            template.assign("page", navi.output())
            return template.asResponse()
            
        }
        
        // MARK: browse data in project - user
        server.GET["/browseProjectData"] = { request, responseHeaders in

            guard let project = (self.projects.filter{ $0.id == request.queryParam("projectID") }.first) else {
                return .notFound
            }
            
            let template = Template(raw: Resource.getAppResource(relativePath: "templates/main.tpl"))
            let navi = Template(raw: Resource.getAppResource(relativePath: "templates/myProjectsNavi.tpl"))
            
            navi.assign("title", "Dane")
            navi.assign("page", self.prepareProjectDataTable(project, withAddButton: true))
            
            template.assign("page", navi.output())
            return template.asResponse()
            
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
    
    private func prepareProjectDataTable(_ project: Project, withAddButton: Bool) -> String {
        let browser = Template(raw: Resource.getAppResource(relativePath: "templates/browseProject.tpl"))

        if withAddButton {
            browser.assign(variables: nil, inNest: "addDataButton")
        }
        browser.assign("projectID", project.id)
        project.questions.forEach { question in
            var variables: [String:String] = [:]
            variables["name"] = question.label ?? "-"
            browser.assign(variables: variables, inNest: "header")
        }

        project.entries.forEach { data in
            var columns = ""
            
            for question in project.questions {
                let value = data.answers.filter{ $0.questionID == question.id }.first?.value ?? ""
                switch question.dataType {
                case .dictionary:
                    let dictionaryValue = project.dictionaries
                        .filter { $0.id == question.dictionaryID }
                        .first?.options
                        .filter{ $0.id == value }
                        .first?.title ?? ""
                    columns.append("<td>\(dictionaryValue)</td>")
                default:
                    columns.append("<td>\(value)</td>")
                }
            }
            
            var variables: [String:String] = [:]
            variables["columns"] = columns
            variables["projectID"] = project.id
            variables["dataID"] = data.id
            browser.assign(variables: variables, inNest: "row")
        }
        return browser.output()
    }
    
    private func initConfiguration() {
        let sampleProject = Project()
        sampleProject.name = "Badanie testowe"
        
        let q1 = ProjectQuestion()
        q1.dataType = .number
        q1.label = "Numer pacjenta"
        sampleProject.questions.append(q1)
        
        let q2 = ProjectQuestion()
        q2.dataType = .text
        q2.label = "Inicjały"
        sampleProject.questions.append(q2)
        
        
        let q3 = ProjectQuestion()
        q3.dataType = .number
        q3.label = "Rok urodzenia"
        q3.minValue = 1920
        q3.maxValue = 2050
        sampleProject.questions.append(q3)
        
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
        
        
        
        let q4 = ProjectQuestion()
        q4.dataType = .dictionary
        q4.label = "Przebył COVID-19"
        q4.dictionaryID = dict.id
        sampleProject.questions.append(q4)
        
        let q5 = ProjectQuestion()
        q5.dataType = .longText
        q5.label = "Rozpoznanie"
        sampleProject.questions.append(q5)
        
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
        
        let q6 = ProjectQuestion()
        q6.dataType = .dictionary
        q6.label = "Województwo"
        q6.dictionaryID = dict2.id
        sampleProject.questions.append(q6)
        
        self.projects.append(sampleProject)
    }
    
    private func getMainTemplate(_ request: HttpRequest) -> Template {
        let template = Template(raw: Resource.getAppResource(relativePath: "templates/main.tpl"))
        let userBadge = Template(raw: Resource.getAppResource(relativePath: "templates/userBadgeView.tpl"))
        let avatarUrl = "https://www.gravatar.com/avatar/5ede5914f659676c0295d5282c1c9df9"
        userBadge.assign("avatarUrl", avatarUrl)
        template.assign("userBadge", userBadge.output())
        return template
    }
    
    private func addCardsToProjectEditTemplate(_ page: Template, activeGroup: ProjectGroup?, editProjectUrl: String) {
        let cardView = Template(raw: Resource.getAppResource(relativePath: "templates/dashboardCardView.tpl"))
        
        var cardGroup: [String:String] = [:]
        cardGroup["title"] = "Dodaj grupę/podgrupę"
        cardGroup["desc"] = "Dodaj nową grupę w danej kategorii pytań"
        cardGroup["url"] = "\(editProjectUrl)&groupID=\(activeGroup?.id ?? "")&action=addGroup"
        
        var cardParameter: [String:String] = [:]
        cardParameter["title"] = "Dodaj parametr"
        cardParameter["desc"] = "Pytanie możn dodać tylko wtedy, gdy w danej podgrupie nie są dodane podgrupy pytań"
        cardParameter["url"] = "#"
        
        var cardDictionary: [String:String] = [:]
        cardDictionary["title"] = "Edytuj słowniki"
        cardDictionary["desc"] = "Stwórz słowniki, w których możesz zdefiniować specyficzne odpowiedzi na pytania"
        cardDictionary["url"] = "#"
        
        cardView.assign(variables: cardGroup, inNest: "card")
        cardView.assign(variables: cardParameter, inNest: "card")
        cardView.assign(variables: cardDictionary, inNest: "card")
        
        page.assign("cards", cardView.output())
    }
    
    private func addGroupToTreeMenu(_ template: Template, group: ProjectGroup, activeGroup: ProjectGroup?, level: Int = 1, editProjectUrl: String) {
        
        let url = "\(editProjectUrl)&groupID=\(group.id)"
        let uiTreeItem = UITreeItem(name: group.name, nestLevel: level, isActive: group.id == activeGroup?.id, url: url, hasChildren: !group.groups.isEmpty)
        template.assign(variables: uiTreeItem.getTemplateVariables(), inNest: "treeGroup")
        let level = level + 1
        group.groups.forEach{ self.addGroupToTreeMenu(template, group: $0, activeGroup: activeGroup, level: level, editProjectUrl: editProjectUrl) }
    }
}
