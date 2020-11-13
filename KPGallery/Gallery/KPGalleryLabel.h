//
//  KPGalleryLabel.h
//  KPGallery
//
//  Created by xukj on 2019/6/20.
//

#import <UIKit/UIKit.h>

typedef enum {
    KPAlignmentTop = 0, // default
    KPAlignmentMiddle,
    KPAlignmentBottom,
} KPLabelAlignment;

NS_ASSUME_NONNULL_BEGIN

@interface KPGalleryLabel : UILabel

@property (nonatomic, assign) KPLabelAlignment kpAlignment;

@end

NS_ASSUME_NONNULL_END
