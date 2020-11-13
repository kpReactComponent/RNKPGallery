/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIView+KPWebCache.h"

#if KPSD_UIKIT || KPSD_MAC

#import "objc/runtime.h"
#import "UIView+KPWebCacheOperation.h"

NSString * const KPSDWebImageInternalSetImageGroupKey = @"internalSetImageGroup";
NSString * const KPSDWebImageExternalCustomManagerKey = @"externalCustomManager";

const int64_t KPSDWebImageProgressUnitCountUnknown = 1LL;

static char imageURLKey;

#if KPSD_UIKIT
static char TAG_ACTIVITY_INDICATOR;
static char TAG_ACTIVITY_STYLE;
#endif
static char TAG_ACTIVITY_SHOW;

@implementation UIView (KPWebCache)

- (nullable NSURL *)kpsd_imageURL {
    return objc_getAssociatedObject(self, &imageURLKey);
}

- (NSProgress *)kpsd_imageProgress {
    NSProgress *progress = objc_getAssociatedObject(self, @selector(kpsd_imageProgress));
    if (!progress) {
        progress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
        self.kpsd_imageProgress = progress;
    }
    return progress;
}

- (void)setSd_imageProgress:(NSProgress *)kpsd_imageProgress {
    objc_setAssociatedObject(self, @selector(kpsd_imageProgress), kpsd_imageProgress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)kpsd_internalSetImageWithURL:(nullable NSURL *)url
                  placeholderImage:(nullable UIImage *)placeholder
                           options:(KPSDWebImageOptions)options
                      operationKey:(nullable NSString *)operationKey
                     setImageBlock:(nullable SDSetImageBlock)setImageBlock
                          progress:(nullable KPSDWebImageDownloaderProgressBlock)progressBlock
                         completed:(nullable KPSDExternalCompletionBlock)completedBlock {
    return [self kpsd_internalSetImageWithURL:url placeholderImage:placeholder options:options operationKey:operationKey setImageBlock:setImageBlock progress:progressBlock completed:completedBlock context:nil];
}

- (void)kpsd_internalSetImageWithURL:(nullable NSURL *)url
                  placeholderImage:(nullable UIImage *)placeholder
                           options:(KPSDWebImageOptions)options
                      operationKey:(nullable NSString *)operationKey
                     setImageBlock:(nullable SDSetImageBlock)setImageBlock
                          progress:(nullable KPSDWebImageDownloaderProgressBlock)progressBlock
                         completed:(nullable KPSDExternalCompletionBlock)completedBlock
                           context:(nullable NSDictionary<NSString *, id> *)context {
    NSString *validOperationKey = operationKey ?: NSStringFromClass([self class]);
    [self kpsd_cancelImageLoadOperationWithKey:validOperationKey];
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!(options & SDWebImageDelayPlaceholder)) {
        if ([context valueForKey:KPSDWebImageInternalSetImageGroupKey]) {
            dispatch_group_t group = [context valueForKey:KPSDWebImageInternalSetImageGroupKey];
            dispatch_group_enter(group);
        }
        dispatch_main_async_safe(^{
            [self kpsd_setImage:placeholder imageData:nil basedOnClassOrViaCustomSetImageBlock:setImageBlock];
        });
    }
    
    if (url) {
        // check if activityView is enabled or not
        if ([self kpsd_showActivityIndicatorView]) {
            [self kpsd_addActivityIndicator];
        }
        
        // reset the progress
        self.kpsd_imageProgress.totalUnitCount = 0;
        self.kpsd_imageProgress.completedUnitCount = 0;
        
        KPSDWebImageManager *manager;
        if ([context valueForKey:KPSDWebImageExternalCustomManagerKey]) {
            manager = (KPSDWebImageManager *)[context valueForKey:KPSDWebImageExternalCustomManagerKey];
        } else {
            manager = [KPSDWebImageManager sharedManager];
        }
        
        __weak __typeof(self)wself = self;
        KPSDWebImageDownloaderProgressBlock combinedProgressBlock = ^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            wself.kpsd_imageProgress.totalUnitCount = expectedSize;
            wself.kpsd_imageProgress.completedUnitCount = receivedSize;
            if (progressBlock) {
                progressBlock(receivedSize, expectedSize, targetURL);
            }
        };
        id <KPSDWebImageOperation> operation = [manager loadImageWithURL:url options:options progress:combinedProgressBlock completed:^(UIImage *image, NSData *data, NSError *error, KPSDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            __strong __typeof (wself) sself = wself;
            if (!sself) { return; }
            [sself kpsd_removeActivityIndicator];
            // if the progress not been updated, mark it to complete state
            if (finished && !error && sself.kpsd_imageProgress.totalUnitCount == 0 && sself.kpsd_imageProgress.completedUnitCount == 0) {
                sself.kpsd_imageProgress.totalUnitCount = KPSDWebImageProgressUnitCountUnknown;
                sself.kpsd_imageProgress.completedUnitCount = KPSDWebImageProgressUnitCountUnknown;
            }
            BOOL shouldCallCompletedBlock = finished || (options & SDWebImageAvoidAutoSetImage);
            BOOL shouldNotSetImage = ((image && (options & SDWebImageAvoidAutoSetImage)) ||
                                      (!image && !(options & SDWebImageDelayPlaceholder)));
            KPSDWebImageNoParamsBlock callCompletedBlockClojure = ^{
                if (!sself) { return; }
                if (!shouldNotSetImage) {
                    [sself kpsd_setNeedsLayout];
                }
                if (completedBlock && shouldCallCompletedBlock) {
                    completedBlock(image, error, cacheType, url);
                }
            };
            
            // case 1a: we got an image, but the SDWebImageAvoidAutoSetImage flag is set
            // OR
            // case 1b: we got no image and the SDWebImageDelayPlaceholder is not set
            if (shouldNotSetImage) {
                dispatch_main_async_safe(callCompletedBlockClojure);
                return;
            }
            
            UIImage *targetImage = nil;
            NSData *targetData = nil;
            if (image) {
                // case 2a: we got an image and the SDWebImageAvoidAutoSetImage is not set
                targetImage = image;
                targetData = data;
            } else if (options & SDWebImageDelayPlaceholder) {
                // case 2b: we got no image and the SDWebImageDelayPlaceholder flag is set
                targetImage = placeholder;
                targetData = nil;
            }
            
            // check whether we should use the image transition
            KPSDWebImageTransition *transition = nil;
            if (finished && (options & SDWebImageForceTransition || cacheType == SDImageCacheTypeNone)) {
                transition = sself.kpsd_imageTransition;
            }
            if ([context valueForKey:KPSDWebImageInternalSetImageGroupKey]) {
                dispatch_group_t group = [context valueForKey:KPSDWebImageInternalSetImageGroupKey];
                dispatch_group_enter(group);
                dispatch_main_async_safe(^{
                    [sself kpsd_setImage:targetImage imageData:targetData basedOnClassOrViaCustomSetImageBlock:setImageBlock transition:transition cacheType:cacheType imageURL:imageURL];
                });
                // ensure completion block is called after custom setImage process finish
                dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                    callCompletedBlockClojure();
                });
            } else {
                dispatch_main_async_safe(^{
                    [sself kpsd_setImage:targetImage imageData:targetData basedOnClassOrViaCustomSetImageBlock:setImageBlock transition:transition cacheType:cacheType imageURL:imageURL];
                    callCompletedBlockClojure();
                });
            }
        }];
        [self kpsd_setImageLoadOperation:operation forKey:validOperationKey];
    } else {
        dispatch_main_async_safe(^{
            [self kpsd_removeActivityIndicator];
            if (completedBlock) {
                NSError *error = [NSError errorWithDomain:KPSDWebImageErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
                completedBlock(nil, error, SDImageCacheTypeNone, url);
            }
        });
    }
}

- (void)kpsd_cancelCurrentImageLoad {
    [self kpsd_cancelImageLoadOperationWithKey:NSStringFromClass([self class])];
}

- (void)kpsd_setImage:(UIImage *)image imageData:(NSData *)imageData basedOnClassOrViaCustomSetImageBlock:(SDSetImageBlock)setImageBlock {
    [self kpsd_setImage:image imageData:imageData basedOnClassOrViaCustomSetImageBlock:setImageBlock transition:nil cacheType:0 imageURL:nil];
}

- (void)kpsd_setImage:(UIImage *)image imageData:(NSData *)imageData basedOnClassOrViaCustomSetImageBlock:(SDSetImageBlock)setImageBlock transition:(KPSDWebImageTransition *)transition cacheType:(KPSDImageCacheType)cacheType imageURL:(NSURL *)imageURL {
    UIView *view = self;
    SDSetImageBlock finalSetImageBlock;
    if (setImageBlock) {
        finalSetImageBlock = setImageBlock;
    }
#if KPSD_UIKIT || KPSD_MAC
    else if ([view isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)view;
        finalSetImageBlock = ^(UIImage *setImage, NSData *setImageData) {
            imageView.image = setImage;
        };
    }
#endif
#if KPSD_UIKIT
    else if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        finalSetImageBlock = ^(UIImage *setImage, NSData *setImageData){
            [button setImage:setImage forState:UIControlStateNormal];
        };
    }
#endif
    
    if (transition) {
#if KPSD_UIKIT
        [UIView transitionWithView:view duration:0 options:0 animations:^{
            // 0 duration to let UIKit render placeholder and prepares block
            if (transition.prepares) {
                transition.prepares(view, image, imageData, cacheType, imageURL);
            }
        } completion:^(BOOL finished) {
            [UIView transitionWithView:view duration:transition.duration options:transition.animationOptions animations:^{
                if (finalSetImageBlock && !transition.avoidAutoSetImage) {
                    finalSetImageBlock(image, imageData);
                }
                if (transition.animations) {
                    transition.animations(view, image);
                }
            } completion:transition.completion];
        }];
#elif KPSD_MAC
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull prepareContext) {
            // 0 duration to let AppKit render placeholder and prepares block
            prepareContext.duration = 0;
            if (transition.prepares) {
                transition.prepares(view, image, imageData, cacheType, imageURL);
            }
        } completionHandler:^{
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
                context.duration = transition.duration;
                context.timingFunction = transition.timingFunction;
                context.allowsImplicitAnimation = (transition.animationOptions & SDWebImageAnimationOptionAllowsImplicitAnimation);
                if (finalSetImageBlock && !transition.avoidAutoSetImage) {
                    finalSetImageBlock(image, imageData);
                }
                if (transition.animations) {
                    transition.animations(view, image);
                }
            } completionHandler:^{
                if (transition.completion) {
                    transition.completion(YES);
                }
            }];
        }];
#endif
    } else {
        if (finalSetImageBlock) {
            finalSetImageBlock(image, imageData);
        }
    }
}

- (void)kpsd_setNeedsLayout {
#if KPSD_UIKIT
    [self setNeedsLayout];
#elif KPSD_MAC
    [self setNeedsLayout:YES];
#endif
}

#pragma mark - Image Transition
- (KPSDWebImageTransition *)kpsd_imageTransition {
    return objc_getAssociatedObject(self, @selector(kpsd_imageTransition));
}

- (void)setSd_imageTransition:(KPSDWebImageTransition *)kpsd_imageTransition {
    objc_setAssociatedObject(self, @selector(kpsd_imageTransition), kpsd_imageTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Activity indicator

#pragma mark -
#if KPSD_UIKIT
- (UIActivityIndicatorView *)activityIndicator {
    return (UIActivityIndicatorView *)objc_getAssociatedObject(self, &TAG_ACTIVITY_INDICATOR);
}

- (void)setActivityIndicator:(UIActivityIndicatorView *)activityIndicator {
    objc_setAssociatedObject(self, &TAG_ACTIVITY_INDICATOR, activityIndicator, OBJC_ASSOCIATION_RETAIN);
}
#endif

- (void)kpsd_setShowActivityIndicatorView:(BOOL)show {
    objc_setAssociatedObject(self, &TAG_ACTIVITY_SHOW, @(show), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)kpsd_showActivityIndicatorView {
    return [objc_getAssociatedObject(self, &TAG_ACTIVITY_SHOW) boolValue];
}

#if KPSD_UIKIT
- (void)kpsd_setIndicatorStyle:(UIActivityIndicatorViewStyle)style{
    objc_setAssociatedObject(self, &TAG_ACTIVITY_STYLE, [NSNumber numberWithInt:style], OBJC_ASSOCIATION_RETAIN);
}

- (int)kpsd_getIndicatorStyle{
    return [objc_getAssociatedObject(self, &TAG_ACTIVITY_STYLE) intValue];
}
#endif

- (void)kpsd_addActivityIndicator {
#if KPSD_UIKIT
    dispatch_main_async_safe(^{
        if (!self.activityIndicator) {
            self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:[self kpsd_getIndicatorStyle]];
            self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        
            [self addSubview:self.activityIndicator];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1.0
                                                              constant:0.0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:0.0]];
        }
        [self.activityIndicator startAnimating];
    });
#endif
}

- (void)kpsd_removeActivityIndicator {
#if KPSD_UIKIT
    dispatch_main_async_safe(^{
        if (self.activityIndicator) {
            [self.activityIndicator removeFromSuperview];
            self.activityIndicator = nil;
        }
    });
#endif
}

@end

#endif
