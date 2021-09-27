//
//  Date+extension.swift
//  
//
//  Created by Tomasz Kucharski on 27/09/2021.
//

import Foundation

extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
