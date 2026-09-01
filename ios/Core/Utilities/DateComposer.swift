import Foundation

enum DateComposer {
    static func timeOnDate(hour: Int, minute: Int, on reference: Date = .now) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: reference)
        components.hour = hour
        components.minute = minute
        components.second = 0
        return Calendar.current.date(from: components) ?? reference
    }

    static func minutesSinceMidnight(from date: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }

    static func date(fromMinutesSinceMidnight minutes: Int, on reference: Date = .now) -> Date {
        timeOnDate(hour: minutes / 60, minute: minutes % 60, on: reference)
    }

    static func combineTime(from timeSource: Date, on dayReference: Date) -> Date {
        let time = Calendar.current.dateComponents([.hour, .minute], from: timeSource)
        var day = Calendar.current.dateComponents([.year, .month, .day], from: dayReference)
        day.hour = time.hour
        day.minute = time.minute
        day.second = 0
        return Calendar.current.date(from: day) ?? dayReference
    }
}

extension Date {
    func settingTime(from source: Date) -> Date {
        DateComposer.combineTime(from: source, on: self)
    }
}

enum CollegeDayHelper {
    static func collegeDays(sundayIsHoliday: Bool) -> [Int] {
        if sundayIsHoliday {
            return [2, 3, 4, 5, 6, 7]
        }
        return Array(1...7)
    }

    static func isCollegeDay(_ date: Date, sundayIsHoliday: Bool) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        if sundayIsHoliday && weekday == DayOfWeek.sunday.rawValue {
            return false
        }
        return true
    }
}
