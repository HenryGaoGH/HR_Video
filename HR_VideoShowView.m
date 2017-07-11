//
//  HR_VideoShowView.m
//  HR_Video
//
//  Created by HenryGao on 2017/7/6.
//  Copyright © 2017年 HenryGao. All rights reserved.
//


#define THISWIDTH self.frame.size.width
#define THISHEIGHT self.frame.size.height



#import "HR_VideoShowView.h"




@implementation HR_VideoShowView{
    
    UILabel *vTitle;       // 标题
    UILabel *afterLabel;  // 播放时间
    UILabel *allTimeL;    // 总时间
    UIButton *playButton;   //
    UIButton *fullButton;
    UIButton *backButton;
    
    HR_VideoProgressView *hr_progressV;
    
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
    self.backgroundColor = [UIColor clearColor];
    
    // 标题
    vTitle = [UILabel new];
    vTitle.frame = CGRectMake(0, 20 ,THISWIDTH , 50);
    vTitle.userInteractionEnabled = NO;
    vTitle.text = @"默认占位标题";
    vTitle.textColor = [UIColor lightGrayColor];
    vTitle.textAlignment = NSTextAlignmentCenter;
    [self addSubview:vTitle];
    
    
    
    // 返回 按钮
    backButton = [UIButton new];
    backButton.frame = CGRectMake(5, 20, 44, 44);
    backButton.tag = 100;
    [backButton setImage:[UIImage imageNamed:@"backButton"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backButton];
    
    
    
    // 暂停 、 播放 按钮
    playButton = [UIButton new];
    playButton.bounds = CGRectMake(0, 0, THISWIDTH / 6, THISWIDTH / 6);
    playButton.center = self.center;
    playButton.tag = 101;
    playButton.selected = YES;
    [playButton setImage:[UIImage imageNamed:@"b"] forState:UIControlStateNormal];
    [playButton setImage:[UIImage imageNamed:@"p"] forState:UIControlStateSelected];
    [playButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:playButton];
    
    
    // 时间 （已播放）
    afterLabel = [UILabel new];
    afterLabel.frame = CGRectMake(10, THISHEIGHT - 30, 30, 20);
    afterLabel.text = @"00:00:00";
    afterLabel.textColor = [UIColor lightGrayColor];
    afterLabel.textAlignment = NSTextAlignmentCenter;
    afterLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:afterLabel];
    
    
    // 进度条 ：
    
    hr_progressV = [[HR_VideoProgressView alloc]initWithFrame:CGRectMake(40, THISHEIGHT - 20, THISWIDTH - 100 , 30)];
    hr_progressV.backgroundColor = [UIColor whiteColor];
    hr_progressV.progress = 0.f;
    hr_progressV.progressTintColor = [UIColor grayColor];
    [self addSubview:hr_progressV];
    
    
    // 时间 （总）
    allTimeL = [UILabel new];
    allTimeL.frame = CGRectMake(THISWIDTH - 60, THISHEIGHT - 30, 30 , 20);
    allTimeL.text = @"00:00:00";
    allTimeL.adjustsFontSizeToFitWidth = YES;
    allTimeL.textColor = [UIColor lightGrayColor];
    allTimeL.textAlignment = NSTextAlignmentCenter;
    [self addSubview:allTimeL];
    
    
    // 全屏
    fullButton = [UIButton new];
    fullButton.tag = 102;
    fullButton.frame = CGRectMake(THISWIDTH - 30, THISHEIGHT - 30, 30, 30);
    [fullButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [fullButton setImage:[UIImage imageNamed:@"fullButtonN"] forState:UIControlStateNormal];
    [fullButton setImage:[UIImage imageNamed:@"fullButtonS"] forState:UIControlStateSelected];
    [self addSubview:fullButton];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self HR_Hidden];
    });
}







#pragma mark 点击事件 (返回、 放大、 暂停)
- (void)buttonAction:(UIButton *)aButton{
    switch (aButton.tag) {
        case 100:{
            [self.hr_VideoShowViewDelegate HR_VideoShowViewDelegateAllButton:aButton];
        }
            break;
        case 101:{
            aButton.selected = !aButton.selected;
            [self.hr_VideoShowViewDelegate HR_VideoShowViewDelegateAllButton:aButton];
        }
            break;
        case 102:{
            aButton.selected = !aButton.selected;
            [self.hr_VideoShowViewDelegate HR_VideoShowViewDelegateAllButton:aButton];
        }
            break;
            
        default:
            break;
    }
    
}











#pragma mark- ========== SET ===========
/** Single line comment spreading
 * HenryGao
 * 写点说明。。。。。 设置 代理、标题、 视频时间 、 视频进度、
 **/
- (void)setHr_VideoShowViewDelegate:(id<HR_VideoShowViewDelegate>)hr_VideoShowViewDelegate{
    if (_hr_VideoShowViewDelegate != hr_VideoShowViewDelegate) {
        _hr_VideoShowViewDelegate = hr_VideoShowViewDelegate;
    }
    id<HR_VideoProgressViewDelegate> temp = (id)hr_VideoShowViewDelegate;
    if (hr_progressV.hr_videoProgressViewDelegate != temp) {
        hr_progressV.hr_videoProgressViewDelegate = temp;
    }
    
}
- (void)setVideoTitle:(NSString *)videoTitle{   // 标题
    if (videoTitle == nil || _videoTitle == videoTitle) return;
    _videoTitle = videoTitle;
    vTitle.text = _videoTitle;
    
}
- (void)setNowTime:(NSString *)nowTime{
    if (_nowTime == nowTime) return;
    _nowTime = nowTime;
    afterLabel.text = nowTime;
    
}
- (void)setAllTime:(NSString *)allTime{
    if (_allTime == allTime) return;
    _allTime = allTime;
    allTimeL.text = allTime;
}
- (void)setCacheProgress:(float)cacheProgress{
    if (_cacheProgress == cacheProgress) return;
    _cacheProgress = cacheProgress;
    hr_progressV.progress = cacheProgress;
}
- (void)setAllProgress:(float)allProgress{
    if (_allProgress == allProgress) return;
    _allProgress = allProgress;
    hr_progressV.nowProgressSlider.maximumValue = allProgress;
    
}
- (void)setPlayProgress:(float)playProgress{
    if (_playProgress == playProgress) return;
    _playProgress = playProgress;
    hr_progressV.nowProgressSlider.value = playProgress;
    
}






- (void)layoutSubviews{
    [super layoutSubviews];
    // 布局
    vTitle.frame = CGRectMake(0, 20 ,THISWIDTH , 50);
    backButton.frame = CGRectMake(5, 20, 44, 44);
    playButton.center = self.center;
    playButton.bounds = CGRectMake(0, 0, THISWIDTH / 6, THISWIDTH / 6);
    afterLabel.frame = CGRectMake(10, THISHEIGHT - 30, 30, 20);
    hr_progressV.frame = CGRectMake(40, THISHEIGHT - 20, THISWIDTH - 100 , 30);
    allTimeL.frame = CGRectMake(THISWIDTH - 60, THISHEIGHT - 30, 30 , 20);
    fullButton.frame = CGRectMake(THISWIDTH - 30, THISHEIGHT - 30, 30, 30);
    
}









#pragma mark- ========== 显示、 隐藏 ===========
/** Single line comment spreading
 * HenryGao
 * 写点说明。。。。。
 **/
- (void)HR_Show{
    if (!self.isHidden) return;
    self.hidden = NO;
    self.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self HR_Hidden];
    });
    
    
}
- (void)HR_Hidden{
    if (self.isHidden) return;
    self.alpha = 1;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}















@end
