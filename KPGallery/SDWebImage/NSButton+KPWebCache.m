/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "NSButton+KPWebCache.h"

#if KPSD_MAC

#import "objc/runtime.h"
#import "UIView+WebCacheOperation.h"
#import "UIView+WebCache.h"

static inline NSString * imageOperationKey() {
    return @"NSButtonImageOperation";
}

static inline NSString * alternateImageOperationKey() {
    return @"NSButtonAlternateImageOperation";
}

@implementation NSButton (KPWebCache)

#pragma mark - Image

- (void)kpsd_setImageWithURL:(nullable NSURL *)url {
    [self kpsd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)kpsd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder {
    [self kpsd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)kpsd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SDWebImageOptions)options {
    [self kpsd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)kpsd_setImageWithURL:(nullable NSURL *)url completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self kpsd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)kpsd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self kpsd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)kpsd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SDWebImageOptions)options completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self kpsd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)kpsd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(SDWebImageOptions)options
                  progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
                 completed:(nullable SDExternalCompletionBlock)completedBlock {
    self.kpsd_currentImageURL = url;
    
    __weak typeof(self)weakSelf = self;
    [self kpsd_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                        operationKey:imageOperationKey()
                       setImageBlock:^(NSImage * _Nullable image, NSData * _Nullable imageData) {
                           weakSelf.image = image;
                       }
                            progress:progressBlock
                           completed:completedBlock];
}

#pragma mark - Alternate Image

- (void)kpsd_setAlternateImageWithURL:(nullable NSURL *)url {
    [self kpsd_setAlternateImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)kpsd_setAlternateImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder {
    [self kpsd_setAlternateImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)kpsd_setAlternateImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SDWebImageOptions)options {
    [self kpsd_setAlternateImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)kpsd_setAlternateImageWithURL:(nullable NSURL *)url completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self kpsd_setAlternateImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)kpsd_setAlternateImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self kpsd_setAlternateImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)kpsd_setAlternateImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SDWebImageOptions)options completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self kpsd_setAlternateImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)kpsd_setAlternateImageWithURL:(nullable NSURL *)url
                   placeholderImage:(nullable UIImage *)placeholder
                            options:(SDWebImageOptions)options
                           progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
                          completed:(nullable SDExternalCompletionBlock)completedBlock {
    self.kpsd_currentAlternateImageURL = url;
    
    __weak typeof(self)weakSelf = self;
    [self kpsd_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                        operationKey:alternateImageOperationKey()
                       setImageBlock:^(NSImage * _Nullable image, NSData * _Nullable imageData) {
                           weakSelf.alternateImage = image;
                       }
                            progress:progressBlock
                           completed:completedBlock];
}

#pragma mark - Cancel

- (void)kpsd_cancelCurrentImageLoad {
    [self kpsd_cancelImageLoadOperationWithKey:imageOperationKey()];
}

- (void)kpsd_cancelCurrentAlternateImageLoad {
    [self kpsd_cancelImageLoadOperationWithKey:alternateImageOperationKey()];
}

#pragma mar - Private

- (NSURL *)kpsd_currentImageURL {
    return objc_getAssociatedObject(self, @selector(kpsd_currentImageURL));
}

- (void)setSd_currentImageURL:(NSURL *)kpsd_currentImageURL {
    objc_setAssociatedObject(self, @selector(kpsd_currentImageURL), kpsd_currentImageURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURL *)kpsd_currentAlternateImageURL {
    return objc_getAssociatedObject(self, @selector(kpsd_currentAlternateImageURL));
}

- (void)setSd_currentAlternateImageURL:(NSURL *)kpsd_currentAlternateImageURL {
    objc_setAssociatedObject(self, @selector(kpsd_currentAlternateImageURL), kpsd_currentAlternateImageURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#endif
