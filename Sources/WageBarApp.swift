import SwiftUI
import AppKit

@main
struct WageBarApp: App {
    @StateObject private var store = WageStore()

    var body: some Scene {
        MenuBarExtra {
            MenuContentView(store: store)
                .frame(width: 410, height: 760)
        } label: {
            StatusBarLabel(metrics: store.metrics, style: store.settings.statusBarStyle)
        }
        .menuBarExtraStyle(.window)
    }
}

private struct StatusBarLabel: View {
    let metrics: WageMetrics
    let style: WageSettings.StatusBarStyle

    var body: some View {
        Group {
            switch style {
            case .amountAndRate:
                textLabel("💰 \(metrics.compactAmount) \(metrics.compactRate)")
            case .amountOnly:
                textLabel(metrics.compactAmount)
            case .amountAndProgress:
                textLabel("💰 \(metrics.compactAmount) \(metrics.progressText)")
            case .amountAndWorked:
                textLabel("💰 \(metrics.compactAmount) \(metrics.workedText)")
            case .iconAndAmount:
                textLabel("💰 \(metrics.compactAmount)")
            }
        }
    }

    private func textLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .monospacedDigit()
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
    }
}

private struct MenuContentView: View {
    @ObservedObject var store: WageStore
    @State private var saveFlash = "自动保存已开启"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                topBar
                header
                summaryCard
                statusCard
                quickActionsCard
                settingsForm
                footerActions
            }
            .padding(16)
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private var topBar: some View {
        HStack {
            Button {
                NSApp.keyWindow?.close()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .frame(width: 30, height: 30)
                    .background(Color.black.opacity(0.06))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            Text("设置")
                .font(.system(size: 17, weight: .semibold))

            Spacer()

            Button {
                store.forceSave()
                saveFlash = "刚刚已手动保存"
            } label: {
                Text("保存")
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.96))
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 3)
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("今日印钞")
                .font(.system(size: 28, weight: .bold))
            Text(store.metrics.statusText)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
            Text(store.metrics.calendarHint)
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
            Text(saveFlash)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
    }

    private var summaryCard: some View {
        card {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("今日已赚")
                Text(store.metrics.amountText)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text(store.metrics.detailText)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                ProgressView(value: store.metrics.progress)
                    .tint(.yellow)

                HStack {
                    metricBlock(title: "每秒", value: store.metrics.rateText)
                    metricBlock(title: "全天", value: store.metrics.fullDayText)
                    metricBlock(title: "已工作", value: store.metrics.workedText)
                }
            }
        }
    }

    private var statusCard: some View {
        card {
            VStack(alignment: .leading, spacing: 10) {
                Text("状态切换")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)

                Picker("状态", selection: Binding(
                    get: { store.settings.manualState },
                    set: { store.setManualState($0) }
                )) {
                    ForEach(WageSettings.ManualState.allCases) { state in
                        Text(state.title).tag(state)
                    }
                }
                .pickerStyle(.segmented)

                Text("`自动` 按规则跑；`开工` 强制今天按正常班计算；`摸鱼` 暂停累计；`收工` 从切换时刻起冻结今天收入。")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var quickActionsCard: some View {
        card {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("快捷操作")

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ], spacing: 10) {
                    actionButton("同步节假日", systemImage: "arrow.triangle.2.circlepath") {
                        store.syncHolidayCalendar()
                    }
                    .disabled(store.holidaySyncInProgress)

                    actionButton("打开数据目录", systemImage: "folder") {
                        openDataFolder()
                    }

                    actionButton("查看官方来源", systemImage: "link") {
                        openSourceURL()
                    }
                    .disabled(store.settings.holidaySourceURL.isEmpty)

                    actionButton("恢复默认", systemImage: "arrow.counterclockwise") {
                        store.reset()
                        saveFlash = "已恢复默认配置"
                    }
                }
            }
        }
    }

    private func metricBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var settingsForm: some View {
        VStack(alignment: .leading, spacing: 14) {
            card {
                VStack(alignment: .leading, spacing: 12) {
                    sectionTitle("基础设置")

                    Picker("计算方式", selection: $store.settings.mode) {
                        ForEach(WageSettings.Mode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    if store.settings.mode == .monthly {
                        HStack(spacing: 12) {
                            numericField("月薪", value: $store.settings.monthlySalary, step: 100)
                            numericField("每月工作日", value: $store.settings.monthlyWorkDays, step: 1)
                        }
                    } else {
                        numericField("时薪", value: $store.settings.hourlyRate, step: 1)
                    }

                    HStack(spacing: 12) {
                        timePicker("上班", selection: $store.settings.startTime)
                        timePicker("下班", selection: $store.settings.endTime)
                    }

                    Picker("状态栏显示", selection: $store.settings.statusBarStyle) {
                        ForEach(WageSettings.StatusBarStyle.allCases) { style in
                            Text(style.title).tag(style)
                        }
                    }
                    .pickerStyle(.menu)

                    timePicker("午休开始", selection: $store.settings.breakStartTime)
                    numericField("午休分钟", value: $store.settings.breakMinutes, step: 10)
                }
            }

            card {
                VStack(alignment: .leading, spacing: 12) {
                    sectionTitle("工作日规则")

                    Toggle("周末默认不计薪", isOn: $store.settings.excludeWeekends)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("官方节假日同步")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.secondary)
                            Text(store.holidaySyncMessage)
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button(store.holidaySyncInProgress ? "同步中..." : "同步官方") {
                            store.syncHolidayCalendar()
                        }
                        .disabled(store.holidaySyncInProgress)
                    }

                    textField(
                        "法定节假日",
                        text: $store.settings.legalHolidaysText,
                        prompt: "YYYY-MM-DD, YYYY-MM-DD"
                    )

                    textField(
                        "补班工作日",
                        text: $store.settings.makeupWorkdaysText,
                        prompt: "YYYY-MM-DD, YYYY-MM-DD"
                    )

                    Text("日期支持逗号、空格或换行分隔。节假日优先级高于普通工作日，补班日可让周末照常计薪。")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)

                    if let sourceURL = URL(string: store.settings.holidaySourceURL), !store.settings.holidaySourceURL.isEmpty {
                        Link("查看官方来源", destination: sourceURL)
                            .font(.system(size: 11))
                    }
                }
            }

            card {
                VStack(alignment: .leading, spacing: 12) {
                    sectionTitle("加班时段")

                    Toggle("启用加班时段", isOn: $store.settings.overtimeEnabled)

                    if store.settings.overtimeEnabled {
                        HStack(spacing: 12) {
                            timePicker("加班开始", selection: $store.settings.overtimeStartTime)
                            timePicker("加班结束", selection: $store.settings.overtimeEndTime)
                        }

                        numericField("加班倍率", value: $store.settings.overtimeMultiplier, step: 0.1)

                        Text("加班按 `基础时薪 x 倍率` 追加计算，可用于工作日晚班，也可用于周末/节假日补录。")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .onChange(of: store.settings) { _, newValue in
            store.updateSettings(newValue)
        }
    }

    private func numericField(_ title: String, value: Binding<Double>, step: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
            HStack {
                TextField(title, value: value, format: .number)
                    .textFieldStyle(.roundedBorder)
                Stepper("", value: value, step: step)
                    .labelsHidden()
            }
        }
    }

    private func textField(_ title: String, text: Binding<String>, prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
            TextField(prompt, text: text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...3)
        }
    }

    private func timePicker(_ title: String, selection: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
            DatePicker("", selection: selection, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(.field)
        }
    }

    private var footerActions: some View {
        HStack {
            Button("恢复默认") {
                store.reset()
                saveFlash = "已恢复默认配置"
            }

            Spacer()

            Button("退出") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.tertiary)
            .textCase(.uppercase)
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.black.opacity(0.04), lineWidth: 1)
            )
    }

    private func actionButton(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }

    private func openSourceURL() {
        guard let url = URL(string: store.settings.holidaySourceURL), !store.settings.holidaySourceURL.isEmpty else { return }
        NSWorkspace.shared.open(url)
    }

    private func openDataFolder() {
        let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return }
        let preferencesURL = libraryURL?
            .appendingPathComponent("Preferences", isDirectory: true)
            .appendingPathComponent("\(bundleIdentifier).plist", isDirectory: false)
        if let preferencesURL {
            NSWorkspace.shared.activateFileViewerSelecting([preferencesURL])
        }
    }
}
