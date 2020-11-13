//
//  KPImageBrowseCellData.m
//  KPNativeGallery
//
//  Created by xukj on 2019/4/23.
//  Copyright © 2019 kpframework. All rights reserved.
//

#import "KPImageBrowseCellData.h"

@implementation KPImageBrowseCellData

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.allowShowSheetView = NO;
        self.allowSaveToPhotoAlbum = NO;
    }
    return self;
}

@end
