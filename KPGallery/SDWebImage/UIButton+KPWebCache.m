/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIButton+KPWebCache.h"

#if KPSD_UIKIT

#import "objc/runtime.h"
#import "UIView+KPWebCacheOperation.h"
#import "UIView+KPWebCache.h"

static char imageURLStorageKey;

typedef NSMutableDictionary<NSString *, NSURL *> SDStateImageURLDictionary;

static inline NSString * imageURLKeyForState(UIControlState state) {
    return [NSString stringWithFormat:@"image_%lu", (unsigned long)state];
}

static inline NSString * backgroundImageURLKeyForState(UIControlState state) {
    return [NSString stringWithFormat:@"backgroundImage_%lu", (unsigned long)state];
}

static inline NSString * imageOperationKeyForState(UIControlState state) {
    return [NSString stringWithFormat:@"UIButtonImageOperation%lu", (unsigned long)state];
}

static inline NSString * backgroundImageOperationKeyForState(UIControlState state) {
    return [NSString stringWithFormat:@"UIButtonBackgroundImageOperation%lu", (unsigned long)state];
}

@implementation UIButton (KPWebCache)

#pragma mark - Image

- (nullable NSURL *)kpsd_currentImageURL {
    NSURL *url = self.kpsd_imageURLStorage[imageURLKeyForState(self.state)];

    if (!url) {
        url = self.kpsd_imageURLStorage[imageURLKeyForState(UIControlStateNormal)];
    }

    return url;
}

- (nullable NSURL *)kpsd_imageURLForState:(UIControlState)state {
    return self.kpsd_imageURLStorage[imageURLKeyForState(state)];
}

- (void)kpsd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state {
    [self kpsd_setImageWithURL:url forState:state placeholderImage:nil options:0 completed:nil];
}

- (void)kpsd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder {
    [self kpsd_setImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:nil];
}

- (void)kpsd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(KPSDWebImageOptions)options {
    [self kpsd_setImageWithURL:url forState:state placeholderImage:placeholder options:options completed:nil];
}

- (void)kpsd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state completed:(nullable KPSDExternalCompletionBlock)completedBlock {
    [self kpsd_setImageWithURL:url forState:state placeholderImage:nil options:0 completed:completedBlock];
}

- (void)kpsd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder completed:(nullable KPSDExternalCompletionBlock)completedBlock {
    [self kpsd_setImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:completedBlock];
}

- (void)kpsd_setImageWithURL:(nullable NSURL *)url
                  forState:(UIControlState)state
          placeholderImage:(nullable UIImage *)placeholder
                   options:(KPSDWebImageOptions)options
                 completed:(nullable KPSDExternalCompletionBlock)completedBlock {
    if (!url) {
        [self.kpsd_imageURLStorage removeObjectForKey:imageURLKeyForState(state)];
    } else {
        self.kpsd_imageURLStorage[imageURLKeyForState(state)] = url;
    }
    
    __weak typeof(self)weakSelf = self;
    [self kpsd_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                        operationKey:imageOperationKeyForState(state)
                       setImageBlock:^(UIImage *image, NSData *imageData) {
                           [weakSelf setImage:image forState:state];
                       }
                            progress:nil
                           completed:completedBlock];
}

#pragma mark - Background Image

- (nullable NSURL *)kpsd_currentBackgroundImageURL {
    NSURL *url = self.kpsd_imageURLStorage[backgroundImageURLKeyForState(self.state)];
    
    if (!url) {
        url = self.kpsd_imageURLStorage[backgroundImageURLKeyForState(UIControlStateNormal)];
    }
    
    return url;
}

- (nullable NSURL *)kpsd_backgroundImageURLForState:(UIControlState)state {
    return self.kpsd_imageURLStorage[backgroundImageURLKeyForState(state)];
}

- (void)kpsd_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state {
    [self kpsd_setBackgroundImageWithURL:url forState:state placeholderImage:nil options:0 completed:nil];
}

- (void)kpsd_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder {
    [self kpsd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:nil];
}

- (void)kpsd_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(KPSDWebImageOptions)options {
    [self kpsd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options completed:nil];
}

- (void)kpsd_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state completed:(nullable KPSDExternalCompletionBlock)completedBlock {
    [self kpsd_setBackgroundImageWithURL:url forState:state placeholderImage:nil options:0 completed:completedBlock];
}

- (void)kpsd_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder completed:(nullable KPSDExternalCompletionBlock)completedBlock {
    [self kpsd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:completedBlock];
}

- (void)kpsd_setBackgroundImageWithURL:(nullable NSURL *)url
                            forState:(UIControlState)state
                    placeholderImage:(nullable UIImage *)placeholder
                             options:(KPSDWebImageOptions)options
                           completed:(nullable KPSDExternalCompletionBlock)completedBlock {
    if (!url) {
        [self.kpsd_imageURLStorage removeObjectForKey:backgroundImageURLKeyForState(state)];
    } else {
        self.kpsd_imageURLStorage[backgroundImageURLKeyForState(state)] = url;
    }
    
    __weak typeof(self)weakSelf = self;
    [self kpsd_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                        operationKey:backgroundImageOperationKeyForState(state)
                       setImageBlock:^(UIImage *image, NSData *imageData) {
                           [weakSelf setBackgroundImage:image forState:state];
                       }
                            progress:nil
                           completed:completedBlock];
}

#pragma mark - Cancel

- (void)kpsd_cancelImageLoadForState:(UIControlState)state {
    [self kpsd_cancelImageLoadOperationWithKey:imageOperationKeyForState(state)];
}

- (void)kpsd_cancelBackgroundImageLoadForState:(UIControlState)state {
    [self kpsd_cancelImageLoadOperationWithKey:backgroundImageOperationKeyForState(state)];
}

#pragma mark - Private

- (SDStateImageURLDictionary *)kpsd_imageURLStorage {
    SDStateImageURLDictionary *storage = objc_getAssociatedObject(self, &imageURLStorageKey);
    if (!storage) {
        storage = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &imageURLStorageKey, storage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return storage;
}

@end

#endif
