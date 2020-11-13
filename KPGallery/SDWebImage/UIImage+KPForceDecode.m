/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImage+KPForceDecode.h"
#import "KPSDWebImageCodersManager.h"

@implementation UIImage (KPForceDecode)

+ (UIImage *)decodedImageWithImage:(UIImage *)image {
    if (!image) {
        return nil;
    }
    NSData *tempData;
    return [[KPSDWebImageCodersManager sharedInstance] decompressedImageWithImage:image data:&tempData options:@{KPSDWebImageCoderScaleDownLargeImagesKey: @(NO)}];
}

+ (UIImage *)decodedAndScaledDownImageWithImage:(UIImage *)image {
    if (!image) {
        return nil;
    }
    NSData *tempData;
    return [[KPSDWebImageCodersManager sharedInstance] decompressedImageWithImage:image data:&tempData options:@{KPSDWebImageCoderScaleDownLargeImagesKey: @(YES)}];
}

@end
