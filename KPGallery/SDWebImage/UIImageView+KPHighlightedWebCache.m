/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+KPHighlightedWebCache.h"

#if KPSD_UIKIT

#import "UIView+KPWebCacheOperation.h"
#import "UIView+KPWebCache.h"

@implementation UIImageView (KPHighlightedWebCache)

- (void)kpsd_setHighlightedImageWithURL:(nullable NSURL *)url {
    [self kpsd_setHighlightedImageWithURL:url options:0 progress:nil completed:nil];
}

- (void)kpsd_setHighlightedImageWithURL:(nullable NSURL *)url options:(KPSDWebImageOptions)options {
    [self kpsd_setHighlightedImageWithURL:url options:options progress:nil completed:nil];
}

- (void)kpsd_setHighlightedImageWithURL:(nullable NSURL *)url completed:(nullable KPSDExternalCompletionBlock)completedBlock {
    [self kpsd_setHighlightedImageWithURL:url options:0 progress:nil completed:completedBlock];
}

- (void)kpsd_setHighlightedImageWithURL:(nullable NSURL *)url options:(KPSDWebImageOptions)options completed:(nullable KPSDExternalCompletionBlock)completedBlock {
    [self kpsd_setHighlightedImageWithURL:url options:options progress:nil completed:completedBlock];
}

- (void)kpsd_setHighlightedImageWithURL:(nullable NSURL *)url
                              options:(KPSDWebImageOptions)options
                             progress:(nullable KPSDWebImageDownloaderProgressBlock)progressBlock
                            completed:(nullable KPSDExternalCompletionBlock)completedBlock {
    __weak typeof(self)weakSelf = self;
    [self kpsd_internalSetImageWithURL:url
                    placeholderImage:nil
                             options:options
                        operationKey:@"UIImageViewImageOperationHighlighted"
                       setImageBlock:^(UIImage *image, NSData *imageData) {
                           weakSelf.highlightedImage = image;
                       }
                            progress:progressBlock
                           completed:completedBlock];
}

@end

#endif
