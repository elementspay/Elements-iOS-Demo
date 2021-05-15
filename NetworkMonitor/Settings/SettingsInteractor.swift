//
//  SettingsInteractor.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 11/15/19.
//

import UIKit

enum SettingsSection: String, ElementsFilterSection {
    case themeSettings = "Theme Settings"
    case enabledRewrite = "Rewrite"
    case enabledAutoRefresh = "Auto Refresh"

    var displayID: String { return rawValue }
    var toServerID: String { return rawValue }
}

enum SupportedThemeType: String {
    case dark = "Dark Mode"
    case light = "Light Mode"

    public static let allCases: [SupportedThemeType] = [
        .dark,
        .light
    ]
}

final class SettingsInteractor {

    private let presenter: SettingsPresenterType
    private var currentSettings: [ElementsFilterContainer]?

    init(presenter: SettingsPresenterType,
         currentSettings: [ElementsFilterContainer]?) {
        self.presenter = presenter
        self.currentSettings = currentSettings
    }
}

extension SettingsInteractor {

    func loadPresentationData() {
        if let currentSettings = currentSettings, !currentSettings.isEmpty {
            presenter.presentDisplayData(settings: currentSettings)
            return
        }
        let settings = configSettings()
        currentSettings = settings
        presenter.presentDisplayData(settings: settings)
    }

    func resetFilters() {
        let settings = configSettings()
        currentSettings = settings
        presenter.presentDisplayData(settings: settings)
    }

    func getCurrentSettings() -> [ElementsFilterContainer] {
        return currentSettings ?? []
    }

    private func configSettings() -> [ElementsFilterContainer] {
        return [generateThemeSettings(),
                generateRewriteSettings(),
                generateAutoRefreshSettings()]
    }

    private func generateThemeSettings() -> ElementsFilterContainer {
        return ElementsFilterContainer(
            section: SettingsSection.themeSettings,
            selections: SupportedThemeType.allCases.map { ElementsFilterSelection($0.rawValue, $0.rawValue) },
            selectedItem: ApplicationDependency.manager.theme == .light ? SupportedThemeType.light.rawValue : SupportedThemeType.dark.rawValue
        )
    }

    private func generateRewriteSettings() -> ElementsFilterContainer {
        return ElementsFilterContainer(
            section: SettingsSection.enabledRewrite,
            selection: ElementsFilterSelection("Enable Rewrite", "Enable Rewrite"),
            selected: ApplicationSettings.enabledRewrite
        )
    }

    private func generateAutoRefreshSettings() -> ElementsFilterContainer {
        return ElementsFilterContainer(
            section: SettingsSection.enabledAutoRefresh,
            selection: ElementsFilterSelection("Enabl Auto Refresh", "Enable Auto Refresh"),
            selected: ApplicationSettings.enabledAutoRefresh
        )
    }
}
