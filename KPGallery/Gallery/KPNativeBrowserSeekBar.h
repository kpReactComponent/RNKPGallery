//
//  KPNativeBrowserSeekBar.h
//  KPGallery
//
//  Created by xukj on 2019/6/20.
//

#import <UIKit/UIKit.h>
#import "YBImageBrowserToolBarProtocol.h"

@protocol KPNativeBrowserSeekBarProtocal <NSObject>

@required
-(void)seekbar:(UISlider * _Nonnull)slider didChangeIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_BEGIN

@interface KPNativeBrowserSeekBar : UIView <YBImageBrowserToolBarProtocol>

@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong, readonly) UISlider *slider;
@property (nonatomic, weak)id<KPNativeBrowserSeekBarProtocal> delegate;

@end

NS_ASSUME_NONNULL_END
