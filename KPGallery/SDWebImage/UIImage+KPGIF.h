/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Laurin Brandner
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "KPSDWebImageCompat.h"

@interface UIImage (KPGIF)

/**
 *  Creates an animated UIImage from an NSData.
 *  For static GIF, will create an UIImage with `images` array set to nil. For animated GIF, will create an UIImage with valid `images` array.
 */
+ (UIImage *)kpsd_animatedGIFWithData:(NSData *)data;

/**
 *  Checks if an UIImage instance is a GIF. Will use the `images` array.
 */
- (BOOL)isGIF;

@end
