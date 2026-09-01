import Foundation

struct RoutineBlockTemplate {
    let title: String
    let startMinutes: Int
    let endMinutes: Int
    let blockType: ScheduleBlockType
    let icon: String
    let recurringDays: [Int]
}

protocol RoutineGeneratorProtocol {
    func generateInitialSchedule(for profile: UserProfile, on date: Date) -> [ScheduleBlock]
}

struct RoutineGenerator: RoutineGeneratorProtocol {

    func generateInitialSchedule(for profile: UserProfile, on date: Date = .now) -> [ScheduleBlock] {
        let wake = DateComposer.minutesSinceMidnight(from: profile.wakeUpTime)
        let sleep = DateComposer.minutesSinceMidnight(from: profile.sleepTime)
        let collegeStart = DateComposer.minutesSinceMidnight(from: profile.collegeStartTime)
        let collegeEnd = DateComposer.minutesSinceMidnight(from: profile.collegeEndTime)
        let homeArrival = collegeEnd + profile.travelMinutes

        let eveningCodingMinutes = max(profile.codingTargetMinutes - 150, 60)
        let firstCodingEnd = homeArrival + 30 + 150
        let firstCodingStart = firstCodingEnd - 150
        let windDownStart = max(sleep - 15, firstCodingEnd + 90 + eveningCodingMinutes)

        let allDays = Array(1...7)
        let collegeDays = CollegeDayHelper.collegeDays(sundayIsHoliday: profile.sundayIsHoliday)
        let sundayOnly = [DayOfWeek.sunday.rawValue]

        var templates: [RoutineBlockTemplate] = [
            RoutineBlockTemplate(title: "Wake Up", startMinutes: wake, endMinutes: wake + 30,
                                 blockType: .routine, icon: "sun.max.fill", recurringDays: allDays),
            RoutineBlockTemplate(title: "Morning Routine", startMinutes: wake + 30, endMinutes: wake + 60,
                                 blockType: .routine, icon: "cup.and.saucer.fill", recurringDays: allDays),
            RoutineBlockTemplate(title: "Bath", startMinutes: wake + 60, endMinutes: wake + 90,
                                 blockType: .routine, icon: "drop.fill", recurringDays: allDays),
            RoutineBlockTemplate(title: "Breakfast / Preparation", startMinutes: wake + 90, endMinutes: wake + 120,
                                 blockType: .routine, icon: "fork.knife", recurringDays: allDays),
            RoutineBlockTemplate(title: "Travel", startMinutes: wake + 120, endMinutes: collegeStart,
                                 blockType: .routine, icon: "car.fill", recurringDays: collegeDays),
            RoutineBlockTemplate(title: "College", startMinutes: collegeStart, endMinutes: collegeEnd,
                                 blockType: .college, icon: "graduationcap.fill", recurringDays: collegeDays),
            RoutineBlockTemplate(title: "Travel Home", startMinutes: collegeEnd, endMinutes: homeArrival,
                                 blockType: .routine, icon: "house.fill", recurringDays: collegeDays),
            RoutineBlockTemplate(title: "Rest / Freshen Up", startMinutes: homeArrival, endMinutes: homeArrival + 30,
                                 blockType: .break_, icon: "bed.double.fill", recurringDays: collegeDays),
            RoutineBlockTemplate(title: "Personal Coding", startMinutes: firstCodingStart, endMinutes: firstCodingEnd,
                                 blockType: .coding, icon: "laptopcomputer", recurringDays: collegeDays),
            RoutineBlockTemplate(title: "Cooking + Dinner", startMinutes: firstCodingEnd, endMinutes: firstCodingEnd + 60,
                                 blockType: .routine, icon: "frying.pan.fill", recurringDays: allDays),
            RoutineBlockTemplate(title: "Dinner / Cleanup", startMinutes: firstCodingEnd + 60, endMinutes: firstCodingEnd + 90,
                                 blockType: .routine, icon: "takeoutbag.and.cup.and.straw.fill", recurringDays: allDays),
            RoutineBlockTemplate(title: "Personal Coding / Deep Work",
                                 startMinutes: firstCodingEnd + 90,
                                 endMinutes: firstCodingEnd + 90 + eveningCodingMinutes,
                                 blockType: .coding, icon: "laptopcomputer", recurringDays: allDays),
            RoutineBlockTemplate(title: "Wind Down", startMinutes: windDownStart, endMinutes: sleep,
                                 blockType: .sleep, icon: "moon.stars.fill", recurringDays: allDays),
            RoutineBlockTemplate(title: "Sleep", startMinutes: sleep, endMinutes: min(sleep + 60, 24 * 60 - 1),
                                 blockType: .sleep, icon: "moon.zzz.fill", recurringDays: allDays)
        ]

        if profile.sundayIsHoliday {
            let sundayCodingEnd = collegeEnd
            let sundayCodingStart = max(wake + 120, sundayCodingEnd - profile.codingTargetMinutes)
            templates.append(
                RoutineBlockTemplate(
                    title: "Personal Coding",
                    startMinutes: sundayCodingStart,
                    endMinutes: sundayCodingEnd,
                    blockType: .coding,
                    icon: "laptopcomputer",
                    recurringDays: sundayOnly
                )
            )
        }

        return templates.map { template in
            ScheduleBlock(
                title: template.title,
                blockType: template.blockType.rawValue,
                startTime: DateComposer.date(fromMinutesSinceMidnight: template.startMinutes, on: date),
                endTime: DateComposer.date(fromMinutesSinceMidnight: template.endMinutes, on: date),
                isRecurring: true,
                recurringDays: template.recurringDays,
                icon: template.icon,
                isEditable: true
            )
        }
    }
}
