/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIView+KPWebCacheOperation.h"

#if KPSD_UIKIT || KPSD_MAC

#import "objc/runtime.h"

static char loadOperationKey;

// key is copy, value is weak because operation instance is retained by SDWebImageManager's runningOperations property
// we should use lock to keep thread-safe because these method may not be acessed from main queue
typedef NSMapTable<NSString *, id<KPSDWebImageOperation>> KPSDOperationsDictionary;

@implementation UIView (KPWebCacheOperation)

- (KPSDOperationsDictionary *)kpsd_operationDictionary {
    @synchronized(self) {
        KPSDOperationsDictionary *operations = objc_getAssociatedObject(self, &loadOperationKey);
        if (operations) {
            return operations;
        }
        operations = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
        objc_setAssociatedObject(self, &loadOperationKey, operations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return operations;
    }
}

- (void)kpsd_setImageLoadOperation:(nullable id<KPSDWebImageOperation>)operation forKey:(nullable NSString *)key {
    if (key) {
        [self kpsd_cancelImageLoadOperationWithKey:key];
        if (operation) {
            KPSDOperationsDictionary *operationDictionary = [self kpsd_operationDictionary];
            @synchronized (self) {
                [operationDictionary setObject:operation forKey:key];
            }
        }
    }
}

- (void)kpsd_cancelImageLoadOperationWithKey:(nullable NSString *)key {
    // Cancel in progress downloader from queue
    KPSDOperationsDictionary *operationDictionary = [self kpsd_operationDictionary];
    id<KPSDWebImageOperation> operation;
    @synchronized (self) {
        operation = [operationDictionary objectForKey:key];
    }
    if (operation) {
        if ([operation conformsToProtocol:@protocol(KPSDWebImageOperation)]){
            [operation cancel];
        }
        @synchronized (self) {
            [operationDictionary removeObjectForKey:key];
        }
    }
}

- (void)kpsd_removeImageLoadOperationWithKey:(nullable NSString *)key {
    if (key) {
        KPSDOperationsDictionary *operationDictionary = [self kpsd_operationDictionary];
        @synchronized (self) {
            [operationDictionary removeObjectForKey:key];
        }
    }
}

@end

#endif
