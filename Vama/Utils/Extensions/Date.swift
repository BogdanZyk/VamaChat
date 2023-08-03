//
//  Date.swift
//  Vama
//
//  Created by Bogdan Zykov on 03.08.2023.
//

import Foundation


extension Date{
    
    func toStrDate(format: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func timeAgo() -> String {
        
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "second"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "min"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "hour"
        } else {
            return toStrDate(format: "MMM d")
        }
        
        if quotient == 0{
            return "now"
        }else{
            return "\(quotient) \(unit)\(quotient == 1 ? "" : "s") ago"
        }
    }
    
    static var hoursAndMinuteFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        return formatter
    }()
    
    
    func extractDateComponents() -> DateComponents {
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        
        return components
    }
    
    func isSameDay(as date: Date) -> Bool {
        let components1 = extractDateComponents()
        let components2 = date.extractDateComponents()
        
        return (components1.year == components2.year) &&
                (components1.month == components2.month) &&
                (components1.day == components2.day)
    }
    
    func toFormatDate() -> String {
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let dateString: String
        
        if self >= today {
            dateString = "today"
        } else if self >= yesterday {
            dateString = "yesterday"
        } else {
            dateString = self.toStrDate(format: "MMM d")
        }
        return dateString
    }
}
