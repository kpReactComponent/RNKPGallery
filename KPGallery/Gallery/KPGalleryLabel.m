//
//  KPGalleryLabel.m
//  KPGallery
//
//  Created by xukj on 2019/6/20.
//

#import "KPGalleryLabel.h"

@implementation KPGalleryLabel

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.kpAlignment = KPAlignmentTop;
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    switch (self.kpAlignment) {
        case KPAlignmentBottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;
            break;
        case KPAlignmentMiddle:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0;
            break;
        case KPAlignmentTop:
        default:
            textRect.origin.y = bounds.origin.y;
    }
    return textRect;
}

-(void)drawTextInRect:(CGRect)requestedRect {
    CGRect actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:actualRect];
}

- (void)setKpAlignment:(KPLabelAlignment)kpAlignment
{
    _kpAlignment = kpAlignment;
    [self setNeedsDisplay];
}

@end
