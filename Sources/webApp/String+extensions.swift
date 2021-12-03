//
//  String+extensions.swift
//  
//
//  Created by Tomasz Kucharski on 03/12/2021.
//

import Foundation

extension String {

    func append(_ key: String, _ value: String) -> String {
        if self.contains("?") {
            return "\(self)&\(key)=\(value)"
        }
        return "\(self)?\(key)=\(value)"
    }
}

extension String {
    func toInt() -> Int? {
        return Int(self)
    }
}
