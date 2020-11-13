//
//  UIImage+Utils.m
//  YBImageBrowserDemo
//
//  Created by xukj on 2019/4/22.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "UIImage+Utils.h"

@implementation UIImage (Utils)

- (UIImage *)resizeToSize:(CGSize)size
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:self];
    //创建一个input image类型的滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:kCIInputImageKey, ciImage, nil];
    //设置默认的滤镜效果
    [filter setDefaults];
    
    //设置缩放比例
    CGFloat scale = 1;
    if (size.width != CGFLOAT_MAX) {
        scale = (CGFloat) size.width / self.size.width;
    } else if (size.height != CGFLOAT_MAX) {
        scale = (CGFloat) size.height / self.size.height;
    }
    
    //进行赋值
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
    [filter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    //通过GPU的方式来进行处理
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];
    //根据滤镜输出图片
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    //创建UIImage 对象，并释放资源
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}

@end
