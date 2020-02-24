//
//  Date+Formatting.swift
//  Violations
//
//  Created by Artyom Zagoskin on 24.02.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import Foundation


enum DateFormatType: String {
    case long = "dd MMMM yyyy"       // 20 декабря 2018
    case short = "d MMMM"            // 20 декабря
    case longNumbers = "dd.MM.yyyy"  // 20.12.2018
    case shortNumbers = "dd.MM"      // 20.12
}


enum DateFormatTimeZone {
    case current, gmt
    
    var timeZone: TimeZone? {
        switch self {
        case .current:
            return TimeZone.current
        case .gmt:
            return TimeZone(secondsFromGMT: 0)
        }
    }
}


enum DateLocale: String {
    case en = "en"
    case ru = "ru"
}


extension Date {

    func formattedDate(_ formatType: DateFormatType, locale: DateLocale = .en, timeZone: DateFormatTimeZone = .current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatType.rawValue
        dateFormatter.timeZone = timeZone.timeZone
        dateFormatter.locale = .init(identifier: locale.rawValue)
        return dateFormatter.string(from: self)
    }

}
