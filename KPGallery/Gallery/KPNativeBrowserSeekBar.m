//
//  KPNativeBrowserSeekBar.m
//  KPGallery
//
//  Created by xukj on 2019/6/20.
//

#import "KPNativeBrowserSeekBar.h"
#import "YBIBUtilities.h"
#import "KPGalleryLabel.h"

static CGFloat kSeekBarDefaultsHeight = 50.0;
static CGFloat kPageSize = 100;

@interface KPNativeBrowserSeekBar ()

@property (nonatomic, strong) UIView *vPageView;
@property (nonatomic, strong) KPGalleryLabel *labPage;
@property (nonatomic, strong) UIView *vToolBar;
@property (nonatomic, strong) UISlider *slider;

@property (nonatomic, assign) BOOL seeking;

@end

@implementation KPNativeBrowserSeekBar

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.vToolBar];
        [self.vToolBar addSubview:self.slider];
        [self.vPageView addSubview:self.labPage];
    }
    return self;
}

#pragma mark - delegate

-(void)yb_browserUpdateLayoutWithDirection:(YBImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize
{
    CGFloat height = kSeekBarDefaultsHeight;
    CGFloat width = containerSize.width;
    CGFloat hExtra = 0;
    
    if (containerSize.height > containerSize.width && YBIB_IS_IPHONEX) height += YBIB_HEIGHT_STATUSBAR;
    if (containerSize.height < containerSize.width && YBIB_IS_IPHONEX) hExtra += YBIB_HEIGHT_EXTRABOTTOM;
    
    self.frame = CGRectMake(0, containerSize.height - height, width, height);
    
    self.vToolBar.frame = self.bounds;
    self.slider.frame = CGRectMake(5, height / 2 - 10, width - 10, 20);
    
    self.vPageView.frame = CGRectMake(0, 0, kPageSize, kPageSize);
    self.vPageView.center = CGPointMake(containerSize.width / 2, containerSize.height / 2);
    self.labPage.frame = self.vPageView.bounds;
}

-(void)yb_browserPageIndexChanged:(NSUInteger)pageIndex totalPage:(NSUInteger)totalPage data:(id<YBImageBrowserCellDataProtocol>)data
{
    self.slider.maximumValue = totalPage - 1;
    self.slider.value = pageIndex;
}

#pragma mark - private

- (void)onValueChanged:(UISlider *)slider
{
    if (!self.seeking) {
        self.seeking = YES;
        [self.superview addSubview:self.vPageView];
    }
    
    NSUInteger index = (NSUInteger)(slider.value + 0.5);
    [slider setValue:index animated:NO];
    
    self.labPage.text = [NSString stringWithFormat:@"%lu", index + 1];
}

- (void)onTouchUp:(UISlider *)slider
{
    self.seeking = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(seekbar:didChangeIndex:)]) {
        [self.delegate seekbar:slider didChangeIndex:(NSUInteger)slider.value];
    }
    
    [self.vPageView removeFromSuperview];
}

#pragma mark - getter/setter

- (UIView *)contentView
{
    return self.vToolBar;
}

- (UIView *)vToolBar
{
    if (_vToolBar == nil) {
        _vToolBar = [UIView new];
        _vToolBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        _vToolBar.hidden = YES;
    }
    return _vToolBar;
}

- (UIView *)vPageView
{
    if (_vPageView == nil){
        _vPageView = [UIView new];
        _vPageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        _vPageView.layer.cornerRadius = 4;
        _vPageView.layer.masksToBounds = YES;
    }
    return _vPageView;
}

- (KPGalleryLabel *)labPage
{
    if (_labPage == nil) {
        _labPage = [KPGalleryLabel new];
        _labPage.font = [UIFont systemFontOfSize:36];
        _labPage.textColor = [UIColor whiteColor];
        _labPage.textAlignment = NSTextAlignmentCenter;
        _labPage.kpAlignment = KPAlignmentMiddle;
    }
    return _labPage;
}

- (UISlider *)slider
{
    if (_slider == nil) {
        _slider = [UISlider new];
        [_slider addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(onTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [_slider addTarget:self action:@selector(onTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    }
    return _slider;
}

@end
