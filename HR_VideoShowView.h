//
//  HR_VideoShowView.h
//  HR_Video
//
//  Created by HenryGao on 2017/7/6.
//  Copyright © 2017年 HenryGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HR_VideoProgressView.h"


typedef void(^HR_VideoShowViewProgress)(float progress);    // 进度



@protocol HR_VideoShowViewDelegate <NSObject>
@required
- (void)HR_VideoShowViewDelegateAllButton:(UIButton *)aButton;
@end



@interface HR_VideoShowView : UIView

@property (nonatomic,assign) id<HR_VideoShowViewDelegate> hr_VideoShowViewDelegate;
@property (nonatomic,copy) HR_VideoShowViewProgress hr_VideoShowViewProgress;

// 设置 进度
@property (nonatomic,assign) float cacheProgress;   //缓存 进度 0。。。1

// slider
@property (nonatomic,assign) float allProgress;     //总播放进度  slider
@property (nonatomic,assign) float playProgress;    //播放 进度  slider


// 设置 当前时间 、 总时间
@property (nonatomic,assign) NSString *nowTime;   //当前时间
@property (nonatomic,assign) NSString *allTime;   //总时间


// 设置 视频标题
@property (nonatomic,retain) NSString *videoTitle;  //视频标题


// 隐藏、 展示
- (void)HR_Show;
- (void)HR_Hidden;









@end
