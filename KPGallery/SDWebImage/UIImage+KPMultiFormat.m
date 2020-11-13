/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImage+KPMultiFormat.h"

#import "objc/runtime.h"
#import "KPSDWebImageCodersManager.h"

@implementation UIImage (KPMultiFormat)

#if KPSD_MAC
- (NSUInteger)kpsd_imageLoopCount {
    NSUInteger imageLoopCount = 0;
    for (NSImageRep *rep in self.representations) {
        if ([rep isKindOfClass:[NSBitmapImageRep class]]) {
            NSBitmapImageRep *bitmapRep = (NSBitmapImageRep *)rep;
            imageLoopCount = [[bitmapRep valueForProperty:NSImageLoopCount] unsignedIntegerValue];
            break;
        }
    }
    return imageLoopCount;
}

- (void)setSd_imageLoopCount:(NSUInteger)kpsd_imageLoopCount {
    for (NSImageRep *rep in self.representations) {
        if ([rep isKindOfClass:[NSBitmapImageRep class]]) {
            NSBitmapImageRep *bitmapRep = (NSBitmapImageRep *)rep;
            [bitmapRep setProperty:NSImageLoopCount withValue:@(kpsd_imageLoopCount)];
            break;
        }
    }
}

#else

- (NSUInteger)kpsd_imageLoopCount {
    NSUInteger imageLoopCount = 0;
    NSNumber *value = objc_getAssociatedObject(self, @selector(kpsd_imageLoopCount));
    if ([value isKindOfClass:[NSNumber class]]) {
        imageLoopCount = value.unsignedIntegerValue;
    }
    return imageLoopCount;
}

- (void)setSd_imageLoopCount:(NSUInteger)kpsd_imageLoopCount {
    NSNumber *value = @(kpsd_imageLoopCount);
    objc_setAssociatedObject(self, @selector(kpsd_imageLoopCount), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#endif

+ (nullable UIImage *)kpsd_imageWithData:(nullable NSData *)data {
    return [[KPSDWebImageCodersManager sharedInstance] decodedImageWithData:data];
}

- (nullable NSData *)kpsd_imageData {
    return [self kpsd_imageDataAsFormat:SDImageFormatUndefined];
}

- (nullable NSData *)kpsd_imageDataAsFormat:(KPSDImageFormat)imageFormat {
    NSData *imageData = nil;
    if (self) {
        imageData = [[KPSDWebImageCodersManager sharedInstance] encodedDataWithImage:self format:imageFormat];
    }
    return imageData;
}


@end
