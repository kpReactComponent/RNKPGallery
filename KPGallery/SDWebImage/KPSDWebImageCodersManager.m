/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "KPSDWebImageCodersManager.h"
#import "KPSDWebImageImageIOCoder.h"
#import "KPSDWebImageGIFCoder.h"
#ifdef KPSD_WEBP
#import "KPSDWebImageWebPCoder.h"
#endif

@interface KPSDWebImageCodersManager ()

@property (strong, nonatomic, nonnull) NSMutableArray<KPSDWebImageCoder>* mutableCoders;
@property (strong, nonatomic, nullable) dispatch_queue_t mutableCodersAccessQueue;

@end

@implementation KPSDWebImageCodersManager

+ (nonnull instancetype)sharedInstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        // initialize with default coders
        _mutableCoders = [@[[KPSDWebImageImageIOCoder sharedCoder]] mutableCopy];
#ifdef KPSD_WEBP
        [_mutableCoders addObject:[SDWebImageWebPCoder sharedCoder]];
#endif
        _mutableCodersAccessQueue = dispatch_queue_create("com.hackemist.SDWebImageCodersManager", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

#pragma mark - Coder IO operations

- (void)addCoder:(nonnull id<KPSDWebImageCoder>)coder {
    if ([coder conformsToProtocol:@protocol(KPSDWebImageCoder)]) {
        dispatch_barrier_sync(self.mutableCodersAccessQueue, ^{
            [self.mutableCoders addObject:coder];
        });
    }
}

- (void)removeCoder:(nonnull id<KPSDWebImageCoder>)coder {
    dispatch_barrier_sync(self.mutableCodersAccessQueue, ^{
        [self.mutableCoders removeObject:coder];
    });
}

- (NSArray<KPSDWebImageCoder> *)coders {
    __block NSArray<KPSDWebImageCoder> *sortedCoders = nil;
    dispatch_sync(self.mutableCodersAccessQueue, ^{
        sortedCoders = (NSArray<KPSDWebImageCoder> *)[[[self.mutableCoders copy] reverseObjectEnumerator] allObjects];
    });
    return sortedCoders;
}

- (void)setCoders:(NSArray<KPSDWebImageCoder> *)coders {
    dispatch_barrier_sync(self.mutableCodersAccessQueue, ^{
        self.mutableCoders = [coders mutableCopy];
    });
}

#pragma mark - SDWebImageCoder
- (BOOL)canDecodeFromData:(NSData *)data {
    for (id<KPSDWebImageCoder> coder in self.coders) {
        if ([coder canDecodeFromData:data]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)canEncodeToFormat:(KPSDImageFormat)format {
    for (id<KPSDWebImageCoder> coder in self.coders) {
        if ([coder canEncodeToFormat:format]) {
            return YES;
        }
    }
    return NO;
}

- (UIImage *)decodedImageWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    for (id<KPSDWebImageCoder> coder in self.coders) {
        if ([coder canDecodeFromData:data]) {
            return [coder decodedImageWithData:data];
        }
    }
    return nil;
}

- (UIImage *)decompressedImageWithImage:(UIImage *)image
                                   data:(NSData *__autoreleasing  _Nullable *)data
                                options:(nullable NSDictionary<NSString*, NSObject*>*)optionsDict {
    if (!image) {
        return nil;
    }
    for (id<KPSDWebImageCoder> coder in self.coders) {
        if ([coder canDecodeFromData:*data]) {
            return [coder decompressedImageWithImage:image data:data options:optionsDict];
        }
    }
    return nil;
}

- (NSData *)encodedDataWithImage:(UIImage *)image format:(KPSDImageFormat)format {
    if (!image) {
        return nil;
    }
    for (id<KPSDWebImageCoder> coder in self.coders) {
        if ([coder canEncodeToFormat:format]) {
            return [coder encodedDataWithImage:image format:format];
        }
    }
    return nil;
}

@end
