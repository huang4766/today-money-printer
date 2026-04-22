import SwiftUI
import Combine
import Foundation

struct WageSettings: Codable, Equatable {
    enum Mode: String, Codable, CaseIterable, Identifiable {
        case monthly
        case hourly

        var id: String { rawValue }

        var title: String {
            switch self {
            case .monthly:
                return "按月薪"
            case .hourly:
                return "按时薪"
            }
        }
    }

    enum ManualState: String, Codable, CaseIterable, Identifiable {
        case auto
        case working
        case slacking
        case offDuty

        var id: String { rawValue }

        var title: String {
            switch self {
            case .auto:
                return "自动"
            case .working:
                return "开工"
            case .slacking:
                return "摸鱼"
            case .offDuty:
                return "收工"
            }
        }
    }

    enum StatusBarStyle: String, Codable, CaseIterable, Identifiable {
        case amountAndRate
        case amountOnly
        case amountAndProgress
        case amountAndWorked
        case iconAndAmount

        var id: String { rawValue }

        var title: String {
            switch self {
            case .amountAndRate:
                return "金额+每秒"
            case .amountOnly:
                return "只看金额"
            case .amountAndProgress:
                return "金额+进度"
            case .amountAndWorked:
                return "金额+工时"
            case .iconAndAmount:
                return "图标+金额"
            }
        }
    }

    var mode: Mode = .monthly
    var manualState: ManualState = .auto
    var statusBarStyle: StatusBarStyle = .amountAndRate
    var monthlySalary: Double = 12000
    var monthlyWorkDays: Double = 22
    var hourlyRate: Double = 68
    var startTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: .now) ?? .now
    var endTime: Date = Calendar.current.date(bySettingHour: 18, minute: 30, second: 0, of: .now) ?? .now
    var breakStartTime: Date = Calendar.current.date(bySettingHour: 12, minute: 30, second: 0, of: .now) ?? .now
    var breakMinutes: Double = 90
    var excludeWeekends: Bool = true
    var legalHolidaysText: String = ""
    var makeupWorkdaysText: String = ""
    var overtimeEnabled: Bool = false
    var overtimeStartTime: Date = Calendar.current.date(bySettingHour: 19, minute: 30, second: 0, of: .now) ?? .now
    var overtimeEndTime: Date = Calendar.current.date(bySettingHour: 21, minute: 30, second: 0, of: .now) ?? .now
    var overtimeMultiplier: Double = 1.5
    var holidaySourceURL: String = ""
    var holidayLastSyncedAt: Date?
    var trackingDayKey: String = ""
    var pausedWorkedSeconds: Double = 0
    var pausedPayableAmount: Double = 0
    var pauseStartedAt: Date?

    init() {}

    enum CodingKeys: String, CodingKey {
        case mode
        case manualState
        case statusBarStyle
        case monthlySalary
        case monthlyWorkDays
        case hourlyRate
        case startTime
        case endTime
        case breakStartTime
        case breakMinutes
        case excludeWeekends
        case legalHolidaysText
        case makeupWorkdaysText
        case overtimeEnabled
        case overtimeStartTime
        case overtimeEndTime
        case overtimeMultiplier
        case holidaySourceURL
        case holidayLastSyncedAt
        case trackingDayKey
        case pausedWorkedSeconds
        case pausedPayableAmount
        case pauseStartedAt
    }

    init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)

        mode = try container.decodeIfPresent(Mode.self, forKey: .mode) ?? mode
        manualState = try container.decodeIfPresent(ManualState.self, forKey: .manualState) ?? manualState
        statusBarStyle = try container.decodeIfPresent(StatusBarStyle.self, forKey: .statusBarStyle) ?? statusBarStyle
        monthlySalary = try container.decodeIfPresent(Double.self, forKey: .monthlySalary) ?? monthlySalary
        monthlyWorkDays = try container.decodeIfPresent(Double.self, forKey: .monthlyWorkDays) ?? monthlyWorkDays
        hourlyRate = try container.decodeIfPresent(Double.self, forKey: .hourlyRate) ?? hourlyRate
        startTime = try container.decodeIfPresent(Date.self, forKey: .startTime) ?? startTime
        endTime = try container.decodeIfPresent(Date.self, forKey: .endTime) ?? endTime
        breakStartTime = try container.decodeIfPresent(Date.self, forKey: .breakStartTime) ?? breakStartTime
        breakMinutes = try container.decodeIfPresent(Double.self, forKey: .breakMinutes) ?? breakMinutes
        excludeWeekends = try container.decodeIfPresent(Bool.self, forKey: .excludeWeekends) ?? excludeWeekends
        legalHolidaysText = try container.decodeIfPresent(String.self, forKey: .legalHolidaysText) ?? legalHolidaysText
        makeupWorkdaysText = try container.decodeIfPresent(String.self, forKey: .makeupWorkdaysText) ?? makeupWorkdaysText
        overtimeEnabled = try container.decodeIfPresent(Bool.self, forKey: .overtimeEnabled) ?? overtimeEnabled
        overtimeStartTime = try container.decodeIfPresent(Date.self, forKey: .overtimeStartTime) ?? overtimeStartTime
        overtimeEndTime = try container.decodeIfPresent(Date.self, forKey: .overtimeEndTime) ?? overtimeEndTime
        overtimeMultiplier = try container.decodeIfPresent(Double.self, forKey: .overtimeMultiplier) ?? overtimeMultiplier
        holidaySourceURL = try container.decodeIfPresent(String.self, forKey: .holidaySourceURL) ?? holidaySourceURL
        holidayLastSyncedAt = try container.decodeIfPresent(Date.self, forKey: .holidayLastSyncedAt) ?? holidayLastSyncedAt
        trackingDayKey = try container.decodeIfPresent(String.self, forKey: .trackingDayKey) ?? trackingDayKey
        pausedWorkedSeconds = try container.decodeIfPresent(Double.self, forKey: .pausedWorkedSeconds) ?? pausedWorkedSeconds
        pausedPayableAmount = try container.decodeIfPresent(Double.self, forKey: .pausedPayableAmount) ?? pausedPayableAmount
        pauseStartedAt = try container.decodeIfPresent(Date.self, forKey: .pauseStartedAt) ?? pauseStartedAt
    }
}

struct WageMetrics {
    var amountText: String
    var rateText: String
    var fullDayText: String
    var workedText: String
    var detailText: String
    var statusText: String
    var compactAmount: String
    var compactRate: String
    var progress: Double
    var calendarHint: String
    var progressText: String

    static let empty = WageMetrics(
        amountText: "¥0.00",
        rateText: "¥0.00/s",
        fullDayText: "¥0.00",
        workedText: "0分钟",
        detailText: "等待开始",
        statusText: "等待开始",
        compactAmount: "¥0.00",
        compactRate: "(+0.00/s)",
        progress: 0,
        calendarHint: "默认按工作日规则计算",
        progressText: "0%"
    )
}

@MainActor
final class WageStore: ObservableObject {
    private static let legacyBundleIdentifiers = [
        "com.codex.wagebar"
    ]

    @Published var settings: WageSettings
    @Published private(set) var metrics: WageMetrics = .empty
    @Published private(set) var holidaySyncMessage: String = "未同步官方节假日"
    @Published private(set) var holidaySyncInProgress = false

    private let defaultsKey = "WageBar.settings"
    private var timer: AnyCancellable?

    init() {
        self.settings = Self.loadSettings()
        normalizeForCurrentDay(now: .now)
        self.metrics = Self.calculateMetrics(settings: settings, now: .now)
        self.holidaySyncMessage = Self.syncMessage(for: settings)
        self.timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                self?.refresh(now: now)
            }
        triggerAutoHolidaySyncIfNeeded()
    }

    func updateSettings(_ newValue: WageSettings) {
        settings = newValue
        normalizeForCurrentDay(now: .now)
        saveSettings()
        metrics = Self.calculateMetrics(settings: settings, now: .now)
        holidaySyncMessage = Self.syncMessage(for: settings)
    }

    func setManualState(_ newState: WageSettings.ManualState) {
        let now = Date()
        normalizeForCurrentDay(now: now)

        if settings.manualState == .slacking || settings.manualState == .offDuty,
           let pauseStartedAt = settings.pauseStartedAt {
            settings.pausedWorkedSeconds += Self.payableSecondsBetween(
                start: pauseStartedAt,
                end: now,
                settings: settings
            )
            settings.pausedPayableAmount += Self.payableAmountBetween(
                start: pauseStartedAt,
                end: now,
                settings: settings
            )
            settings.pauseStartedAt = nil
        }

        settings.manualState = newState

        if newState == .slacking || newState == .offDuty {
            settings.pauseStartedAt = now
        }

        saveSettings()
        metrics = Self.calculateMetrics(settings: settings, now: now)
    }

    func reset() {
        settings = WageSettings()
        normalizeForCurrentDay(now: .now)
        saveSettings()
        metrics = Self.calculateMetrics(settings: settings, now: .now)
        holidaySyncMessage = Self.syncMessage(for: settings)
    }

    func forceSave() {
        saveSettings()
        holidaySyncMessage = Self.syncMessage(for: settings)
    }

    func syncHolidayCalendar(isAutomatic: Bool = false) {
        let year = Calendar.current.component(.year, from: .now)
        guard !holidaySyncInProgress else { return }
        holidaySyncInProgress = true
        holidaySyncMessage = isAutomatic
            ? "启动时自动同步 \(year) 年节假日..."
            : "正在同步 \(year) 年节假日..."

        Task {
            do {
                let result = try await HolidaySyncService.sync(year: year)
                self.settings.legalHolidaysText = result.holidays.joined(separator: ", ")
                self.settings.makeupWorkdaysText = result.makeupWorkdays.joined(separator: ", ")
                self.settings.holidaySourceURL = result.sourceURL.absoluteString
                self.settings.holidayLastSyncedAt = .now
                self.saveSettings()
                self.metrics = Self.calculateMetrics(settings: self.settings, now: .now)
                self.holidaySyncMessage = isAutomatic
                    ? "已自动同步 \(year) 年官方节假日"
                    : "已同步 \(year) 年官方节假日"
                self.holidaySyncInProgress = false
            } catch {
                self.holidaySyncMessage = isAutomatic
                    ? "自动同步失败，继续使用本地缓存"
                    : "同步失败：\(error.localizedDescription)"
                self.holidaySyncInProgress = false
            }
        }
    }

    private func refresh(now: Date) {
        normalizeForCurrentDay(now: now)

        if (settings.manualState == .slacking || settings.manualState == .offDuty),
           settings.pauseStartedAt == nil {
            settings.pauseStartedAt = now
        }

        metrics = Self.calculateMetrics(settings: settings, now: now)
    }

    private func normalizeForCurrentDay(now: Date) {
        let currentKey = Self.dayKey(for: now)
        if settings.trackingDayKey == currentKey {
            return
        }

        settings.trackingDayKey = currentKey
        settings.pausedWorkedSeconds = 0
        settings.pausedPayableAmount = 0
        settings.pauseStartedAt = nil
        settings.manualState = .auto
        saveSettings()
    }

    private static func syncMessage(for settings: WageSettings) -> String {
        guard let lastSyncedAt = settings.holidayLastSyncedAt else {
            return "未同步官方节假日"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let timestamp = formatter.string(from: lastSyncedAt)
        return "上次同步：\(timestamp)"
    }

    private func triggerAutoHolidaySyncIfNeeded() {
        guard shouldAutoSyncHolidayCalendar(now: .now) else { return }
        syncHolidayCalendar(isAutomatic: true)
    }

    private func shouldAutoSyncHolidayCalendar(now: Date) -> Bool {
        let currentYear = Calendar.current.component(.year, from: now)
        guard HolidaySyncService.supports(year: currentYear) else { return false }

        let missingHolidayData = settings.legalHolidaysText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let missingMakeupData = settings.makeupWorkdaysText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        guard let lastSyncedAt = settings.holidayLastSyncedAt else {
            return missingHolidayData || missingMakeupData || settings.holidaySourceURL.isEmpty
        }

        let syncedYear = Calendar.current.component(.year, from: lastSyncedAt)
        if syncedYear != currentYear {
            return true
        }

        return missingHolidayData || missingMakeupData
    }

    private func saveSettings() {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }

    private static func loadSettings() -> WageSettings {
        guard
            let data = UserDefaults.standard.data(forKey: "WageBar.settings")
                ?? loadLegacySettingsData(),
            let settings = try? JSONDecoder().decode(WageSettings.self, from: data)
        else {
            return WageSettings()
        }

        return settings
    }

    private static func loadLegacySettingsData() -> Data? {
        for bundleIdentifier in legacyBundleIdentifiers {
            if let data = UserDefaults.standard.persistentDomain(forName: bundleIdentifier)?["WageBar.settings"] as? Data {
                return data
            }
        }
        return nil
    }

    private static func calculateMetrics(settings: WageSettings, now: Date) -> WageMetrics {
        let calendar = Calendar.current
        let start = merge(date: now, time: settings.startTime, calendar: calendar)
        let end = merge(date: now, time: settings.endTime, calendar: calendar)
        let breakStart = merge(date: now, time: settings.breakStartTime, calendar: calendar)
        let overtimeStart = merge(date: now, time: settings.overtimeStartTime, calendar: calendar)
        let overtimeEnd = merge(date: now, time: settings.overtimeEndTime, calendar: calendar)

        let regularWorkday = isRegularWorkday(on: now, settings: settings)
        let forcedWorkday = settings.manualState == .working
        let regularEligible = regularWorkday || forcedWorkday

        guard end > start else {
            return buildMetrics(
                earned: 0,
                rate: 0,
                fullDay: 0,
                workedSeconds: 0,
                detail: "请确保下班时间晚于上班时间",
                status: "时间设置有误",
                progress: 0,
                calendarHint: calendarHint(for: now, settings: settings, forcedWorkday: forcedWorkday)
            )
        }

        let regularShiftSeconds = regularEligible
            ? max(end.timeIntervalSince(start) - settings.breakMinutes * 60, 0)
            : 0
        let baseHourlyRate = effectiveHourlyRate(for: settings, shiftSeconds: regularShiftSeconds)
        let basePerSecond = baseHourlyRate / 3600

        let regularWorked = regularWorkedSeconds(
            now: now,
            start: start,
            end: end,
            breakStart: breakStart,
            breakMinutes: settings.breakMinutes,
            regularEligible: regularEligible
        )

        let regularPay = regularWorked * basePerSecond
        let regularFullDay = regularShiftSeconds * basePerSecond

        let overtimeWorked = overtimeWorkedSeconds(
            now: now,
            start: overtimeStart,
            end: overtimeEnd,
            enabled: settings.overtimeEnabled
        )
        let overtimeFullSeconds = overtimeTotalSeconds(start: overtimeStart, end: overtimeEnd, enabled: settings.overtimeEnabled)
        let overtimePerSecond = settings.overtimeEnabled ? basePerSecond * max(settings.overtimeMultiplier, 0) : 0
        let overtimePay = overtimeWorked * overtimePerSecond
        let overtimeFullDay = overtimeFullSeconds * overtimePerSecond

        let pausedWorked = pausedWorkedSecondsUntilNow(settings: settings, now: now)
        let pausedAmount = pausedAmountUntilNow(settings: settings, now: now)
        let pausedWorkedClamped = min(
            pausedWorked,
            max(regularWorked + overtimeWorked, 0)
        )
        let pausedAmountClamped = min(pausedAmount, max(regularPay + overtimePay, 0))

        let currentCombinedRate = currentRate(
            now: now,
            start: start,
            end: end,
            overtimeStart: overtimeStart,
            overtimeEnd: overtimeEnd,
            settings: settings,
            regularEligible: regularEligible,
            basePerSecond: basePerSecond,
            overtimePerSecond: overtimePerSecond,
            breakStart: breakStart
        )

        let pausedRate = settings.manualState == .slacking || settings.manualState == .offDuty ? 0 : currentCombinedRate
        let earnedBeforePause = regularPay + overtimePay
        let earned = max(earnedBeforePause - pausedAmountClamped, 0)
        let workedSeconds = max(regularWorked + overtimeWorked - pausedWorkedClamped, 0)
        let fullDayPay = regularFullDay + overtimeFullDay
        let progress = fullDayPay > 0 ? min(max(earned / fullDayPay, 0), 1) : 0

        let computedStatus = statusText(
            now: now,
            start: start,
            end: end,
            overtimeStart: overtimeStart,
            overtimeEnd: overtimeEnd,
            settings: settings,
            regularEligible: regularEligible,
            currentRate: pausedRate,
            fullDayPay: fullDayPay,
            earned: earned
        )

        let detail = detailText(
            now: now,
            settings: settings,
            regularEligible: regularEligible,
            fullDayPay: fullDayPay,
            start: start,
            earned: earned
        )

        return buildMetrics(
            earned: earned,
            rate: pausedRate,
            fullDay: fullDayPay,
            workedSeconds: workedSeconds,
            detail: detail,
            status: computedStatus,
            progress: progress,
            calendarHint: calendarHint(for: now, settings: settings, forcedWorkday: forcedWorkday)
        )
    }

    private static func buildMetrics(
        earned: Double,
        rate: Double,
        fullDay: Double,
        workedSeconds: Double,
        detail: String,
        status: String,
        progress: Double,
        calendarHint: String
    ) -> WageMetrics {
        WageMetrics(
            amountText: currency(earned),
            rateText: "\(currency(rate))/s",
            fullDayText: currency(fullDay),
            workedText: duration(workedSeconds),
            detailText: detail,
            statusText: status,
            compactAmount: currency(earned),
            compactRate: "(+\(plain(rate))/s)",
            progress: progress,
            calendarHint: calendarHint,
            progressText: "\(Int((progress * 100).rounded()))%"
        )
    }

    private static func effectiveHourlyRate(for settings: WageSettings, shiftSeconds: Double) -> Double {
        switch settings.mode {
        case .hourly:
            return settings.hourlyRate
        case .monthly:
            let workDays = max(settings.monthlyWorkDays, 1)
            let shiftHours = max(shiftSeconds / 3600, 0.1)
            return settings.monthlySalary / workDays / shiftHours
        }
    }

    private static func regularWorkedSeconds(
        now: Date,
        start: Date,
        end: Date,
        breakStart: Date,
        breakMinutes: Double,
        regularEligible: Bool
    ) -> Double {
        guard regularEligible else { return 0 }
        if now <= start { return 0 }
        let totalPaid = max(end.timeIntervalSince(start) - breakMinutes * 60, 0)
        let effectiveEnd = min(max(now, start), end)
        let worked = paidOverlapSeconds(
            from: start,
            to: effectiveEnd,
            shiftStart: start,
            shiftEnd: end,
            breakStart: breakStart,
            breakMinutes: breakMinutes
        )
        return min(max(worked, 0), totalPaid)
    }

    private static func overtimeWorkedSeconds(
        now: Date,
        start: Date,
        end: Date,
        enabled: Bool
    ) -> Double {
        guard enabled, end > start else { return 0 }
        if now <= start { return 0 }
        if now >= end { return end.timeIntervalSince(start) }
        return now.timeIntervalSince(start)
    }

    private static func overtimeTotalSeconds(start: Date, end: Date, enabled: Bool) -> Double {
        guard enabled, end > start else { return 0 }
        return end.timeIntervalSince(start)
    }

    private static func currentRate(
        now: Date,
        start: Date,
        end: Date,
        overtimeStart: Date,
        overtimeEnd: Date,
        settings: WageSettings,
        regularEligible: Bool,
        basePerSecond: Double,
        overtimePerSecond: Double,
        breakStart: Date
    ) -> Double {
        if settings.manualState == .slacking || settings.manualState == .offDuty {
            return 0
        }

        var rate = 0.0

        if regularEligible,
           now >= start,
           now <= end,
           isInPaidRegularWindow(
               now: now,
               start: start,
               end: end,
               breakStart: breakStart,
               breakMinutes: settings.breakMinutes
           ) {
            rate += basePerSecond
        }

        if settings.overtimeEnabled, overtimeEnd > overtimeStart, now >= overtimeStart, now <= overtimeEnd {
            rate += overtimePerSecond
        }

        return rate
    }

    private static func pausedWorkedSecondsUntilNow(settings: WageSettings, now: Date) -> Double {
        var paused = settings.pausedWorkedSeconds
        if (settings.manualState == .slacking || settings.manualState == .offDuty),
           let pauseStartedAt = settings.pauseStartedAt {
            paused += payableSecondsBetween(start: pauseStartedAt, end: now, settings: settings)
        }
        return paused
    }

    private static func pausedAmountUntilNow(settings: WageSettings, now: Date) -> Double {
        var paused = settings.pausedPayableAmount
        if (settings.manualState == .slacking || settings.manualState == .offDuty),
           let pauseStartedAt = settings.pauseStartedAt {
            paused += payableAmountBetween(start: pauseStartedAt, end: now, settings: settings)
        }
        return paused
    }

    private static func payableSecondsBetween(start: Date, end: Date, settings: WageSettings) -> Double {
        guard end > start else { return 0 }

        let regular = regularWorkedBetween(start: start, end: end, settings: settings)
        let overtime = overtimeWorkedBetween(start: start, end: end, settings: settings)
        return regular + overtime
    }

    private static func payableAmountBetween(start: Date, end: Date, settings: WageSettings) -> Double {
        guard end > start else { return 0 }

        let regularSeconds = regularWorkedBetween(start: start, end: end, settings: settings)
        let overtimeSeconds = overtimeWorkedBetween(start: start, end: end, settings: settings)

        let regularShiftSeconds = max(
            merge(date: start, time: settings.endTime, calendar: .current)
                .timeIntervalSince(merge(date: start, time: settings.startTime, calendar: .current))
                - settings.breakMinutes * 60,
            0
        )
        let baseHourlyRate = effectiveHourlyRate(for: settings, shiftSeconds: regularShiftSeconds)
        let basePerSecond = baseHourlyRate / 3600
        let overtimePerSecond = settings.overtimeEnabled ? basePerSecond * max(settings.overtimeMultiplier, 0) : 0

        return regularSeconds * basePerSecond + overtimeSeconds * overtimePerSecond
    }

    private static func regularWorkedBetween(start: Date, end: Date, settings: WageSettings) -> Double {
        let calendar = Calendar.current
        let regularEligible = isRegularWorkday(on: start, settings: settings) || settings.manualState == .working
        guard regularEligible else { return 0 }

        let dayStart = merge(date: start, time: settings.startTime, calendar: calendar)
        let dayEnd = merge(date: start, time: settings.endTime, calendar: calendar)
        guard dayEnd > dayStart else { return 0 }

        let overlapStart = max(start, dayStart)
        let overlapEnd = min(end, dayEnd)
        guard overlapEnd > overlapStart else { return 0 }

        let totalPaid = max(dayEnd.timeIntervalSince(dayStart) - settings.breakMinutes * 60, 0)
        let worked = paidOverlapSeconds(
            from: overlapStart,
            to: overlapEnd,
            shiftStart: dayStart,
            shiftEnd: dayEnd,
            breakStart: merge(date: start, time: settings.breakStartTime, calendar: calendar),
            breakMinutes: settings.breakMinutes
        )
        return min(max(worked, 0), totalPaid)
    }

    private static func paidOverlapSeconds(
        from start: Date,
        to end: Date,
        shiftStart: Date,
        shiftEnd: Date,
        breakStart: Date,
        breakMinutes: Double
    ) -> Double {
        guard end > start else { return 0 }

        let raw = end.timeIntervalSince(start)
        guard breakMinutes > 0 else { return raw }

        let breakWindow = defaultBreakWindow(
            shiftStart: shiftStart,
            shiftEnd: shiftEnd,
            breakStart: breakStart,
            breakMinutes: breakMinutes
        )

        let unpaidBreak = overlapSeconds(
            startA: start,
            endA: end,
            startB: breakWindow.start,
            endB: breakWindow.end
        )

        return max(raw - unpaidBreak, 0)
    }

    private static func isInPaidRegularWindow(
        now: Date,
        start: Date,
        end: Date,
        breakStart: Date,
        breakMinutes: Double
    ) -> Bool {
        guard now >= start, now <= end else { return false }
        guard breakMinutes > 0 else { return true }

        let breakWindow = defaultBreakWindow(
            shiftStart: start,
            shiftEnd: end,
            breakStart: breakStart,
            breakMinutes: breakMinutes
        )

        return !(now >= breakWindow.start && now < breakWindow.end)
    }

    private static func defaultBreakWindow(
        shiftStart: Date,
        shiftEnd: Date,
        breakStart: Date,
        breakMinutes: Double
    ) -> (start: Date, end: Date) {
        let totalSeconds = max(shiftEnd.timeIntervalSince(shiftStart), 0)
        let breakSeconds = min(max(breakMinutes * 60, 0), totalSeconds)
        let clampedStart = min(max(breakStart, shiftStart), shiftEnd)
        let maxStart = shiftEnd.addingTimeInterval(-breakSeconds)
        let adjustedStart = min(clampedStart, max(maxStart, shiftStart))
        let adjustedEnd = min(adjustedStart.addingTimeInterval(breakSeconds), shiftEnd)
        return (adjustedStart, adjustedEnd)
    }

    private static func overlapSeconds(
        startA: Date,
        endA: Date,
        startB: Date,
        endB: Date
    ) -> Double {
        let overlapStart = max(startA, startB)
        let overlapEnd = min(endA, endB)
        return max(overlapEnd.timeIntervalSince(overlapStart), 0)
    }

    private static func overtimeWorkedBetween(start: Date, end: Date, settings: WageSettings) -> Double {
        guard settings.overtimeEnabled else { return 0 }

        let calendar = Calendar.current
        let overtimeStart = merge(date: start, time: settings.overtimeStartTime, calendar: calendar)
        let overtimeEnd = merge(date: start, time: settings.overtimeEndTime, calendar: calendar)
        guard overtimeEnd > overtimeStart else { return 0 }

        let overlapStart = max(start, overtimeStart)
        let overlapEnd = min(end, overtimeEnd)
        guard overlapEnd > overlapStart else { return 0 }
        return overlapEnd.timeIntervalSince(overlapStart)
    }

    private static func statusText(
        now: Date,
        start: Date,
        end: Date,
        overtimeStart: Date,
        overtimeEnd: Date,
        settings: WageSettings,
        regularEligible: Bool,
        currentRate: Double,
        fullDayPay: Double,
        earned: Double
    ) -> String {
        switch settings.manualState {
        case .slacking:
            return "摸鱼中"
        case .offDuty:
            return "手动收工"
        case .working:
            if regularEligible {
                return currentRate > 0 ? "手动开工中" : "手动开工"
            }
        case .auto:
            break
        }

        let hasFutureRegular = regularEligible && now < start
        let hasFutureOvertime = settings.overtimeEnabled && overtimeEnd > overtimeStart && now < overtimeStart

        if currentRate > 0 {
            return "正在赚钱"
        }

        if !regularEligible && !settings.overtimeEnabled {
            return "今日休息"
        }

        if hasFutureRegular || hasFutureOvertime {
            return "等待开始"
        }

        if earned > 0 || fullDayPay > 0 {
            return "今日已收工"
        }

        return "等待开始"
    }

    private static func detailText(
        now: Date,
        settings: WageSettings,
        regularEligible: Bool,
        fullDayPay: Double,
        start: Date,
        earned: Double
    ) -> String {
        switch settings.manualState {
        case .slacking:
            return "暂停累计中，切回自动或开工后会继续从当前时刻计算。"
        case .offDuty:
            return "今天已在手动收工时刻冻结收入，不再继续累计。"
        case .working:
            if !regularEligible {
                return "已强制把今天视为工作日，你可以照常按班次累计收入。"
            }
        case .auto:
            break
        }

        if !regularEligible && !settings.overtimeEnabled {
            return "今天不计常规工时；如需记录，填补班日或开启加班时段。"
        }

        if now < start && regularEligible {
            return "今天上班从 \(timeString(start)) 开始。"
        }

        if earned > 0 {
            return "按照当前规则，今天预计累计 \(currency(fullDayPay))。"
        }

        return "等待进入可计薪时段。"
    }

    private static func calendarHint(for now: Date, settings: WageSettings, forcedWorkday: Bool) -> String {
        let day = dayKey(for: now)
        let holidays = parsedDateSet(from: settings.legalHolidaysText)
        let makeups = parsedDateSet(from: settings.makeupWorkdaysText)
        let weekend = Calendar.current.isDateInWeekend(now)

        if forcedWorkday {
            return "\(day) 已手动强制按工作日计算"
        }
        if holidays.contains(day) {
            return "\(day) 命中法定节假日"
        }
        if makeups.contains(day) {
            return "\(day) 命中补班工作日"
        }
        if weekend && settings.excludeWeekends {
            return "\(day) 是周末，默认不计常规工时"
        }
        return "\(day) 按正常工作日规则计算"
    }

    private static func isRegularWorkday(on date: Date, settings: WageSettings) -> Bool {
        let key = dayKey(for: date)
        let holidays = parsedDateSet(from: settings.legalHolidaysText)
        if holidays.contains(key) {
            return false
        }

        let makeups = parsedDateSet(from: settings.makeupWorkdaysText)
        if makeups.contains(key) {
            return true
        }

        if settings.excludeWeekends && Calendar.current.isDateInWeekend(date) {
            return false
        }

        return true
    }

    private static func parsedDateSet(from text: String) -> Set<String> {
        let separators = CharacterSet(charactersIn: ", \n\t")
        let tokens = text
            .components(separatedBy: separators)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return Set(tokens)
    }

    private static func merge(date: Date, time: Date, calendar: Calendar) -> Date {
        let timeParts = calendar.dateComponents([.hour, .minute], from: time)
        return calendar.date(bySettingHour: timeParts.hour ?? 0, minute: timeParts.minute ?? 0, second: 0, of: date) ?? date
    }

    private static func currency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "¥0.00"
    }

    private static func plain(_ value: Double) -> String {
        String(format: "%.2f", value)
    }

    private static func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private static func duration(_ seconds: Double) -> String {
        let totalSeconds = max(0, Int(seconds))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        if hours == 0 {
            return "\(minutes)分钟"
        }
        return "\(hours)小时\(minutes)分钟"
    }

    private static func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

private enum HolidaySyncService {
    struct Result {
        let holidays: [String]
        let makeupWorkdays: [String]
        let sourceURL: URL
    }

    static func sync(year: Int) async throws -> Result {
        guard let sourceURL = sourceURL(for: year) else {
            throw HolidaySyncError.unsupportedYear(year)
        }

        let (data, _) = try await URLSession.shared.data(from: sourceURL)
        guard let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .unicode) else {
            throw HolidaySyncError.invalidEncoding
        }

        let text = normalizeHTML(html)
        let sections = try extractSections(from: text)

        let holidays = sections.flatMap { parseHolidayDates(year: year, section: $0) }
        let makeupWorkdays = sections.flatMap { parseMakeupDates(year: year, section: $0) }

        guard !holidays.isEmpty else {
            throw HolidaySyncError.parseFailed
        }

        return Result(
            holidays: Array(Set(holidays)).sorted(),
            makeupWorkdays: Array(Set(makeupWorkdays)).sorted(),
            sourceURL: sourceURL
        )
    }

    static func supports(year: Int) -> Bool {
        sourceURL(for: year) != nil
    }

    private static func sourceURL(for year: Int) -> URL? {
        switch year {
        case 2026:
            return URL(string: "https://www.gov.cn/zhengce/zhengceku/202511/content_7047091.htm")
        default:
            return nil
        }
    }

    private static func normalizeHTML(_ html: String) -> String {
        html
            .replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&ensp;", with: " ")
            .replacingOccurrences(of: "&emsp;", with: " ")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }

    private static func extractSections(from text: String) throws -> [String] {
        let ranges = [
            "一、元旦：" : "二、春节：",
            "二、春节：" : "三、清明节：",
            "三、清明节：" : "四、劳动节：",
            "四、劳动节：" : "五、端午节：",
            "五、端午节：" : "六、中秋节：",
            "六、中秋节：" : "七、国庆节：",
            "七、国庆节：" : "鼓励单位和个人结合落实带薪年休假等制度"
        ]

        let sections = ranges.compactMap { startMarker, endMarker -> String? in
            guard
                let startRange = text.range(of: startMarker),
                let endRange = text.range(of: endMarker),
                startRange.upperBound <= endRange.lowerBound
            else {
                return nil
            }
            return String(text[startRange.lowerBound..<endRange.lowerBound])
        }

        if sections.count < ranges.count {
            throw HolidaySyncError.parseFailed
        }

        return sections
    }

    private static func parseHolidayDates(year: Int, section: String) -> [String] {
        let pattern = #"(\d{1,2})月(\d{1,2})日.*?至(?:(\d{1,2})月)?(\d{1,2})日"#
        guard let match = firstMatch(pattern: pattern, in: section) else {
            return []
        }

        let startMonth = Int(match[1]) ?? 0
        let startDay = Int(match[2]) ?? 0
        let endMonth = Int(match[3]).flatMap { Optional($0) } ?? startMonth
        let endDay = Int(match[4]) ?? 0

        return enumerateDates(year: year, startMonth: startMonth, startDay: startDay, endMonth: endMonth, endDay: endDay)
    }

    private static func parseMakeupDates(year: Int, section: String) -> [String] {
        guard let sentenceStart = section.range(of: "。") else {
            return []
        }

        let suffix = String(section[sentenceStart.upperBound...])
        let pattern = #"(\d{1,2})月(\d{1,2})日"#
        return allMatches(pattern: pattern, in: suffix).compactMap { match in
            guard let month = Int(match[1]), let day = Int(match[2]) else {
                return nil
            }
            return formatDate(year: year, month: month, day: day)
        }
    }

    private static func enumerateDates(year: Int, startMonth: Int, startDay: Int, endMonth: Int, endDay: Int) -> [String] {
        var dates: [String] = []
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .current

        guard
            let start = calendar.date(from: DateComponents(year: year, month: startMonth, day: startDay)),
            let end = calendar.date(from: DateComponents(year: year, month: endMonth, day: endDay))
        else {
            return []
        }

        var current = start
        while current <= end {
            dates.append(formatDate(current))
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else {
                break
            }
            current = next
        }
        return dates
    }

    private static func formatDate(year: Int, month: Int, day: Int) -> String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }

    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private static func firstMatch(pattern: String, in text: String) -> [String]? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }
        guard let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) else {
            return nil
        }
        return extractGroups(match: match, in: text)
    }

    private static func allMatches(pattern: String, in text: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        return matches.map { extractGroups(match: $0, in: text) }
    }

    private static func extractGroups(match: NSTextCheckingResult, in text: String) -> [String] {
        (0..<match.numberOfRanges).map { index in
            let range = match.range(at: index)
            guard let swiftRange = Range(range, in: text) else { return "" }
            return String(text[swiftRange])
        }
    }
}

private enum HolidaySyncError: LocalizedError {
    case unsupportedYear(Int)
    case invalidEncoding
    case parseFailed

    var errorDescription: String? {
        switch self {
        case .unsupportedYear(let year):
            return "暂不支持自动同步 \(year) 年"
        case .invalidEncoding:
            return "官方页面编码无法识别"
        case .parseFailed:
            return "官方页面解析失败"
        }
    }
}
