/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "KPSDWebImageCompat.h"
#import "NSData+KPImageContentType.h"

@interface UIImage (KPMultiFormat)

/**
 * UIKit:
 * For static image format, this value is always 0.
 * For animated image format, 0 means infinite looping.
 * Note that because of the limitations of categories this property can get out of sync if you create another instance with CGImage or other methods.
 * AppKit:
 * NSImage currently only support animated via GIF imageRep unlike UIImage.
 * The getter of this property will get the loop count from GIF imageRep
 * The setter of this property will set the loop count from GIF imageRep
 */
@property (nonatomic, assign) NSUInteger kpsd_imageLoopCount;

+ (nullable UIImage *)kpsd_imageWithData:(nullable NSData *)data;
- (nullable NSData *)kpsd_imageData;
- (nullable NSData *)kpsd_imageDataAsFormat:(KPSDImageFormat)imageFormat;

@end
