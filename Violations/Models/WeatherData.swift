//
//  WeatherData.swift
//  Violations
//
//  Created by Артем Загоскин on 23/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import Foundation


struct WeatherData {
    
    var temperature: Int
    var condition: Int
    var weather: String { "\(temperature)º\n\(updateWeatherEmoji)" }
    
    
    //This method turns a condition code into the name of the weather condition image
    
    private var updateWeatherEmoji: String {
        
        switch (condition) {
            
        case 0...300 :
            return "🌦"
            
        case 301...600 :
            return "☔️"
            
        case 601...700, 903 :
            return "❄️"
            
        case 701...771 :
            return "💨"
            
        case 800, 904 :
            return "☀️"
            
        case 801...804 :
            return "🌤"
            
        case 772...799, 900...903, 905...1000  :
            return "⛈"
            
        default :
            return "❓"
        }
    }
    
}
