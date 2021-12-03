//
//  EditProjectAPI.swift
//  
//
//  Created by Tomasz Kucharski on 01/12/2021.
//

import Foundation
import Swifter

enum EditorUrl: String, CaseIterable {
    case editor
    case editorTreeMenu
    case editorCardsMenu
    case editorTable
    case editorGroupCopyableToggle
    case editorConfirmGroupRemoval
    case editorDeleteGroup
    case editorAddGroup
    case editorRenameGroup
    case editorMoveGroup
    case editorConfirmQuestionRemoval
    case editorAddQuestionStep1
    case editorAddQuestionStep2
    case editorDeleteQuestion
    case editorMoveQuestion
    case editorDictionaryList
    case editorDictionaryPreview
    case editorAddDictionary
    case editorAddDictionaryOption
    
    var url: String {
        return "/\(self.rawValue)"
    }
}

class EditProjectAPI: BaseAPI {
    

    
    private let dataStore: DataStore
    
    required init(_ server: HttpServer, dataStore: DataStore) {
        self.dataStore = dataStore

        
        // MARK: .editor
        server[EditorUrl.editor.url] = { request, responseHeaders in
            
            guard let project = (self.dataStore.projects.first{ $0.id == request.queryParam("projectID") }) else {
                return .notFound
            }
            
            var activeGroup: ProjectGroup?
            if let groupID = request.queryParam("groupID") {
                activeGroup = project.findGroup(id: groupID)
            }
            
            let container = Template(raw: Resource.getAppResource(relativePath: "templates/containerView.tpl"))
            container.assign(variables: ["title" : "Projekty"])
            container.assign(variables: ["title" : Template.htmlNode(type: "a", attributes: ["href":"#", "onclick":JSCode.loadBody(url: "/projects").js], content: "Projekty")], inNest: "item")
            container.assign(variables: ["title" : project.name], inNest: "item")
            
            let page = Template(raw: Resource.getAppResource(relativePath: "templates/projectEdit.tpl"))

            if let group = activeGroup, group.questions.count > 0 {
                page.assign("table", self.parameterList(project: project, group: group))
            } else {
                page.assign("table", self.groupList(project: project, group: activeGroup))
            }

            var templateVariables: [String:String] = [:]
            templateVariables["projectName"] = project.name
            templateVariables["projectID"] = project.id
            templateVariables["tree"] = self.treeMenu(project: project, activeGroup: activeGroup)
            templateVariables["cards"] = self.cardsMenu(project: project, activeGroup: activeGroup)
            page.assign(variables: templateVariables)
            
            container.assign("page", page.output())
            return container.asResponse()
        }
        
        // MARK: .editorTreeMenu
        server.GET[EditorUrl.editorTreeMenu.url] = { request, responseHeaders in
            guard let project = (self.dataStore.projects.filter{ $0.id == request.queryParam("projectID") }.first) else {
                return .notFound
            }
            var activeGroup: ProjectGroup?
            if let groupID = request.queryParam("groupID") {
                activeGroup = project.findGroup(id: groupID)
            }
            return self.treeMenu(project: project, activeGroup: activeGroup).asResponse
        }
        
        // MARK: .editorCardsMenu
        server.GET[EditorUrl.editorCardsMenu.url] = { request, responseHeaders in
            guard let project = (self.dataStore.projects.filter{ $0.id == request.queryParam("projectID") }.first) else {
                return .notFound
            }
            var activeGroup: ProjectGroup?
            if let groupID = request.queryParam("groupID") {
                activeGroup = project.findGroup(id: groupID)
            }
            return self.cardsMenu(project: project, activeGroup: activeGroup).asResponse
        }

        // MARK: .editorTable
        server.GET[EditorUrl.editorTable.url] = { request, responseHeaders in
            guard let project = (self.dataStore.projects.filter{ $0.id == request.queryParam("projectID") }.first) else {
                return .notFound
            }
            guard let groupID = request.queryParam("groupID"), let group = project.findGroup(id: groupID) else {
                return self.groupList(project: project, group: nil).asResponse
            }
            if group.questions.isEmpty {
                return self.groupList(project: project, group: group).asResponse
            }
            return self.parameterList(project: project, group: group).asResponse
        }
    
        // MARK: .editorGroupCopyableToggle
        server.GET[EditorUrl.editorGroupCopyableToggle.url] = { request, responseHeaders in
            guard let project = (self.dataStore.projects.filter{ $0.id == request.queryParam("projectID") }.first) else {
                return .notFound
            }
            guard let groupID = request.queryParam("groupID"), let group = project.findGroup(id: groupID) else { return .notFound }
            group.canBeCopied = Bool(request.queryParam("value") ?? "false") ?? false
            return .noContent
        }
        
        // MARK: .editorConfirmGroupRemoval
        server.GET[EditorUrl.editorConfirmGroupRemoval.url]  = { request, responseHeaders in
            guard let projectID = request.queryParam("projectID") else { return .badRequest(nil) }
            guard let groupID = request.queryParam("groupID") else { return .badRequest(nil) }
            let name = self.dataStore.projects.first{ $0.id == projectID }?.findGroup(id: groupID)?.name ?? ""

            var html = "Czy na pewno chcesz usunąć grupę <b>\(name)</b>?<br><br>"
            html.append("<a href='#' onclick=\"\(JSCode.loadScript(url: EditorUrl.editorDeleteGroup.url.append("projectID", projectID).append("groupID", groupID)).js)\" class='btn btn-purple'>Potwierdzam</a> ")
            html.append("<a href='#' onclick='\(JSCode.closeLayer.js)' class='btn btn-purple-negative'>Anuluj</a>")
            return self.wrapAsLayer(width: 500, title: "Usuwanie grupy", content: html).asResponse
        }
        
        // MARK: .editorDeleteGroup
        server.GET[EditorUrl.editorDeleteGroup.url]  = { request, responseHeaders in
            guard let projectID = request.queryParam("projectID") else { return .notFound }
            guard let groupID = request.queryParam("groupID") else { return .notFound }
            
            guard let project = (self.dataStore.projects.first{ $0.id == projectID }) else {
                return .notFound
            }
            project.removeGroup(id: groupID)
            
            let parentGroupID = project.parentGroup(id: groupID)?.id ?? ""
            let js = JSResponse()
            js.add(.closeLayer)
            js.add(.editorLoadTreeMenu(projectID: project.id, groupID: parentGroupID))
            js.add(.editorLoadCardsMenu(projectID: project.id, groupID: parentGroupID))
            js.add(.editorLoadGroupTable(projectID: project.id, groupID: parentGroupID))
            return js.response
        }
        
        // MARK: .editorAddGroup
        server.GET[EditorUrl.editorAddGroup.url]  = { request, responseHeaders in
            guard let projectID = request.queryParam("projectID") else { return .badRequest(nil) }
            guard let activeGroupID = request.queryParam("activeGroupID") else { return .badRequest(nil) }

            let form = Form(url: EditorUrl.editorAddGroup.url, method: "POST", ajax: true)
                .addInputText(name: "name", label: "Nazwa Grupy", labelCSSClass: "text-gray font-13")
                .addHidden(name: "projectID", value: projectID)
                .addHidden(name: "groupID", value: activeGroupID)
                .addSubmit(name: "submit", label: "Dodaj")
                .addRaw(html: "<a href='#' onclick='closeLayer()' class='btn btn-purple-negative'>Anuluj</a>")
            return .ok(.html(self.wrapAsLayer(width: 500, title: "Dodaj grupę", content: form.output())))
        }
        
        // MARK: .editorAddGroup
        server.POST[EditorUrl.editorAddGroup.url] = { request, responseHeaders in
            let formData = request.flatFormData()
            guard let project = (self.dataStore.projects.first{ $0.id == formData["projectID"] }) else {
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
                group.sequence = parentGroup.groups.count
            } else {
                project.groups.append(group)
                group.sequence = project.groups.count
            }
            let activeGroupID = activeGroup?.id ?? ""
            
            let js = JSResponse()
            js.add(.closeLayer)
            js.add(.editorLoadGroup(projectID: project.id, groupID: activeGroupID))
            return js.response
        }
        
        // MARK: .editorRenameGroup
        server.GET[EditorUrl.editorRenameGroup.url]  = { request, responseHeaders in
            guard let projectID = request.queryParam("projectID") else { return .badRequest(nil) }
            guard let groupID = request.queryParam("groupID") else { return .badRequest(nil) }
            let name = self.dataStore.projects.first{ $0.id == projectID }?.findGroup(id: groupID)?.name ?? ""

            let form = Form(url: EditorUrl.editorRenameGroup.url, method: "POST", ajax: true)
                .addInputText(name: "name", label: "Nazwa Grupy", value: name, labelCSSClass: "text-gray font-13")
                .addHidden(name: "projectID", value: projectID)
                .addHidden(name: "groupID", value: groupID)
                .addSubmit(name: "submit", label: "Zmień")
                .addRaw(html: "<a href='#' onclick='closeLayer()' class='btn btn-purple-negative'>Anuluj</a>")

            return self.wrapAsLayer(width: 500, title: "Zmień nazwę grupy", content: form.output()).asResponse
        }
        
        // MARK: .editorRenameGroup
        server.POST[EditorUrl.editorRenameGroup.url] = { request, responseHeaders in
            let formData = request.flatFormData()
            guard let project = (self.dataStore.projects.filter{ $0.id == formData["projectID"] }.first) else {
                return .notFound
            }
            guard let groupID = formData["groupID"], let group = project.findGroup(id: groupID) else { return .notFound }
            
            group.name = "bez nazwy"
            if let name = formData["name"], !name.isEmpty {
                group.name = name
            }
            let parentGroupID = project.parentGroup(id: groupID)?.id ?? ""
            let js = JSResponse()
            js.add(.closeLayer)
            js.add(.editorLoadTreeMenu(projectID: project.id, groupID: parentGroupID))
            js.add(.editorLoadGroupTable(projectID: project.id, groupID: parentGroupID))
            return js.response
        }
        
        // MARK: .editorMoveGroup
        server.GET[EditorUrl.editorMoveGroup.url] = { request, responseHeaders in
            guard let projectID = request.queryParam("projectID") else { return .notFound }
            guard let groupID = request.queryParam("groupID") else { return .notFound }
            guard let direction = request.queryParam("direction") else { return .notFound }
            
            guard let project = (self.dataStore.projects.first{ $0.id == projectID }) else {
                return .notFound
            }
            guard let group = project.findGroup(id: groupID) else {
                return .notFound
            }
            let parentGroup = project.parentGroup(id: groupID)
            let groups = (parentGroup?.groups ?? project.groups).sorted()
            if let index = groups.firstIndex(of: group) {
                if direction == "up" {
                    if group.sequence > 1 {
                        group.sequence -= 1
                        groups[safeIndex: index - 1]?.sequence += 1
                    }
                } else {
                    if group.sequence < groups.count {
                        group.sequence += 1
                        groups[safeIndex: index + 1]?.sequence -= 1
                    }
                }
            }
            
            let parentGroupID = parentGroup?.id ?? ""

            let js = JSResponse()
            js.add(.editorLoadTreeMenu(projectID: project.id, groupID: parentGroupID))
            js.add(.editorLoadGroupTable(projectID: project.id, groupID: parentGroupID))
            return js.response
        }
        
        // MARK: .editorConfirmQuestionRemoval
        server.GET[EditorUrl.editorConfirmQuestionRemoval.url] = { request, responseHeaders in
            guard let projectID = request.queryParam("projectID") else { return .badRequest(nil) }
            guard let questionID = request.queryParam("questionID") else { return .badRequest(nil) }
            guard let question = (self.dataStore.projects.first{ $0.id == projectID }?.findQuestion(id: questionID)) else { return .badRequest(nil) }
            let name = question.label

            var html = "Czy na pewno chcesz usunąć parametr <b>\(name)</b>?<br><br>"
            html.append("<a href='#' onclick=\"\(JSCode.loadScript(url: EditorUrl.editorDeleteQuestion.url.append("projectID", projectID).append("questionID", questionID)).js)\" class='btn btn-purple'>Potwierdzam</a> ")
            html.append("<a href='#' onclick='\(JSCode.closeLayer.js)' class='btn btn-purple-negative'>Anuluj</a>")
            return self.wrapAsLayer(width: 500, title: "Usuwanie parametru", content: html).asResponse
        }
        
        // MARK: .editorAddQuestionStep1
        server.GET[EditorUrl.editorAddQuestionStep1.url] = { request, responseHeaders in
            guard let projectID = request.queryParam("projectID") else { return .badRequest(nil) }
            guard let groupID = request.queryParam("groupID") else { return .badRequest(nil) }

            let questionTypeOptions = ProjectQuestionType.allCases.map{FormRadioModel(label: $0.title, value: $0.rawValue)}
            let form = Form(url: EditorUrl.editorAddQuestionStep1.url, method: "POST", ajax: true)
                .addInputText(name: "label", label: "Nazwa parametru", labelCSSClass: "text-gray font-20")
                .addHidden(name: "projectID", value: projectID)
                .addHidden(name: "groupID", value: groupID)
                .addRadio(name: "type", label: "Typ parametru", options: questionTypeOptions, labelCSSClass: "text-gray font-20")
                .addSubmit(name: "submit", label: "Dalej")
                .addRaw(html: "<span onclick='\(JSCode.closeLayer.js)' class='btn btn-purple-negative hand'>Anuluj</span>")

            return self.wrapAsLayer(width: 500, title: "Dodaj Parametr", content: form.output()).asResponse
        }
        
        // MARK: .editorAddQuestionStep1
        server.POST[EditorUrl.editorAddQuestionStep1.url] = { request, responseHeaders in
            let formData = request.flatFormData()
            guard let projectID = formData["projectID"] else { return .notFound }
            guard let groupID = formData["groupID"] else { return .notFound }
            
            guard let questionType = ProjectQuestionType(rawValue: formData["type"] ?? "") else {
                return .notFound
            }
            let label = formData["label"] ?? "Brak nazwy"

            
            let js = JSResponse()
            js.add(.loadAsLayer(url: EditorUrl.editorAddQuestionStep2.url.append("projectID", projectID).append("groupID", groupID).append("type", questionType.rawValue).append("label", label)))
            return js.response
        }

        // MARK: .editorAddQuestionStep2
        server.GET[EditorUrl.editorAddQuestionStep2.url] = { request, responseHeaders in
            
            guard let projectID = request.queryParam("projectID") else { return .notFound }
            guard let groupID = request.queryParam("groupID") else { return .notFound }
            guard let project = (self.dataStore.projects.first{$0.id == projectID}) else { return .notFound }
            
            guard let questionType = ProjectQuestionType(rawValue: request.queryParam("type") ?? "") else {
                return .notFound
            }
            let label = request.queryParam("label")?.removingPercentEncoding ?? "Brak nazwy"
            
            var html = ""
            let url = EditorUrl.editorAddQuestionStep2.url
            switch questionType {

            case .number:
                let form = Form(url: url, method: "POST", ajax: true)
                    .addHidden(name: "label", value: label)
                    .addHidden(name: "type", value: questionType.rawValue)
                    .addHidden(name: "projectID", value: project.id)
                    .addHidden(name: "groupID", value: groupID)
                    .addInputText(name: "minValue", label: "Wartość minimalna")
                    .addInputText(name: "maxValue", label: "Wartość maksymalna")
                    .addSeparator(txt: "Pozostawienie wolnych zakresów wartości minimalnej i maksymalnej pozwala na podanie nieograniczonych wartości w odpowiedzi.")
                    .addInputText(name: "unit", label: "Jednostka")
                    .addSeparator(txt: "Jeśli chcesz, aby przy pytaniu była jednostka, wpisz ją w pole powyżej")
                    .addSubmit(name: "submit", label: "Dodaj")
                    .addRaw(html: "<span onclick='\(JSCode.closeLayer.js)' class='btn btn-purple-negative hand'>Anuluj</span>")
                html = form.output()
            case .dictionary:
                let form = Form(url: url, method: "POST", ajax: true)
                    .addHidden(name: "label", value: label)
                    .addHidden(name: "type", value: questionType.rawValue)
                    .addHidden(name: "projectID", value: project.id)
                    .addHidden(name: "groupID", value: groupID)
                    .addHidden(name: "step", value: "2")
                    .addRadio(name: "dictionaryID", label: "Wybierz zbiór danych słownikowych z jakich można wybrać odpowiedź", options: project.dictionaries.map{ FormRadioModel(label: $0.name, value: $0.id) })
                    .addSubmit(name: "submit", label: "Dodaj")
                    .addRaw(html: "<span onclick='\(JSCode.closeLayer.js)' class='btn btn-purple-negative hand'>Anuluj</span>")
                html = form.output()
            case .longText:
                fallthrough
            case .text:
                let form = Form(url: url, method: "POST", ajax: true)
                    .addHidden(name: "label", value: label)
                    .addHidden(name: "type", value: questionType.rawValue)
                    .addHidden(name: "projectID", value: project.id)
                    .addHidden(name: "groupID", value: groupID)
                    .addHidden(name: "step", value: "2")
                    .addInputText(name: "unit", label: "Jednostka")
                    .addSeparator(txt: "Jeśli chcesz, aby przy pytaniu była jednostka, wpisz ją w pole powyżej")
                    .addSubmit(name: "submit", label: "Dodaj")
                    .addRaw(html: "<span onclick='\(JSCode.closeLayer.js)' class='btn btn-purple-negative hand'>Anuluj</span>")
                html = form.output()
            case .unknown:
                break
            }
            
            return self.wrapAsLayer(width: 500, title: "Dodaj Parametr", content: html).asResponse
        }
        
        
        // MARK: .editorAddQuestionStep2
        server.POST[EditorUrl.editorAddQuestionStep2.url] = { request, responseHeaders in
            let formData = request.flatFormData()
            guard let projectID = formData["projectID"] else { return .notFound }
            guard let groupID = formData["groupID"] else { return .notFound }
            
            guard let project = (self.dataStore.projects.first{$0.id == projectID}) else { return .notFound }
            guard let group = project.findGroup(id: groupID) else { return .notFound }

            guard let questionType = ProjectQuestionType(rawValue: formData["type"] ?? "") else {
                return .notFound
            }
            let label = formData["label"] ?? "Brak nazwy"

            let question = ProjectQuestion()
            question.label = label
            question.dataType = questionType
            question.maxValue = formData["maxValue"]?.toInt()
            question.minValue = formData["minValue"]?.toInt()
            question.dictionaryID = formData["dictionaryID"]
            question.unit = formData["unit"]
            
            if question.label.isEmpty { question.label = "Brak nazwy" }
            group.questions.append(question)
            question.sequence = group.questions.count
            
            let js = JSResponse()
            js.add(.closeLayer)
            js.add(.editorLoadCardsMenu(projectID: projectID, groupID: groupID))
            js.add(.editorLoadGroupTable(projectID: projectID, groupID: groupID))
            return js.response
        }
        
        // MARK: .editorDeleteQuestion
        server.GET[EditorUrl.editorDeleteQuestion.url]  = { request, responseHeaders in
            guard let projectID = request.queryParam("projectID") else { return .notFound }
            guard let questionID = request.queryParam("questionID") else { return .notFound }
            
            guard let project = (self.dataStore.projects.first{ $0.id == projectID }) else {
                return .notFound
            }
            let parentGroup = project.parentGroup(id: questionID)
            parentGroup?.removeQuestion(id: questionID)

            let parentGroupID = parentGroup?.id ?? ""
            let js = JSResponse()
            js.add(.closeLayer)
            js.add(.editorLoadTreeMenu(projectID: project.id, groupID: parentGroupID))
            js.add(.editorLoadCardsMenu(projectID: project.id, groupID: parentGroupID))
            js.add(.editorLoadGroupTable(projectID: project.id, groupID: parentGroupID))
            return js.response
        }
        
        // MARK: .editorMoveQuestion
        server.GET[EditorUrl.editorMoveQuestion.url] = { request, responseHeaders in
            guard let projectID = request.queryParam("projectID") else { return .notFound }
            guard let questionID = request.queryParam("questionID") else { return .notFound }
            guard let direction = request.queryParam("direction") else { return .notFound }
            
            guard let project = (self.dataStore.projects.first{ $0.id == projectID }) else {
                return .notFound
            }
            guard let question = project.findQuestion(id: questionID) else {
                return .notFound
            }
            let parentGroup = project.parentGroup(id: questionID)
            let questions = parentGroup?.questions.sorted() ?? []
            if let index = questions.firstIndex(of: question) {
                if direction == "up" {
                    if question.sequence > 1 {
                        question.sequence -= 1
                        questions[safeIndex: index - 1]?.sequence += 1
                    }
                } else {
                    if question.sequence < questions.count {
                        question.sequence += 1
                        questions[safeIndex: index + 1]?.sequence -= 1
                    }
                }
            }
            
            let parentGroupID = parentGroup?.id ?? ""

            let js = JSResponse()
            js.add(.editorLoadTreeMenu(projectID: project.id, groupID: parentGroupID))
            js.add(.editorLoadGroupTable(projectID: project.id, groupID: parentGroupID))
            return js.response
        }

        // MARK: .editorDictionaryList
        server.GET[EditorUrl.editorDictionaryList.url]  = { request, responseHeaders in
            guard let projectID = request.queryParam("projectID") else { return .badRequest(nil) }
            guard let project = (self.dataStore.projects.first{ $0.id == projectID }) else {
                return .notFound
            }
    
            let list = Template(raw: Resource.getAppResource(relativePath: "templates/dictionaryList.tpl"))
            list.assign("createDictionaryJS", JSCode.loadAsLayer(url: EditorUrl.editorAddDictionary.url.append("projectID", projectID)).js)
            for dictionary in project.dictionaries {
                var data: [String:String] = [:]
                data["name"] = dictionary.name
                data["previewClick"] = JSCode.loadAsLayer(url: EditorUrl.editorDictionaryPreview.url.append("projectID", project.id).append("preview", dictionary.id)).js
                data["dictionaryID"] = dictionary.id
                list.assign(variables: data, inNest: "dictionary")
            }
            
            return list.asResponse()
        }
        
        // MARK: .editorDictionaryPreview
        server.GET[EditorUrl.editorDictionaryPreview.url]  = { request, responseHeaders in
            guard let projectID = request.queryParam("projectID") else { return .notFound }
            guard let project = (self.dataStore.projects.first{ $0.id == projectID }) else {
                return .notFound
            }
            guard let dictionaryID = request.queryParam("preview") else { return .notFound }
            guard let dictionary = (project.dictionaries.first{ $0.id == dictionaryID }) else { return .notFound }
            
            return self.wrapAsLayer(width: 600, title: dictionary.name, content: self.dictionaryPreview(project: project, dictionary: dictionary)).asResponse
        }
        
        //MARK: .editorAddDictionary
        server.GET[EditorUrl.editorAddDictionary.url]  = { request, responseHeaders in
            guard let projectID = request.queryParam("projectID") else { return .notFound }
            guard let project = (self.dataStore.projects.first{ $0.id == projectID }) else {
                return .notFound
            }
                
            let form = Form(url: EditorUrl.editorAddDictionary.url, method: "POST", ajax: true)
                .addInputText(name: "name", label: "", labelCSSClass: "text-gray font-20")
                .addHidden(name: "projectID", value: project.id)
                .addSeparator(txt: "Podaj wartości, jakie użytkownik będzie miał do wyboru")
            
            for _ in (1...2) {
                form.addInputText(name: "option[]", label: "", value: "")
            }
            form.addRaw(html: "<div id='moreOptions'></div>")
            
            var attributes: [String:String] = [:]
            attributes["class"] = "btn btn-purple"
            attributes["onclick"] = "$('<div>').load('\(EditorUrl.editorAddDictionaryOption.url)', function() { $('#moreOptions').append($(this).html());});"
            form.addRaw(html: Template.htmlNode(type: "span", attributes: attributes, content: "+ Dodaj kolejną wartość wyboru"))
                .addRaw(html: "<hr>")
                .addSubmit(name: "submit", label: "Dodaj")
                .addRaw(html: "<span onclick='\(JSCode.closeLayer.js)' class='btn btn-purple-negative hand'>Anuluj</a>")

            return self.wrapAsLayer(width: 600, title: "Dodaj nowy słownik", content: form.output()).asResponse
        }

        //MARK: .editorAddDictionaryOption
        server.GET[EditorUrl.editorAddDictionaryOption.url]  = { request, responseHeaders in
            let template = Template(raw: Resource.getAppResource(relativePath: "templates/form.tpl"))
            
            var variables: [String:String] = [:]
            variables["name"] = "option[]"
            template.assign(variables: variables, inNest: "text")
            return template.asResponse()
        }

        //MARK: .editorAddDictionary
        server.POST[EditorUrl.editorAddDictionary.url]  = { request, responseHeaders in
            let formData = request.flatFormData()
            guard let projectID = formData["projectID"] else { return .notFound }
            guard let project = (self.dataStore.projects.first{ $0.id == projectID }) else {
                return .notFound
            }
            
            let urlencodedForm = request.parseUrlencodedForm()
            let options = urlencodedForm.filter{$0.0 == "option[]"}.map{$0.1}

            let dictionary = ProjectDictionary()
            dictionary.name = formData["name"] ?? "Bez nazwy"
            if dictionary.name.isEmpty { dictionary.name = "Bez nazwy" }
            for name in options {
                if !name.isEmpty {
                    let option = ProjectDictionaryOption()
                    option.title = name
                    dictionary.options.append(option)
                }
            }
            if !dictionary.options.isEmpty {
                project.dictionaries.append(dictionary)
            }
            
            
            let js = JSResponse()
            js.add(.closeLayer)
            js.add(.editorLoadDictionaryList(projectID: projectID))
            return js.response
        }
    }
    
    private func cardsMenu(project: Project, activeGroup: ProjectGroup?) -> String {
        let cardView = Template(raw: Resource.getAppResource(relativePath: "templates/dashboardCardView.tpl"))
        
        var cardGroup: [String:String] = [:]
        cardGroup["title"] = "Dodaj grupę/podgrupę"
        cardGroup["desc"] = "Dodaj nową grupę w danej kategorii pytań"
        cardGroup["href"] = "#"
        
        if activeGroup?.questions.isEmpty ?? true {
            cardGroup["onclick"] = JSCode.loadAsLayer(url: EditorUrl.editorAddGroup.url.append("projectID", project.id).append("activeGroupID", activeGroup?.id ?? "")).js
        } else {
            cardGroup["disabled"] = "disabled"
        }
        cardView.assign(variables: cardGroup, inNest: "card")
        
        var cardParameter: [String:String] = [:]
        cardParameter["title"] = "Dodaj parametr"
        cardParameter["desc"] = "Pytanie możn dodać tylko wtedy, gdy w danej podgrupie nie są dodane podgrupy pytań"
        cardParameter["href"] = "#"
        if let group = activeGroup, group.groups.isEmpty {
            cardParameter["onclick"] = JSCode.loadAsLayer(url: EditorUrl.editorAddQuestionStep1.url.append("projectID", project.id).append("groupID", group.id)).js
        } else {
            cardParameter["disabled"] = "disabled"
        }
        cardView.assign(variables: cardParameter, inNest: "card")
        
        var cardDictionary: [String:String] = [:]
        cardDictionary["title"] = "Edytuj słowniki"
        cardDictionary["desc"] = "Stwórz słowniki, w których możesz zdefiniować specyficzne odpowiedzi na pytania"
        cardDictionary["href"] = "#"
        cardDictionary["onclick"] = JSCode.editorLoadDictionaryList(projectID: project.id).js
        cardView.assign(variables: cardDictionary, inNest: "card")
        
        return cardView.output()
    }
    
    private func parameterList(project: Project, group: ProjectGroup) -> String {

        let table = Template(raw: Resource.getAppResource(relativePath: "templates/projectEditQuestionList.tpl"))
        for question in group.questions.sorted() {
            var data: [String:String] = [:]
            data["name"] = question.label
            data["createDate"] = question.createDate.getFormattedDate(format: "yyyy-MM-dd")
            data["type"] = question.dataType.title
            if let unit = question.unit {
                data["unit"] = Template.htmlNode(type: "span", attributes: ["class":"label label-green"], content: unit)
            }
            data["questionID"] = question.id
            data["onclickDelete"] = JSCode.loadAsLayer(url: EditorUrl.editorConfirmQuestionRemoval.url.append("projectID", project.id).append("questionID", question.id)).js
            data["moveUpClick"] = JSCode.loadScript(url: EditorUrl.editorMoveQuestion.url.append("projectID", project.id).append("questionID", question.id).append("direction", "up")).js
            data["moveDownClick"] = JSCode.loadScript(url: EditorUrl.editorMoveQuestion.url.append("projectID", project.id).append("questionID", question.id).append("direction", "down")).js

            
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
        return table.output()
    }

    private func groupList(project: Project, group: ProjectGroup?) -> String {

        let table = Template(raw: Resource.getAppResource(relativePath: "templates/projectEditGroupList.tpl"))
        let groups = group?.groups ?? project.groups
        for group in groups.sorted() {
            var data: [String:String] = [:]
            data["projectID"] = project.id
            data["name"] = group.name
            data["groupID"] = group.id
            data["openGroupJS"] = JSCode.editorLoadGroup(projectID: project.id, groupID: group.id).js
            data["onclickDelete"] = JSCode.loadAsLayer(url: EditorUrl.editorConfirmGroupRemoval.url.append("projectID", project.id).append("groupID", group.id)).js
            data["onclickRename"] = JSCode.loadAsLayer(url: EditorUrl.editorRenameGroup.url.append("projectID", project.id).append("groupID", group.id)).js
            data["toggleCopyUrl"] = EditorUrl.editorGroupCopyableToggle.url.append("projectID", project.id).append("groupID", group.id)
            data["moveUpClick"] = JSCode.loadScript(url: EditorUrl.editorMoveGroup.url.append("projectID", project.id).append("groupID", group.id).append("direction", "up")).js
            data["moveDownClick"] = JSCode.loadScript(url: EditorUrl.editorMoveGroup.url.append("projectID", project.id).append("groupID", group.id).append("direction", "down")).js
            data["checked"] = group.canBeCopied ? "checked" : ""
            table.assign(variables: data, inNest: "group")
        }
        return table.output()
    }
    
    private func treeMenu(project: Project, activeGroup: ProjectGroup?) -> String {
        let template = Template(raw: Resource.getAppResource(relativePath: "templates/projectEditTree.tpl"))
        for group in project.groups.sorted() {
            self.addGroupToTreeMenu(template, project, group: group, activeGroup: activeGroup)
        }
        var templateVariables: [String:String] = [:]
        templateVariables["css"] = activeGroup == nil ? "treeItemActive" : "treeItemInactive"
        templateVariables["onclick"] = JSCode.editorLoadGroup(projectID: project.id, groupID: "").js
        templateVariables["projectName"] = project.name
        template.assign(variables: templateVariables)
        return template.output()
    }
    
    private func addGroupToTreeMenu(_ template: Template, _ project: Project, group: ProjectGroup, activeGroup: ProjectGroup?, level: Int = 1) {
        
        let uiTreeItem = UITreeItem(project: project, group: group, nestLevel: level, isActive: group.id == activeGroup?.id, hasChildren: !group.groups.isEmpty)
        template.assign(variables: uiTreeItem.getTemplateVariables(), inNest: "treeGroup")
        let level = level + 1
        group.groups.sorted().forEach{ self.addGroupToTreeMenu(template, project, group: $0, activeGroup: activeGroup, level: level) }
    }
    
    
    private func dictionaryPreview(project: Project, dictionary: ProjectDictionary) -> String {
        var html = ""
        for option in dictionary.options {
            html.append(Template.htmlNode(type: "li", content: option.title))
        }
        html.append("<br>")
        let cancelJS = JSCode.closeLayer.js
        html.append(Template.htmlNode(type: "span", attributes: ["onclick": cancelJS, "class":"btn btn-purple hand"], content: "Zamknij"))
        return html
    }
    
    private func wrapAsLayer(width: Int, title: String, content: String) -> String {
        let template = Template(raw: Resource.getAppResource(relativePath: "templates/layer.tpl"))
        template.assign(variables: ["title": title, "content": content, "width": "\(width)"])
        return template.output()
    }
}
