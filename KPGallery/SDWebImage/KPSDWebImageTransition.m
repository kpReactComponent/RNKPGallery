/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "KPSDWebImageTransition.h"

#if KPSD_UIKIT || KPSD_MAC

#if KPSD_MAC
#import <QuartzCore/QuartzCore.h>
#endif

@implementation KPSDWebImageTransition

- (instancetype)init {
    self = [super init];
    if (self) {
        self.duration = 0.5;
    }
    return self;
}

@end

@implementation KPSDWebImageTransition (Conveniences)

+ (KPSDWebImageTransition *)fadeTransition {
    KPSDWebImageTransition *transition = [KPSDWebImageTransition new];
#if KPSD_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionCrossDissolve;
#else
    transition.animations = ^(__kindof NSView * _Nonnull view, NSImage * _Nullable image) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionFade;
        [view.layer addAnimation:trans forKey:kCATransition];
    };
#endif
    return transition;
}

+ (KPSDWebImageTransition *)flipFromLeftTransition {
    KPSDWebImageTransition *transition = [KPSDWebImageTransition new];
#if KPSD_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionFlipFromLeft;
#else
    transition.animations = ^(__kindof NSView * _Nonnull view, NSImage * _Nullable image) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionPush;
        trans.subtype = kCATransitionFromLeft;
        [view.layer addAnimation:trans forKey:kCATransition];
    };
#endif
    return transition;
}

+ (KPSDWebImageTransition *)flipFromRightTransition {
    KPSDWebImageTransition *transition = [KPSDWebImageTransition new];
#if KPSD_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionFlipFromRight;
#else
    transition.animations = ^(__kindof NSView * _Nonnull view, NSImage * _Nullable image) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionPush;
        trans.subtype = kCATransitionFromRight;
        [view.layer addAnimation:trans forKey:kCATransition];
    };
#endif
    return transition;
}

+ (KPSDWebImageTransition *)flipFromTopTransition {
    KPSDWebImageTransition *transition = [KPSDWebImageTransition new];
#if KPSD_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionFlipFromTop;
#else
    transition.animations = ^(__kindof NSView * _Nonnull view, NSImage * _Nullable image) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionPush;
        trans.subtype = kCATransitionFromTop;
        [view.layer addAnimation:trans forKey:kCATransition];
    };
#endif
    return transition;
}

+ (KPSDWebImageTransition *)flipFromBottomTransition {
    KPSDWebImageTransition *transition = [KPSDWebImageTransition new];
#if KPSD_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionFlipFromBottom;
#else
    transition.animations = ^(__kindof NSView * _Nonnull view, NSImage * _Nullable image) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionPush;
        trans.subtype = kCATransitionFromBottom;
        [view.layer addAnimation:trans forKey:kCATransition];
    };
#endif
    return transition;
}

+ (KPSDWebImageTransition *)curlUpTransition {
    KPSDWebImageTransition *transition = [KPSDWebImageTransition new];
#if KPSD_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionCurlUp;
#else
    transition.animations = ^(__kindof NSView * _Nonnull view, NSImage * _Nullable image) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionReveal;
        trans.subtype = kCATransitionFromTop;
        [view.layer addAnimation:trans forKey:kCATransition];
    };
#endif
    return transition;
}

+ (KPSDWebImageTransition *)curlDownTransition {
    KPSDWebImageTransition *transition = [KPSDWebImageTransition new];
#if KPSD_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionCurlDown;
#else
    transition.animations = ^(__kindof NSView * _Nonnull view, NSImage * _Nullable image) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionReveal;
        trans.subtype = kCATransitionFromBottom;
        [view.layer addAnimation:trans forKey:kCATransition];
    };
#endif
    return transition;
}

@end

#endif
