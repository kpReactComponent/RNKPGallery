//
//  YBIBWebImageManager.m
//  YBImageBrowserDemo
//
//  Created by 杨波 on 2018/8/29.
//  Copyright © 2018年 杨波. All rights reserved.
//

#import "YBIBWebImageManager.h"
#import "KPSDWebImageManager.h"

static BOOL _downloaderShouldDecompressImages;
static BOOL _cacheShouldDecompressImages;

@implementation YBIBWebImageManager

#pragma mark public

+ (void)storeOutsideConfiguration {
    _downloaderShouldDecompressImages = [KPSDWebImageDownloader sharedDownloader].shouldDecompressImages;
    _cacheShouldDecompressImages = [KPSDImageCache sharedImageCache].config.shouldDecompressImages;
    [KPSDWebImageDownloader sharedDownloader].shouldDecompressImages = NO;
    [KPSDImageCache sharedImageCache].config.shouldDecompressImages = NO;
}

+ (void)restoreOutsideConfiguration {
    [KPSDWebImageDownloader sharedDownloader].shouldDecompressImages = _downloaderShouldDecompressImages;
    [KPSDImageCache sharedImageCache].config.shouldDecompressImages = _cacheShouldDecompressImages;
}

+ (id)downloadImageWithURL:(NSURL *)url progress:(YBIBWebImageManagerProgressBlock)progress success:(YBIBWebImageManagerSuccessBlock)success failed:(YBIBWebImageManagerFailedBlock)failed {
    if (!url) return nil;
    KPSDWebImageDownloadToken *token = [[KPSDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:SDWebImageDownloaderLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        if (progress) {
            progress(receivedSize, expectedSize, targetURL);
        }
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        if (error) {
            if (failed) failed(error, finished);
            return;
        }
        if (success) {
            success(image, data, finished);
        }
    }];
    return token;
}

+ (void)cancelTaskWithDownloadToken:(id)token {
    if (token && [token isKindOfClass:KPSDWebImageDownloadToken.class]) {
        [((KPSDWebImageDownloadToken *)token) cancel];
    }
}

+ (void)storeImage:(UIImage *)image imageData:(NSData *)data forKey:(NSURL *)key toDisk:(BOOL)toDisk {
    if (!key) return;
    NSString *cacheKey = [KPSDWebImageManager.sharedManager cacheKeyForURL:key];
    if (!cacheKey) return;
    
    [[KPSDImageCache sharedImageCache] storeImage:image imageData:data forKey:cacheKey toDisk:toDisk completion:nil];
}

+ (void)queryCacheOperationForKey:(NSURL *)key completed:(YBIBWebImageManagerCacheQueryCompletedBlock)completed {
#define QUERY_CACHE_FAILED if (completed) {completed(nil, nil); return;}
    if (!key) QUERY_CACHE_FAILED
    NSString *cacheKey = [KPSDWebImageManager.sharedManager cacheKeyForURL:key];
    if (!cacheKey) QUERY_CACHE_FAILED
#undef QUERY_CACHE_FAILED
        
    KPSDImageCacheOptions options = SDImageCacheQueryDataWhenInMemory;
    [[KPSDImageCache sharedImageCache] queryCacheOperationForKey:cacheKey options:options done:^(UIImage * _Nullable image, NSData * _Nullable data, KPSDImageCacheType cacheType) {
        if (completed) {
            completed(image, data);
        }
    }];
}

@end
