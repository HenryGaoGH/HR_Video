//
//  HR_VideoProgressView.m
//  HR_Video
//
//  Created by HenryGao on 2017/7/7.
//  Copyright © 2017年 HenryGao. All rights reserved.
//
#ifdef DEBUG
#define HRLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define NSLog(...)
#endif


#import "HR_VideoProgressView.h"

@implementation HR_VideoProgressView{
    
    float nowProgress;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init{
    self = [super init];
    if (self) {
        [self createView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createView];
    }
    return self;
}


- (void)createView{
    
    // Slider
    _nowProgressSlider = [UISlider new];
    _nowProgressSlider.backgroundColor = [UIColor clearColor];
    _nowProgressSlider.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _nowProgressSlider.minimumValue = 0;
    [_nowProgressSlider setMinimumTrackTintColor:[UIColor redColor]];
    [_nowProgressSlider setMaximumTrackTintColor:[UIColor clearColor]];
    [_nowProgressSlider setThumbTintColor:[UIColor clearColor]];
    [_nowProgressSlider addTarget:self action:@selector(HR_sliderAction:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_nowProgressSlider];
    
}



- (void)HR_sliderAction:(UISlider *)aSlider{
    HRLog(@"------%f",aSlider.value);
    if (aSlider.value == nowProgress) return;
    if ([self.hr_videoProgressViewDelegate respondsToSelector:@selector(HR_VideoProgressViewDelegate:)]) {
        [self.hr_videoProgressViewDelegate HR_VideoProgressViewDelegate:aSlider.value];
        nowProgress = aSlider.value;
    }
    
}




//- (void)layoutSubviews{
//    _nowProgressSlider.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
//}








@end
