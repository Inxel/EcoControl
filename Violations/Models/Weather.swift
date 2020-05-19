//
//  Weather.swift
//  Violations
//
//  Created by Артем Загоскин on 23/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import Foundation


struct Weather: Decodable {
    
    let temperatureData: TemperatureData
    let conditionData: [ConditionData]
    
    var formatted: String { "\(temperature)º\n\(updateWeatherEmoji)" }
    
    private var temperature: Int { Int(temperatureData.temperature - 273.15) }
    private var condition: Int { conditionData.first?.condition ?? 1001 }
    
    private var updateWeatherEmoji: String {
        switch (condition) {
            
        case 0...300:
            return "🌦"
            
        case 301...600:
            return "☔️"
            
        case 601...700, 903:
            return "❄️"
            
        case 701...771:
            return "💨"
            
        case 800, 904:
            return "☀️"
            
        case 801...804:
            return "🌤"
            
        case 772...799, 900...903, 905...1000:
            return "⛈"
            
        default:
            return "❓"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case temperatureData = "main"
        case conditionData = "weather"
    }
    
}

// MARK: - Inner Models

struct TemperatureData: Decodable {
    let temperature: Double
    
    private enum CodingKeys: String, CodingKey {
        case temperature = "temp"
    }
}


struct ConditionData: Decodable {
    let condition: Int
    
    private enum CodingKeys: String, CodingKey {
        case condition = "id"
    }
}


// MARK: - Weather Decoding

extension Weather {
    
    static func decode(wheatherData: Data) -> Weather? {
        do {
            
            let response = try JSONDecoder().decode(Weather.self, from: wheatherData)
            return response
            
        } catch let DecodingError.keyNotFound(key, context) {
            let errorMessage = """
            Key '\(key)' not found: \(context.debugDescription).
            CodingPath: \(context.codingPath)
            """
            print(errorMessage)
            
        } catch let DecodingError.valueNotFound(value, context) {
            let errorMessage = """
            Value '\(value)' not found: \(context.debugDescription).
            CodingPath: \(context.codingPath)
            """
            print(errorMessage)

        } catch let DecodingError.typeMismatch(type, context) {
            let errorMessage = """
            Type '\(type)' not found: \(context.debugDescription).
            CodingPath: \(context.codingPath)
            """
            print(errorMessage)
            
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
}
