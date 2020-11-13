//
//  KPNativeBrowserToolBar.m
//  KPNativeGallery
//
//  Created by xukj on 2019/4/23.
//  Copyright © 2019 kpframework. All rights reserved.
//

#import "KPNativeBrowserToolBar.h"
#import "YBIBUtilities.h"
#import "YBIBFileManager.h"
#import "KPGalleryLabel.h"

static CGFloat kToolBarDefaultsHeight = 50.0;

@interface KPNativeBrowserToolBar () {
    id<YBImageBrowserCellDataProtocol> _data;
}

@property (nonatomic, strong) KPGalleryLabel *indexLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) CAGradientLayer *gradient;

@end

@implementation KPNativeBrowserToolBar

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer addSublayer:self.gradient];
        [self addSubview:self.indexLabel];
        [self addSubview:self.closeButton];
    }
    return self;
}

- (void)resizeLabelFrame
{
    // 获取中心点
    CGPoint center = self.center;
    center.y = center.y + (CGRectGetHeight(self.bounds) - kToolBarDefaultsHeight) / 2;
    // 计算文本大小
    NSString *text = self.indexLabel.text ? : @"";
    CGRect textBounds = [text boundingRectWithSize:self.bounds.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.indexLabel.font} context:nil];
    self.indexLabel.bounds = CGRectInset(textBounds, -16, -8);
    self.indexLabel.center = center;
}

#pragma mark - <YBImageBrowserToolBarProtocol>

- (void)yb_browserUpdateLayoutWithDirection:(YBImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize {
    
    CGFloat height = kToolBarDefaultsHeight;
    CGFloat width = containerSize.width;
    CGFloat buttonWidth = 53;
    CGFloat labelWidth = width / 3.0;
    CGFloat hExtra = 0;
    
    if (containerSize.height > containerSize.width && YBIB_IS_IPHONEX) height += YBIB_HEIGHT_STATUSBAR;
    if (containerSize.height < containerSize.width && YBIB_IS_IPHONEX) hExtra += YBIB_HEIGHT_EXTRABOTTOM;
    
    self.frame = CGRectMake(0, 0, width, height);
    self.gradient.frame = self.bounds;
    
//    self.indexLabel.frame = CGRectMake((width - labelWidth) / 2, height - kToolBarDefaultsHeight, labelWidth + 10, kToolBarDefaultsHeight);
    [self resizeLabelFrame];
    
    self.closeButton.frame = CGRectMake(0, height - kToolBarDefaultsHeight, buttonWidth, kToolBarDefaultsHeight);
}

- (void)yb_browserPageIndexChanged:(NSUInteger)pageIndex totalPage:(NSUInteger)totalPage data:(id<YBImageBrowserCellDataProtocol>)data {
    self->_data = data;
    self.indexLabel.text = [NSString stringWithFormat:@"%ld / %ld", pageIndex + 1, totalPage];
    [self resizeLabelFrame];
}

#pragma mark - event

- (void)clickCloseButton:(UIButton *)button {
    // 关闭当前controller
}

#pragma mark - getter

- (KPGalleryLabel *)indexLabel {
    if (!_indexLabel) {
        _indexLabel = [KPGalleryLabel new];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.font = [UIFont boldSystemFontOfSize:18];
        _indexLabel.textAlignment = NSTextAlignmentRight;
        _indexLabel.kpAlignment = KPAlignmentMiddle;
        _indexLabel.adjustsFontSizeToFitWidth = YES;
        _indexLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        _indexLabel.layer.cornerRadius = 2;
        _indexLabel.layer.masksToBounds = YES;
    }
    return _indexLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _closeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(clickCloseButton:)
               forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setImage:[YBIBFileManager getImageWithName:@"ybib_cancel"] forState:UIControlStateNormal];
    }
    return _closeButton;
}

- (CAGradientLayer *)gradient {
    if (!_gradient) {
        _gradient = [CAGradientLayer layer];
        _gradient.startPoint = CGPointMake(0.5, 0);
        _gradient.endPoint = CGPointMake(0.5, 1);
        _gradient.colors = @[(id)[UIColor colorWithRed:0  green:0  blue:0 alpha:0.3].CGColor, (id)[UIColor colorWithRed:0  green:0  blue:0 alpha:0].CGColor];
    }
    return _gradient;
}

@end
