import Foundation

struct ResolvedScheduleBlock: Identifiable, Equatable {
    let id: UUID
    let sourceBlockId: UUID
    let title: String
    let blockType: String
    let startTime: Date
    let endTime: Date
    let icon: String?
    let isEditable: Bool
}

protocol ScheduleServiceProtocol {
    func resolvedBlocks(for date: Date) throws -> [ResolvedScheduleBlock]
    func currentBlock(for date: Date) throws -> ResolvedScheduleBlock?
}

struct ScheduleService: ScheduleServiceProtocol {
    private let scheduleRepository: ScheduleRepositoryProtocol

    init(scheduleRepository: ScheduleRepositoryProtocol) {
        self.scheduleRepository = scheduleRepository
    }

    func resolvedBlocks(for date: Date) throws -> [ResolvedScheduleBlock] {
        let allBlocks = try scheduleRepository.fetchAll()
        let weekday = Calendar.current.component(.weekday, from: date)

        return allBlocks.compactMap { block in
            if block.isRecurring {
                guard block.recurringDays.isEmpty || block.recurringDays.contains(weekday) else {
                    return nil
                }
            } else {
                guard Calendar.current.isDate(block.startTime, inSameDayAs: date) else {
                    return nil
                }
            }

            let start = DateComposer.combineTime(from: block.startTime, on: date)
            let end = DateComposer.combineTime(from: block.endTime, on: date)

            return ResolvedScheduleBlock(
                id: UUID(),
                sourceBlockId: block.id,
                title: block.title,
                blockType: block.blockType,
                startTime: start,
                endTime: end,
                icon: block.icon,
                isEditable: block.isEditable
            )
        }
        .sorted { $0.startTime < $1.startTime }
    }

    func currentBlock(for date: Date = .now) throws -> ResolvedScheduleBlock? {
        try resolvedBlocks(for: date).first { block in
            block.startTime <= date && block.endTime > date
        }
    }
}
