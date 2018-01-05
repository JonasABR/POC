//
//  OpenCVWrapper.h
//  ZenniPOC
//
//  Created by Avenue Code on 12/11/17.
//  Copyright © 2017 AvenueCode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject
- (NSString *)getOpenCVVersion;
- (UIImage *)proccessImage:(UIImage *)image;
@end
