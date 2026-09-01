import Foundation
import Testing

struct RoutineGeneratorTests {

    @Test func generatesBlocksForDefaultProfile() {
        let profile = UserProfile(
            name: "Test",
            sundayIsHoliday: true
        )
        let generator = RoutineGenerator()
        let blocks = generator.generateInitialSchedule(for: profile)

        #expect(!blocks.isEmpty)
        #expect(blocks.contains { $0.title == "Wake Up" })
        #expect(blocks.contains { $0.title == "College" })
        #expect(blocks.contains { $0.title == "Personal Coding" })
        #expect(blocks.contains { $0.title == "Sleep" })
    }

    @Test func collegeBlocksExcludeSundayWhenHoliday() {
        let profile = UserProfile(sundayIsHoliday: true)
        let generator = RoutineGenerator()
        let blocks = generator.generateInitialSchedule(for: profile)

        let collegeBlock = blocks.first { $0.title == "College" }
        #expect(collegeBlock != nil)
        #expect(collegeBlock?.recurringDays.contains(DayOfWeek.sunday.rawValue) == false)
        #expect(collegeBlock?.recurringDays.contains(DayOfWeek.monday.rawValue) == true)
    }

    @Test func sundayGetsCodingBlockWhenHoliday() {
        let profile = UserProfile(sundayIsHoliday: true, codingTargetMinutes: 180)
        let generator = RoutineGenerator()
        let blocks = generator.generateInitialSchedule(for: profile)

        let sundayCoding = blocks.filter {
            $0.title == "Personal Coding" && $0.recurringDays == [DayOfWeek.sunday.rawValue]
        }
        #expect(sundayCoding.count == 1)
    }

    @Test func allBlocksAreEditable() {
        let profile = UserProfile()
        let blocks = RoutineGenerator().generateInitialSchedule(for: profile)
        #expect(blocks.allSatisfy(\.isEditable))
    }
}
