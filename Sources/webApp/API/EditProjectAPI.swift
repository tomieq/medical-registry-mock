//
//  EditProjectAPI.swift
//  
//
//  Created by Tomasz Kucharski on 01/12/2021.
//

import Foundation
import Swifter

class EditProjectAPI: BaseAPI {
    
    private let dataStore: DataStore
    
    required init(_ server: HttpServer, dataStore: DataStore) {
        self.dataStore = dataStore

        
        // MARK: /editProject
        server["/editProject"] = { request, responseHeaders in
            
            guard let project = (self.dataStore.projects.first{ $0.id == request.queryParam("projectID") }) else {
                return .notFound
            }
            
            var activeGroup: ProjectGroup?
            if let groupID = request.queryParam("groupID") {
                activeGroup = project.findGroup(id: groupID)
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
            container.assign(variables: ["title" : project.name], inNest: "item")
            
            let page = Template(raw: Resource.getAppResource(relativePath: "templates/projectEdit.tpl"))

            
            if let action = request.queryParam("action") {
                switch action {
                case "deleteGroup":
                    project.removeGroup(id: activeGroup?.id ?? "")
                    activeGroup = nil
                case "deleteQuestion":
                    activeGroup?.questions = activeGroup?.questions.filter{ $0.id != request.queryParam("questionID") } ?? []
                case "addParameter":
                    if let response = self.addParameter(request: request, activeGroup: activeGroup, url: url, project: project, page: page) {
                        return response
                    }

                case "dictionaryList":
                    if let response = self.addDictionary(request: request, page: page, url: url, project: project) {
                        return response
                    }
                    self.dictionaryPreview(request: request, page: page, project: project)
                    let list = Template(raw: Resource.getAppResource(relativePath: "templates/dictionaryList.tpl"))
                    list.assign("projectID", project.id)
                    for dictionary in project.dictionaries {
                        var data: [String:String] = [:]
                        data["name"] = dictionary.name
                        data["projectID"] = project.id
                        data["dictionaryID"] = dictionary.id
                        list.assign(variables: data, inNest: "dictionary")
                    }
                    page.assign("table", list.output())
                default:
                    break
                }
            }
            self.addCardsToProjectEditTemplate(page, activeGroup: activeGroup, projectID: project.id)

            
            if let group = activeGroup, group.questions.count > 0 {
                let table = Template(raw: Resource.getAppResource(relativePath: "templates/projectEditQuestionList.tpl"))
                for question in activeGroup?.questions ?? [] {
                    var data: [String:String] = [:]
                    data["name"] = question.label
                    data["createDate"] = question.createDate.getFormattedDate(format: "yyyy-MM-dd")
                    data["type"] = question.dataType.title
                    if let unit = question.unit {
                        data["unit"] = Template.htmlNode(type: "span", attributes: ["class":"label label-green"], content: unit)
                    }
                    data["questionID"] = question.id
                    data["deleteURL"] = "\(url)&groupID=\(group.id)&questionID=\(question.id)&action=deleteQuestion"
                    data["editURL"] = "\(url)&groupID=\(group.id)&action=editQuestion"
                    
                    switch question.dataType {
                    case .number:
                        data["type"]?.append(" (\(question.minValue.toOptionalString() ?? "-∞") do \(question.maxValue.toOptionalString() ?? "+∞"))")
                    case .dictionary:
                        break
                    default:
                        break
                    }
                    table.assign(variables: data, inNest: "question")
                }
                page.assign("table", table.output())
            } else {
                let table = Template(raw: Resource.getAppResource(relativePath: "templates/projectEditGroupList.tpl"))
                let js = Template(raw: Resource.getAppResource(relativePath: "templates/projectEditGroupList.js.tpl"))
                template.assign(variables: ["code":js.output()], inNest: "jsOnReadyCode")
                for group in activeGroup?.groups ?? project.groups {
                    var data: [String:String] = [:]
                    data["projectID"] = project.id
                    data["name"] = group.name
                    data["groupID"] = group.id
                    data["deleteURL"] = "/confirmGroupRemoval?groupID=\(group.id)&projectID=\(project.id)"
                    data["renameURL"] = "/renameGroup?groupID=\(group.id)&projectID=\(project.id)"
                    data["toggleCopyUrl"] = "/toggleGroupCanBeCopied?projectID=\(project.id)&groupID=\(group.id)"
                    data["checked"] = group.canBeCopied ? "checked" : ""
                    table.assign(variables: data, inNest: "group")
                }
                page.assign("table", table.output())
            }

            var templateVariables: [String:String] = [:]
            templateVariables["projectName"] = project.name
            templateVariables["projectID"] = project.id
            templateVariables["tree"] = self.treeMenu(project: project, activeGroup: activeGroup)
            page.assign(variables: templateVariables)
            
            container.assign("page", page.output())
            template.assign("page", container.output())
            return template.asResponse()
        }
    
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
    
    private func addParameter(request: HttpRequest, activeGroup: ProjectGroup?, url: String, project: Project, page: Template) -> HttpResponse? {
        guard let group = activeGroup else { return .notFound }
        let formData = request.flatFormData()
        let editUrl = "\(url)&groupID=\(group.id)&action=addParameter"
        let cancelUrl = "\(url)&groupID=\(group.id)"
        switch formData["step"] ?? "0" {
        case "0":
            let questionTypeOptions = ProjectQuestionType.allCases.map{FormRadioModel(label: $0.title, value: $0.rawValue)}
            let form = Form(url: editUrl, method: "POST")
                .addInputText(name: "label", label: "Nazwa parametru", labelCSSClass: "text-gray font-20")
                .addHidden(name: "projectID", value: project.id)
                .addHidden(name: "groupID", value: group.id)
                .addHidden(name: "step", value: "1")
                .addRadio(name: "type", label: "Typ parametru", options: questionTypeOptions, labelCSSClass: "text-gray font-20")
                .addSubmit(name: "submit", label: "Dodaj")
                .addRaw(html: "<a href='\(cancelUrl)' class='btn btn-purple-negative'>Anuluj</a>")
            page.assign(variables: ["form":form.output(), "title":"Dodaj Parametr"], inNest: "wideForm")
        case "1":
            guard let questionType = ProjectQuestionType(rawValue: formData["type"] ?? "") else {
                return .movedPermanently(cancelUrl)
            }
            switch questionType {

            case .number:
                let form = Form(url: editUrl, method: "POST")
                    .addHidden(name: "label", value: formData["label"] ?? "Brak nazwy")
                    .addHidden(name: "type", value: formData["type"] ?? "")
                    .addHidden(name: "projectID", value: project.id)
                    .addHidden(name: "step", value: "2")
                    .addInputText(name: "minValue", label: "Wartość minimalna")
                    .addInputText(name: "maxValue", label: "Wartość maksymalna")
                    .addSeparator(txt: "Pozostawienie wolnych zakresów wartości minimalnej i maksymalnej pozwala na podanie nieograniczonych wartości w odpowiedzi.")
                    .addInputText(name: "unit", label: "Jednostka")
                    .addSeparator(txt: "Jeśli chcesz, aby przy pytaniu była jednostka, wpisz ją w pole powyżej")
                    .addSubmit(name: "submit", label: "Dodaj")
                    .addRaw(html: "<a href='\(cancelUrl)' class='btn btn-purple-negative'>Anuluj</a>")

                page.assign(variables: ["form":form.output(), "title":"Dodaj Parametr"], inNest: "wideForm")
            case .dictionary:
                let form = Form(url: editUrl, method: "POST")
                    .addHidden(name: "label", value: formData["label"] ?? "Brak nazwy")
                    .addHidden(name: "type", value: formData["type"] ?? "")
                    .addHidden(name: "projectID", value: project.id)
                    .addHidden(name: "step", value: "2")
                    .addRadio(name: "dictionaryID", label: "Wybierz zbiór danych słownikowych z jakich można wybrać odpowiedź", options: project.dictionaries.map{ FormRadioModel(label: $0.name, value: $0.id) })
                    .addSubmit(name: "submit", label: "Dodaj")
                    .addRaw(html: "<a href='\(cancelUrl)' class='btn btn-purple-negative'>Anuluj</a>")
                page.assign(variables: ["form":form.output(), "title":"Dodaj Parametr"], inNest: "wideForm")
            case .longText:
                fallthrough
            case .text:
                let form = Form(url: editUrl, method: "POST")
                    .addHidden(name: "label", value: formData["label"] ?? "Brak nazwy")
                    .addHidden(name: "type", value: formData["type"] ?? "")
                    .addHidden(name: "projectID", value: project.id)
                    .addHidden(name: "step", value: "2")
                    .addInputText(name: "unit", label: "Jednostka")
                    .addSeparator(txt: "Jeśli chcesz, aby przy pytaniu była jednostka, wpisz ją w pole powyżej")
                    .addSubmit(name: "submit", label: "Dodaj")
                    .addRaw(html: "<a href='\(cancelUrl)' class='btn btn-purple-negative'>Anuluj</a>")
                page.assign(variables: ["form":form.output(), "title":"Dodaj Parametr"], inNest: "wideForm")
            case .unknown:
                break
            }
        case "2":
            guard let questionType = ProjectQuestionType(rawValue: formData["type"] ?? "") else {
                return .movedPermanently(cancelUrl)
            }
            let question = ProjectQuestion()
            question.label = formData["label"] ?? "Brak nazwy"
            question.dataType = questionType
            question.maxValue = formData["maxValue"]?.toInt()
            question.minValue = formData["minValue"]?.toInt()
            question.dictionaryID = formData["dictionaryID"]
            question.unit = formData["unit"]
            
            if question.label?.isEmpty ?? true { question.label = "Brak nazwy" }
            group.questions.append(question)
            return .movedPermanently(cancelUrl)
        default:
            break
        }
        return nil
    }
    
    private func addDictionary(request: HttpRequest, page: Template, url: String, project: Project) -> HttpResponse? {
        guard request.queryParam("form") != nil else { return nil }
        
        enum Step {
            case showForm
            case moreInputs
            case createDictionary
        }
        
        let formData = request.flatFormData()
        
        let editUrl = "\(url)&action=dictionaryList&form=new"
        let cancelUrl = "\(url)&action=dictionaryList"
        
        var answerAmount = Int(formData["inputs"] ?? "2") ?? 2
        var step: Step = .showForm

        if formData["addInput"] != nil {
            step = .moreInputs
            answerAmount += 1
        }
        if formData["submit"] != nil {
            step = .createDictionary
        }
        
        switch step {
        case .createDictionary:
            let dictionary = ProjectDictionary()
            dictionary.name = formData["name"] ?? "Bez nazwy"
            for n in (1...answerAmount) {
                if let name = formData["option\(n)"] {
                    let option = ProjectDictionaryOption()
                    option.title = name
                    dictionary.options.append(option)
                }
            }
            project.dictionaries.append(dictionary)
            break
        default:
            
            let form = Form(url: editUrl, method: "POST")
                .addInputText(name: "name", label: "Nazwa słownika", value: formData["name"] ?? "", labelCSSClass: "text-gray font-20")
                .addHidden(name: "projectID", value: project.id)
                .addHidden(name: "inputs", value: "\(answerAmount)")
                .addSeparator(txt: "Podaj wartości, jakie użytkownik będzie miał do wyboru")
            
            for n in (1...answerAmount) {
                form.addInputText(name: "option\(n)", label: "", value: formData["option\(n)"] ?? "")
            }
            
            form.addSubmit(name: "addInput", label: "+ Dodaj kolejną wartość wyboru")
                .addRaw(html: "<hr>")
                .addSubmit(name: "submit", label: "Dodaj")
                .addRaw(html: "<a href='\(cancelUrl)' class='btn btn-purple-negative'>Anuluj</a>")
            page.assign(variables: ["form":form.output(), "title":"Dodaj słownik"], inNest: "wideForm")
        }
        
        return nil
    }
    
    private func addCardsToProjectEditTemplate(_ page: Template, activeGroup: ProjectGroup?, projectID: String) {
        let cardView = Template(raw: Resource.getAppResource(relativePath: "templates/dashboardCardView.tpl"))
        
        var cardGroup: [String:String] = [:]
        cardGroup["title"] = "Dodaj grupę/podgrupę"
        cardGroup["desc"] = "Dodaj nową grupę w danej kategorii pytań"
        
        if activeGroup?.questions.isEmpty ?? true {
            cardGroup["onclick"] = "openLayer('/addGroup?activeGroupID=\(activeGroup?.id ?? "")&projectID=\(projectID)');"
            cardGroup["href"] = "#"
        } else {
            cardGroup["href"] = "#"
            cardGroup["disabled"] = "disabled"
        }
        cardView.assign(variables: cardGroup, inNest: "card")
        
        let url = "/editProject?projectID=\(projectID)"
        var cardParameter: [String:String] = [:]
        cardParameter["title"] = "Dodaj parametr"
        cardParameter["desc"] = "Pytanie możn dodać tylko wtedy, gdy w danej podgrupie nie są dodane podgrupy pytań"
        if let group = activeGroup, group.groups.isEmpty {
            cardParameter["href"] = "\(url)&groupID=\(activeGroup?.id ?? "")&action=addParameter"

        } else {
            cardParameter["href"] = "#"
            cardParameter["disabled"] = "disabled"
        }
        cardView.assign(variables: cardParameter, inNest: "card")
        
        var cardDictionary: [String:String] = [:]
        cardDictionary["title"] = "Edytuj słowniki"
        cardDictionary["desc"] = "Stwórz słowniki, w których możesz zdefiniować specyficzne odpowiedzi na pytania"
        cardDictionary["href"] = "\(url)&action=dictionaryList"
        cardView.assign(variables: cardDictionary, inNest: "card")
        
        page.assign("cards", cardView.output())
    }
    
    private func treeMenu(project: Project, activeGroup: ProjectGroup?) -> String {
        let template = Template(raw: Resource.getAppResource(relativePath: "templates/projectEditTree.tpl"))
        let url = "/editProject?projectID=\(project.id)"
        for group in project.groups {
            self.addGroupToTreeMenu(template, group: group, activeGroup: activeGroup, editProjectUrl: url)
        }
        var templateVariables: [String:String] = [:]
        templateVariables["css"] = activeGroup == nil ? "treeItemActive" : "treeItemInactive"
        templateVariables["projectID"] = project.id
        templateVariables["projectName"] = project.name
        template.assign(variables: templateVariables)
        return template.output()
    }
    
    private func addGroupToTreeMenu(_ template: Template, group: ProjectGroup, activeGroup: ProjectGroup?, level: Int = 1, editProjectUrl: String) {
        
        let url = "\(editProjectUrl)&groupID=\(group.id)"
        let uiTreeItem = UITreeItem(name: group.name, nestLevel: level, isActive: group.id == activeGroup?.id, url: url, hasChildren: !group.groups.isEmpty)
        template.assign(variables: uiTreeItem.getTemplateVariables(), inNest: "treeGroup")
        let level = level + 1
        group.groups.forEach{ self.addGroupToTreeMenu(template, group: $0, activeGroup: activeGroup, level: level, editProjectUrl: editProjectUrl) }
    }
    
    
    private func dictionaryPreview(request: HttpRequest, page: Template, project: Project) {
        guard let dictionaryID = request.queryParam("preview") else { return }
        guard let dictionary = (project.dictionaries.first{ $0.id == dictionaryID }) else { return }
        var html = Template.htmlNode(type: "h4", content: dictionary.name)
        for option in dictionary.options {
            html.append(Template.htmlNode(type: "p", content: option.title))
        }
        let cancelUrl = "/editProject?projectID=\(project.id)&action=dictionaryList"
        html.append(Template.htmlNode(type: "a", attributes: ["href":cancelUrl, "class":"btn btn-purple"], content: "Zamknij"))
        page.assign(variables: ["form":html], inNest: "wideForm")
    }
    
    private func wrapAsLayer(width: Int, title: String, content: String) -> String {
        let template = Template(raw: Resource.getAppResource(relativePath: "templates/layer.tpl"))
        template.assign(variables: ["title": title, "content": content, "width": "\(width)"])
        return template.output()
    }
}
