//
//  OpenCVWrapper.m
//  ZenniPOC
//
//  Created by Avenue Code on 12/11/17.
//  Copyright © 2017 AvenueCode. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/imgproc_c.h>
#import "OpenCVWrapper.h"

NSString * const templateCardImageName = @"templateCard";

@implementation OpenCVWrapper
- (NSString *)getOpenCVVersion {
    return [NSString stringWithFormat:@"Version is %s", CV_VERSION];
}

- (UIImage *)proccessImage:(UIImage *)image {
    cv::Mat cvImage = [self cvMatFromUIImage:image];

    cv::Mat greyMat;
    cv::cvtColor(cvImage, cvImage, CV_BGR2GRAY);


    cv::Mat blurred(cvImage);
    cv::blur(cvImage, cvImage, cv::Size(5,5));

    cv::Mat imageWithCanny;
    cv::Canny(cvImage, imageWithCanny, 20, 40 * 3);

    UIImage *finalImage = [self UIImageFromCVMat:imageWithCanny];
    return finalImage;
}


- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;

    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels

    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags

    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);

    return cvMat;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;

    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }

    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);

    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );


    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);

    return finalImage;
}
@end
