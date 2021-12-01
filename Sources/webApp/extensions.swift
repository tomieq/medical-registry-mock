//
//  extensions.swift
//  
//
//  Created by Tomasz Kucharski on 01/06/2021.
//

import Foundation
import Swifter

extension String {
    
    public var asResponse: HttpResponse {
        return .ok(.html(self))
    }
}


extension Optional {
    func toString() -> String {
        switch self {
        case .none:
            return ""
        case .some(let value):
            return "\(value)"
        }
    }
    func toOptionalString() -> String? {
        switch self {
        case .none:
            return nil
        case .some(let value):
            return "\(value)"
        }
    }
}

extension String {
    func toInt() -> Int? {
        return Int(self)
    }
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = firstIndex(of: object) {
            remove(at: index)
        }
    }
    
    subscript(safeIndex index: Int) -> Element? {
        get {
            guard index >= 0 && index < self.count else { return nil }
            return self[index]
        }
        
        set(newValue) {
            guard let value = newValue, index >= 0 && index < self.count else { return }
            self[index] = value
        }
    }
}
