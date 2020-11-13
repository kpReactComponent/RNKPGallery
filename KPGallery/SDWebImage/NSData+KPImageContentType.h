/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Fabrice Aneche
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "KPSDWebImageCompat.h"

typedef NS_ENUM(NSInteger, KPSDImageFormat) {
    SDImageFormatUndefined = -1,
    SDImageFormatJPEG = 0,
    SDImageFormatPNG,
    SDImageFormatGIF,
    SDImageFormatTIFF,
    SDImageFormatWebP,
    SDImageFormatHEIC
};

@interface NSData (KPImageContentType)

/**
 *  Return image format
 *
 *  @param data the input image data
 *
 *  @return the image format as `SDImageFormat` (enum)
 */
+ (KPSDImageFormat)kpsd_imageFormatForImageData:(nullable NSData *)data;

/**
 Convert SDImageFormat to UTType

 @param format Format as SDImageFormat
 @return The UTType as CFStringRef
 */
+ (nonnull CFStringRef)kpsd_UTTypeFromSDImageFormat:(KPSDImageFormat)format;

@end
