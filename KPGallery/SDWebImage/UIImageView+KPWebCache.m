/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+KPWebCache.h"

#if KPSD_UIKIT || KPSD_MAC

#import "objc/runtime.h"
#import "UIView+KPWebCacheOperation.h"
#import "UIView+KPWebCache.h"

@implementation UIImageView (KPWebCache)

- (void)kpsd_setImageWithURL:(nullable NSURL *)url {
    [self kpsd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)kpsd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder {
    [self kpsd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)kpsd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(KPSDWebImageOptions)options {
    [self kpsd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)kpsd_setImageWithURL:(nullable NSURL *)url completed:(nullable KPSDExternalCompletionBlock)completedBlock {
    [self kpsd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)kpsd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable KPSDExternalCompletionBlock)completedBlock {
    [self kpsd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)kpsd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(KPSDWebImageOptions)options completed:(nullable KPSDExternalCompletionBlock)completedBlock {
    [self kpsd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)kpsd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(KPSDWebImageOptions)options
                  progress:(nullable KPSDWebImageDownloaderProgressBlock)progressBlock
                 completed:(nullable KPSDExternalCompletionBlock)completedBlock {
    [self kpsd_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                        operationKey:nil
                       setImageBlock:nil
                            progress:progressBlock
                           completed:completedBlock];
}

- (void)kpsd_setImageWithPreviousCachedImageWithURL:(nullable NSURL *)url
                                 placeholderImage:(nullable UIImage *)placeholder
                                          options:(KPSDWebImageOptions)options
                                         progress:(nullable KPSDWebImageDownloaderProgressBlock)progressBlock
                                        completed:(nullable KPSDExternalCompletionBlock)completedBlock {
    NSString *key = [[KPSDWebImageManager sharedManager] cacheKeyForURL:url];
    UIImage *lastPreviousCachedImage = [[KPSDImageCache sharedImageCache] imageFromCacheForKey:key];
    
    [self kpsd_setImageWithURL:url placeholderImage:lastPreviousCachedImage ?: placeholder options:options progress:progressBlock completed:completedBlock];    
}

#if KPSD_UIKIT

#pragma mark - Animation of multiple images

- (void)kpsd_setAnimationImagesWithURLs:(nonnull NSArray<NSURL *> *)arrayOfURLs {
    [self kpsd_cancelCurrentAnimationImagesLoad];
    NSPointerArray *operationsArray = [self kpsd_animationOperationArray];
    
    [arrayOfURLs enumerateObjectsUsingBlock:^(NSURL *logoImageURL, NSUInteger idx, BOOL * _Nonnull stop) {
        __weak __typeof(self) wself = self;
        id <KPSDWebImageOperation> operation = [[KPSDWebImageManager sharedManager] loadImageWithURL:logoImageURL options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, KPSDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            __strong typeof(wself) sself = wself;
            if (!sself) return;
            dispatch_main_async_safe(^{
                [sself stopAnimating];
                if (sself && image) {
                    NSMutableArray<UIImage *> *currentImages = [[sself animationImages] mutableCopy];
                    if (!currentImages) {
                        currentImages = [[NSMutableArray alloc] init];
                    }
                    
                    // We know what index objects should be at when they are returned so
                    // we will put the object at the index, filling any empty indexes
                    // with the image that was returned too "early". These images will
                    // be overwritten. (does not require additional sorting datastructure)
                    while ([currentImages count] < idx) {
                        [currentImages addObject:image];
                    }
                    
                    currentImages[idx] = image;

                    sself.animationImages = currentImages;
                    [sself setNeedsLayout];
                }
                [sself startAnimating];
            });
        }];
        @synchronized (self) {
            [operationsArray addPointer:(__bridge void *)(operation)];
        }
    }];
}

static char animationLoadOperationKey;

// element is weak because operation instance is retained by SDWebImageManager's runningOperations property
// we should use lock to keep thread-safe because these method may not be acessed from main queue
- (NSPointerArray *)kpsd_animationOperationArray {
    @synchronized(self) {
        NSPointerArray *operationsArray = objc_getAssociatedObject(self, &animationLoadOperationKey);
        if (operationsArray) {
            return operationsArray;
        }
        operationsArray = [NSPointerArray weakObjectsPointerArray];
        objc_setAssociatedObject(self, &animationLoadOperationKey, operationsArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return operationsArray;
    }
}

- (void)kpsd_cancelCurrentAnimationImagesLoad {
    NSPointerArray *operationsArray = [self kpsd_animationOperationArray];
    if (operationsArray) {
        @synchronized (self) {
            for (id operation in operationsArray) {
                if ([operation conformsToProtocol:@protocol(KPSDWebImageOperation)]) {
                    [operation cancel];
                }
            }
            operationsArray.count = 0;
        }
    }
}
#endif

@end

#endif
