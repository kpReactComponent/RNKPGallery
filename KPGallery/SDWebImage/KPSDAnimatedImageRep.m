/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "KPSDAnimatedImageRep.h"

#if KPSD_MAC

#import "KPSDWebImageGIFCoder.h"

@interface SDWebImageGIFCoder ()

- (float)kpsd_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source;

@end

@interface KPSDAnimatedImageRep ()

@property (nonatomic, assign, readonly, nullable) CGImageSourceRef imageSource;

@end

@implementation KPSDAnimatedImageRep

// `NSBitmapImageRep` will use `kCGImagePropertyGIFDelayTime` whenever you call `setProperty:withValue:` with `NSImageCurrentFrame` to change the current frame. We override it and use the actual `kCGImagePropertyGIFUnclampedDelayTime` if need.
- (void)setProperty:(NSBitmapImageRepPropertyKey)property withValue:(id)value {
    [super setProperty:property withValue:value];
    if ([property isEqualToString:NSImageCurrentFrame]) {
        // Access the image source
        CGImageSourceRef imageSource = self.imageSource;
        if (!imageSource) {
            return;
        }
        // Check format type
        CFStringRef type = CGImageSourceGetType(imageSource);
        if (!type) {
            return;
        }
        NSUInteger index = [value unsignedIntegerValue];
        float frameDuration = 0;
        // Through we currently process GIF only, in the 5.x we support APNG so we keep the extensibility
        if (CFStringCompare(type, kUTTypeGIF, 0) == kCFCompareEqualTo) {
            frameDuration = [[SDWebImageGIFCoder sharedCoder] kpsd_frameDurationAtIndex:index source:imageSource];
        }
        if (!frameDuration) {
            return;
        }
        // Reset super frame duration with the actual frame duration
        [super setProperty:NSImageCurrentFrameDuration withValue:@(frameDuration)];
    }
}

- (CGImageSourceRef)imageSource {
    if (_tiffData) {
        return (__bridge CGImageSourceRef)(_tiffData);
    }
    return NULL;
}

@end

#endif
