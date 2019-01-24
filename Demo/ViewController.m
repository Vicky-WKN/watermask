//
//  ViewController.m
//  Demo
//
//  Created by Ailsa on 2019/1/21.
//  Copyright © 2019 Ailsa. All rights reserved.
//

#import "ViewController.h"
#import "EditImageView.h"

#define K_W [UIScreen mainScreen].bounds.size.width
#define K_H [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<EditImageViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) EditImageView *markIV;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)addWaterMark:(id)sender {
    if (self.markIV) {
        [self.markIV removeFromSuperview];
        self.markIV = nil;
    }
    UIImage *image = [UIImage imageNamed:@"mask"];
    CGPoint center = self.imageView.center;
    CGFloat imgW = image.size.width;
    CGFloat imgH = image.size.height;
    CGFloat endW = imgW * 80 * [UIScreen mainScreen].bounds.size.width / (imgH * 375) + 20;
    CGFloat endH = 80 + 20;
    self.markIV = [[EditImageView alloc] initWithFrame:CGRectMake(center.x - endW * 0.5, center.y - endH * 0.5, endW, endH)];
    self.markIV.showContentShadow = NO;
    self.markIV.delegate = self;
    self.markIV.contentIV.image = image;
    self.markIV.userInteractionEnabled = YES;
    [self.markIV showEditingHandles];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addSubview:self.markIV];
}
- (IBAction)save:(id)sender {
    UIImage *bgImage = [UIImage imageNamed:@"source"];
    UIImage *markImg = [UIImage imageNamed:@"mask"];
    CGSize size = bgImage.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [bgImage drawAtPoint:CGPointMake(0, 0)];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawPath(context, kCGPathStroke);
    
    CGFloat endX, endY, bigW, bigH;
    CGFloat scale = 1.0;
    if (size.width >= size.height) {
        scale = size.width / K_W;
        bigW = K_W;
        bigH = K_W*size.height / size.width;
        CGFloat ySpace = (self.imageView.frame.size.height - bigH) / 2.0;
        endX = self.markIV.frame.origin.x;
        endY = self.markIV.frame.origin.y - ySpace;
    }else {
        scale = size.height / self.imageView.frame.size.height;
        bigW = self.imageView.frame.size.height * size.width / size.height;
        bigH = self.imageView.frame.size.height;
        CGFloat xSpace = (K_W - bigW) / 2.0;
        endX = self.markIV.frame.origin.x - xSpace;
        endY = self.markIV.frame.origin.y;
    }
    //图片的比例自行计算，我算的不太好
    CGSize endMarkSize = CGSizeMake(self.markIV.frame.size.width*scale, self.markIV.frame.size.height*scale);
    CGRect markRect = CGRectMake(endX*scale, endY*scale, endMarkSize.width, endMarkSize.height);
    //将绘制原点调整到源图片的中心
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(size.width / 2, size.height / 2));
    //以绘制原点为中心旋转
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(self.markIV.rotationAngle));
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-size.width / 2, -size.height / 2));
    [markImg drawInRect:markRect];

    UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGContextRestoreGState(context);
    UIImageWriteToSavedPhotosAlbum(newImg, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"保存成功");
}


#pragma mark - EditImageViewDelegate

- (void)editImageViewDidClose:(EditImageView *)sticker {
    [sticker removeFromSuperview];
}



@end
