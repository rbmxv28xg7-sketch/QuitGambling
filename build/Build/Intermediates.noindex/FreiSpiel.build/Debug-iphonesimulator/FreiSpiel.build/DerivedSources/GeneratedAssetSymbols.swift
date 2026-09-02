import Foundation
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "AccentColor" asset catalog color resource.
    static let accent = DeveloperToolsSupport.ColorResource(name: "AccentColor", bundle: resourceBundle)

    /// The "Background" asset catalog color resource.
    static let background = DeveloperToolsSupport.ColorResource(name: "Background", bundle: resourceBundle)

    /// The "BrickRed" asset catalog color resource.
    static let brickRed = DeveloperToolsSupport.ColorResource(name: "BrickRed", bundle: resourceBundle)

    /// The "EucalyptusLight" asset catalog color resource.
    static let eucalyptusLight = DeveloperToolsSupport.ColorResource(name: "EucalyptusLight", bundle: resourceBundle)

    /// The "MutedGold" asset catalog color resource.
    static let mutedGold = DeveloperToolsSupport.ColorResource(name: "MutedGold", bundle: resourceBundle)

    /// The "SageGreen" asset catalog color resource.
    static let sageGreen = DeveloperToolsSupport.ColorResource(name: "SageGreen", bundle: resourceBundle)

    /// The "SlateBlue" asset catalog color resource.
    static let slateBlue = DeveloperToolsSupport.ColorResource(name: "SlateBlue", bundle: resourceBundle)

    /// The "Surface" asset catalog color resource.
    static let surface = DeveloperToolsSupport.ColorResource(name: "Surface", bundle: resourceBundle)

    /// The "SurfaceHover" asset catalog color resource.
    static let surfaceHover = DeveloperToolsSupport.ColorResource(name: "SurfaceHover", bundle: resourceBundle)

    /// The "Terracotta" asset catalog color resource.
    static let terracotta = DeveloperToolsSupport.ColorResource(name: "Terracotta", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

}

