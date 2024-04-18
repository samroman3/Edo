#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "appstore" asset catalog image resource.
static NSString * const ACImageNameAppstore AC_SWIFT_PRIVATE = @"appstore";

/// The "eaze" asset catalog image resource.
static NSString * const ACImageNameEaze AC_SWIFT_PRIVATE = @"eaze";

/// The "playstore" asset catalog image resource.
static NSString * const ACImageNamePlaystore AC_SWIFT_PRIVATE = @"playstore";

#undef AC_SWIFT_PRIVATE