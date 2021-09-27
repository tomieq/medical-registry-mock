//
//  Form.swift
//  
//
//  Created by Tomasz Kucharski on 25/05/2021.
//

import Foundation

class Form {
    let template: Template
    var html: String
    let method: String
    let url: String
    
    init(url: String, method: String) {
        self.method = method
        self.url = url
        self.template = Template(raw: Resource.getAppResource(relativePath: "templates/form.tpl"))
        self.html = ""
    }
    
    @discardableResult
    func addPassword(name: String, label: String, placeholder: String = "") -> Form {
        var variables: [String:String] = [:]
        variables["label"] = label
        variables["id"] = self.randomString(length: 10)
        variables["name"] = name
        self.template.assign(variables: variables, inNest: "password")
        self.html.append(self.template.output())
        self.template.reset()
        return self
    }
    
    @discardableResult
    func addInputText(name: String, label: String, value: String = "", labelCSSClass: String = "") -> Form {
        var variables: [String:String] = [:]
        variables["label"] = label
        variables["id"] = self.randomString(length: 10)
        variables["name"] = name
        variables["value"] = value
        variables["labelCSSClass"] = labelCSSClass
        self.template.assign(variables: variables, inNest: "text")
        self.html.append(self.template.output())
        self.template.reset()
        return self
    }
    
    @discardableResult
    func addSeparator(txt: String) -> Form {
        var variables: [String:String] = [:]
        variables["label"] = txt
        variables["id"] = self.randomString(length: 10)
        self.template.assign(variables: variables, inNest: "label")
        self.html.append(self.template.output())
        self.template.reset()
        return self
    }
    
    @discardableResult
    func addRaw(html: String) -> Form {
        self.html.append(html)
        return self
    }
    
    @discardableResult
    func addHidden(name: String, value: String) -> Form {
        var variables: [String:String] = [:]
        variables["name"] = name
        variables["value"] = value
        self.template.assign(variables: variables, inNest: "hidden")
        self.html.append(self.template.output())
        self.template.reset()
        return self
    }
    
    @discardableResult
    func addCheckbox(name: String, value: String, label: String) -> Form {
        var variables: [String:String] = [:]
        variables["name"] = name
        variables["label"] = label
        variables["value"] = value
        variables["id"] = self.randomString(length: 10)
        self.template.assign(variables: variables, inNest: "checkbox")
        self.html.append(self.template.output())
        self.template.reset()
        return self
    }
    
    @discardableResult
    func addRadio(name: String, label: String, options: [FormRadioModel], checked: String? = nil, labelCSSClass: String = "") -> Form {
        
        var radioHTML = ""
        options.forEach { option in
            var variables: [String:String] = [:]
            variables["label"] = option.label
            variables["id"] = self.randomString(length: 10)
            variables["name"] = name
            variables["value"] = option.value
            if checked == option.value {
                variables["checked"] = "checked"
            }
            self.template.assign(variables: variables, inNest: "radio")
            radioHTML.append(self.template.output())
            self.template.reset()
        }
        var variables: [String:String] = [:]
        variables["label"] = label
        variables["id"] = self.randomString(length: 10)
        variables["labelCSSClass"] = labelCSSClass
        variables["inputHTML"] = radioHTML
        self.template.assign(variables: variables, inNest: "label")
        self.html.append(self.template.output())
        self.template.reset()
        return self
    }
    
    @discardableResult
    func addTextarea(name: String, label: String, rows: Int = 3) -> Form {
        var variables: [String:String] = [:]
        variables["label"] = label
        variables["id"] = self.randomString(length: 10)
        variables["rows"] = "\(rows)"
        variables["name"] = name
        self.template.assign(variables: variables, inNest: "textarea")
        self.html.append(self.template.output())
        self.template.reset()
        return self
    }
    
    @discardableResult
    func addSubmit(name: String, label: String) -> Form {
        var variables: [String:String] = [:]
        variables["label"] = label
        variables["name"] = name
        self.template.assign(variables: variables, inNest: "submit")
        self.html.append(self.template.output())
        self.template.reset()
        return self
    }
    
    func output() -> String {
        var variables: [String:String] = [:]
        variables["html"] = self.html
        variables["method"] = self.method
        variables["url"] = self.url
        self.template.assign(variables: variables, inNest: "form")
        return self.template.output()
    }
    
    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}


struct FormRadioModel {
    let label: String
    let value: String
}
