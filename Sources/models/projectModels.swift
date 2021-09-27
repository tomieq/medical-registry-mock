//
//  ProjectModel.swift
//  
//
//  Created by Tomasz Kucharski on 31/05/2021.
//

import Foundation

enum ProjectStatus {
    case created
    case ready
    case closed
    
    var title: String {
        switch self {
        
        case .created:
            return "Utworzony"
        case .ready:
            return "Gotowy"
        case .closed:
            return "Zamknięty"
        }
    }
}

class Project {
    let id: String = UUID().uuidString
    var ownerID: String?
    var name: String = ""
    var groups: [ProjectGroup] = []
    var entries: [DataEntry] = []
    var status: ProjectStatus = .created
    var dictionaries: [ProjectDictionary] = []
    var data: [DataEntry] = []
    
    func findGroup(id: String) -> ProjectGroup? {
        return self.groups.first{ $0.id == id } ?? self.groups.compactMap{ $0.findGroup(id: id) }.first
    }
    
    func removeGroup(id: String) {
        self.groups = self.groups.filter { $0.id != id }
        self.groups.forEach{ $0.removeGroup(id: id) }
    }
}

class ProjectGroup {
    let id: String = UUID().uuidString
    var name: String = ""
    var groups: [ProjectGroup] = []
    var questions: [ProjectQuestion] = []
    
    func findGroup(id: String) -> ProjectGroup? {
        self.groups.first{ $0.id == id } ?? self.groups.compactMap{ $0.findGroup(id: id) }.first
    }
    
    func findQuestion(id: String) -> ProjectQuestion? {
        self.questions.first { $0.id == id }
    }
    
    func removeGroup(id: String) {
        self.groups = self.groups.filter { $0.id != id }
        self.groups.forEach{ $0.removeGroup(id: id) }
    }
}

enum ProjectQuestionType: String, CaseIterable {
    static var allCases: [ProjectQuestionType] = [.text, .longText, .number, .dictionary]
    
    case unknown
    case text
    case longText
    case number
    case dictionary
    
    var title: String {
        switch self {
        case .unknown:
            return "Nieznany typ"
        case .text:
            return "Odpowiedź tekstowa"
        case .longText:
            return "Odpowiedź tekstowa długa"
        case .number:
            return "Odpowiedź liczbowa"
        case .dictionary:
            return "Pole wyboru ze słownika"
        }
    }
}

class ProjectDictionary: Equatable {
    
    let id: String = UUID().uuidString
    var name: String = ""
    var options: [ProjectDictionaryOption] = []
    
    static func == (lhs: ProjectDictionary, rhs: ProjectDictionary) -> Bool {
        return lhs.id == rhs.id
    }
}

class ProjectDictionaryOption: Equatable {
    
    let id: String = UUID().uuidString
    var title: String = ""

    static func == (lhs: ProjectDictionaryOption, rhs: ProjectDictionaryOption) -> Bool {
        return lhs.id == rhs.id
    }
}

class ProjectQuestion {
    let id: String = UUID().uuidString
    let createDate = Date()
    var label: String?
    var dataType: ProjectQuestionType = .unknown
    var visibleOnList: Bool = false
    var minValue: Int?
    var maxValue: Int?
    var dictionaryID: String?
}

class DataEntry: Equatable {
    
    let id: String
    let ownerID: String
    var answers: [DataEntryAnswer] = []
    var answersForSeries: [[DataEntryAnswer]] = []
    
    init(ownerID: String) {
        self.id = UUID().uuidString
        self.ownerID = ownerID
    }
    
    static func == (lhs: DataEntry, rhs: DataEntry) -> Bool {
        lhs.id == rhs.id
    }
}

class DataEntryAnswer {
    let id: String = UUID().uuidString
    var questionID: String?
    var value: String?
}

class User {
    let id: String
    let login: String
    let password: String
    
    init(login: String, password: String) {
        self.id = UUID().uuidString
        self.login = login
        self.password = password
    }
}
