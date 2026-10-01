//
//  ShieldConfigurationExtension.swift
//  FreiSpiel
//

import ManagedSettings
import ManagedSettingsUI
import UIKit
import os

private let logger = Logger(subsystem: "com.lennertroehrig.freispiel.ShieldConfiguration", category: "Shield")

class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        let appName = application.localizedDisplayName ?? "Glücksspiel-App"
        logger.info("🛡️ Shield requested for app: \(appName)")
        return createShield(
            title: "Quit Gambling Schutzschild",
            subtitle: "Die App '\(appName)' ist pausiert. Halte kurz inne, atme tief durch und bewahre deinen Fokus."
        )
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        let categoryName = category.localizedDisplayName ?? "Glücksspiel"
        logger.info("🛡️ Shield requested for app in category: \(categoryName)")
        return createShield(
            title: "Quit Gambling Schutzschild",
            subtitle: "Die Kategorie '\(categoryName)' ist durch dein aktives Quit Gambling Schutzschild blockiert."
        )
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        let domain = webDomain.domain ?? "Glücksspiel-Website"
        logger.info("🛡️ Shield requested for webDomain: \(domain)")
        return createShield(
            title: "Quit Gambling Schutzschild",
            subtitle: "Die Website '\(domain)' ist pausiert. Halte kurz inne, atme tief durch und bewahre deinen Frieden."
        )
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        let categoryName = category.localizedDisplayName ?? "Glücksspiel"
        logger.info("🛡️ Shield requested for webDomain in category: \(categoryName)")
        return createShield(
            title: "Quit Gambling Schutzschild",
            subtitle: "Diese Website gehört zur blockierten Kategorie '\(categoryName)'. Du hast die Kontrolle."
        )
    }

    private func createShield(title: String, subtitle: String) -> ShieldConfiguration {
        // Deep obsidian canvas matching Quit Gambling's luxury dark glass theme
        let obsidianCanvas = UIColor(red: 12/255, green: 7/255, blue: 8/255, alpha: 0.98)
        let warmAmberGold = UIColor(red: 245/255, green: 158/255, blue: 11/255, alpha: 1.0)
        let warmTerracotta = UIColor(red: 224/255, green: 102/255, blue: 68/255, alpha: 0.9)
        let warmIvory = UIColor(red: 252/255, green: 250/255, blue: 245/255, alpha: 1.0)
        let titaniumGray = UIColor(red: 198/255, green: 184/255, blue: 174/255, alpha: 0.9)
        let darkButtonText = UIColor(red: 18/255, green: 10/255, blue: 8/255, alpha: 1.0)

        // Two-tone palette symbol configuration for shield icon
        let paletteConfig = UIImage.SymbolConfiguration(paletteColors: [warmAmberGold, warmTerracotta])
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 72, weight: .semibold).applying(paletteConfig)
        let fallbackConfig = UIImage.SymbolConfiguration(pointSize: 72, weight: .semibold)
        let icon = UIImage(systemName: "shield.checkered", withConfiguration: symbolConfig)
            ?? UIImage(systemName: "shield.fill", withConfiguration: fallbackConfig)?.withTintColor(warmAmberGold, renderingMode: .alwaysOriginal)

        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: obsidianCanvas,
            icon: icon,
            title: ShieldConfiguration.Label(text: title, color: warmIvory),
            subtitle: ShieldConfiguration.Label(text: subtitle, color: titaniumGray),
            primaryButtonLabel: ShieldConfiguration.Label(text: "🛡️ In Sicherheit bleiben", color: darkButtonText),
            primaryButtonBackgroundColor: warmAmberGold,
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Quit Gambling öffnen", color: warmAmberGold)
        )
    }
}
