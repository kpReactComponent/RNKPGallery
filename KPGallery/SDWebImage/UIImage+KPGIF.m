/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Laurin Brandner
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImage+KPGIF.h"
#import "KPSDWebImageGIFCoder.h"
#import "NSImage+KPWebCache.h"

@implementation UIImage (KPGIF)

+ (UIImage *)kpsd_animatedGIFWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    return [[KPSDWebImageGIFCoder sharedCoder] decodedImageWithData:data];
}

- (BOOL)isGIF {
    return (self.images != nil);
}

@end
