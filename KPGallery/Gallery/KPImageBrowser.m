//
//  KPImageBrowser.m
//  KPGallery
//
//  Created by xukj on 2019/4/23.
//  Copyright © 2019 kpframework. All rights reserved.
//

#import "KPImageBrowser.h"
#import "KPNativeBrowserToolBar.h"
#import "KPNativeBrowserSeekBar.h"

@interface KPImageBrowser ()<YBImageBrowserDelegate, KPNativeBrowserSeekBarProtocal>

@property (nonatomic, strong) KPNativeBrowserToolBar *kpToolBar;
@property (nonatomic, strong) KPNativeBrowserSeekBar *kpSeekBar;
@property (nonatomic, assign) UIInterfaceOrientation kpOrientationBefore;
@property (nonatomic, assign) UIInterfaceOrientation kpOrientationDefault;

@end

@implementation KPImageBrowser

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.toolBars = @[self.kpToolBar, self.kpSeekBar];
        self.delegate = self;
        self.kpSeekBar.delegate = self;
        self.kpOrientationBefore = UIInterfaceOrientationUnknown;
        self.kpOrientationDefault = UIInterfaceOrientationUnknown;
    }
    return self;
}

#pragma mark - delegate

- (void)yb_imageBrowser:(YBImageBrowser *)imageBrowser pageIndexChanged:(NSUInteger)index data:(id<YBImageBrowserCellDataProtocol>)data
{
    // do nothing
    if (self.kpDelegate && [self.kpDelegate respondsToSelector:@selector(imageBrowser:pageIndexChanged:)]) {
        [self.kpDelegate imageBrowser:self pageIndexChanged:index];
    }
}

- (void)seekbar:(UISlider *)slider didChangeIndex:(NSUInteger)index
{
    self.currentIndex = index;
}

#pragma mark - override

- (void)yb_imageBrowserViewDismiss:(YBImageBrowserView *)browserView {
    // 屏蔽单击关闭操作
    if (self.useSeek) {
        self.kpSeekBar.contentView.hidden = !self.kpSeekBar.contentView.isHidden;
    }
}

- (void)show {
    // 重写父类方法，增加横竖屏旋转操作
    self.kpOrientationBefore = [[UIApplication sharedApplication] statusBarOrientation];
    self.kpOrientationDefault = self.kpOrientationBefore;
    
    if ([KPORIENTATION_PORTRAIT isEqualToString:self.kpOrientation]) {
        // 竖屏展示
        self.supportedOrientations = UIInterfaceOrientationMaskPortrait;
        self.kpOrientationDefault = UIInterfaceOrientationPortrait;
    }
    else if ([KPORIENTATION_LANDSCAPE isEqualToString:self.kpOrientation]) {
        // 横屏展示
        self.supportedOrientations = UIInterfaceOrientationMaskLandscape;
        self.kpOrientationDefault = UIInterfaceOrientationLandscapeRight;
    }
    else {
        // 自动展示
    }
    
    __weak typeof(self) wSelf = self;
    [self showOnCompletion:^{
        __strong typeof(self) sSelf = wSelf;
        [sSelf changeOrientation:sSelf.kpOrientationDefault];
    }];
}

- (void)hide {
    __weak typeof(self) wSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        __strong typeof(self) sSelf = wSelf;
        // 重写父类方法，关闭时需要重置横竖屏
        if (sSelf.kpOrientationBefore != [[UIApplication sharedApplication] statusBarOrientation]) {
            [sSelf changeOrientation:sSelf.kpOrientationBefore];
        }
    }];
}

#pragma mark - private

// 旋转屏幕
- (void)changeOrientation:(UIInterfaceOrientation)destOrientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        
        // 设置支持横屏还是竖屏
        // if (UIInterfaceOrientationIsPortrait(destOrientation)) {
        //     self.supportedOrientations = UIInterfaceOrientationMaskPortrait;
        // }
        // else if (UIInterfaceOrientationIsLandscape(destOrientation)) {
        //     self.supportedOrientations = UIInterfaceOrientationMaskLandscape;
        // }
        
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        NSInteger val = destOrientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
        
        [UIViewController attemptRotationToDeviceOrientation];
    }
}

#pragma mark - getter/setter

- (KPNativeBrowserToolBar *)kpToolBar
{
    if (_kpToolBar == nil) {
        _kpToolBar = [KPNativeBrowserToolBar new];
        [_kpToolBar.closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    }
    return _kpToolBar;
}

- (KPNativeBrowserSeekBar *)kpSeekBar
{
    if (_kpSeekBar == nil) {
        _kpSeekBar = [KPNativeBrowserSeekBar new];
    }
    return _kpSeekBar;
}

- (void)dealloc
{
    if (self.kpDelegate && [self.kpDelegate respondsToSelector:@selector(imageBrowserClose)]) {
        [self.kpDelegate imageBrowserClose];
    }
    NSLog(@"dealloc");
}

@end
