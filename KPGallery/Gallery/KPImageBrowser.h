//
//  KPImageBrowser.h
//  KPGallery
//
//  Created by xukj on 2019/4/23.
//  Copyright © 2019 kpframework. All rights reserved.
//

#import "YBImageBrowser.h"
#import "KPImageBrowserDelegate.h"

#define KPORIENTATION_AUTO @"auto"
#define KPORIENTATION_PORTRAIT @"portrait"
#define KPORIENTATION_LANDSCAPE @"landscape"

NS_ASSUME_NONNULL_BEGIN

@interface KPImageBrowser : YBImageBrowser

@property (nonatomic, weak) _Nullable id<KPImageBrowserDelegate> kpDelegate;

@property (nonatomic, strong) NSString *kpOrientation;
@property (nonatomic, assign) BOOL useSeek;

@end

NS_ASSUME_NONNULL_END
