#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.freispiel.app";

/// The "AccentColor" asset catalog color resource.
static NSString * const ACColorNameAccentColor AC_SWIFT_PRIVATE = @"AccentColor";

/// The "Background" asset catalog color resource.
static NSString * const ACColorNameBackground AC_SWIFT_PRIVATE = @"Background";

/// The "BrickRed" asset catalog color resource.
static NSString * const ACColorNameBrickRed AC_SWIFT_PRIVATE = @"BrickRed";

/// The "EucalyptusLight" asset catalog color resource.
static NSString * const ACColorNameEucalyptusLight AC_SWIFT_PRIVATE = @"EucalyptusLight";

/// The "MutedGold" asset catalog color resource.
static NSString * const ACColorNameMutedGold AC_SWIFT_PRIVATE = @"MutedGold";

/// The "SageGreen" asset catalog color resource.
static NSString * const ACColorNameSageGreen AC_SWIFT_PRIVATE = @"SageGreen";

/// The "SlateBlue" asset catalog color resource.
static NSString * const ACColorNameSlateBlue AC_SWIFT_PRIVATE = @"SlateBlue";

/// The "Surface" asset catalog color resource.
static NSString * const ACColorNameSurface AC_SWIFT_PRIVATE = @"Surface";

/// The "SurfaceHover" asset catalog color resource.
static NSString * const ACColorNameSurfaceHover AC_SWIFT_PRIVATE = @"SurfaceHover";

/// The "Terracotta" asset catalog color resource.
static NSString * const ACColorNameTerracotta AC_SWIFT_PRIVATE = @"Terracotta";

#undef AC_SWIFT_PRIVATE
