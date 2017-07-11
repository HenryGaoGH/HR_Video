//
//  HR_VideoProgressView.h
//  HR_Video
//
//  Created by HenryGao on 2017/7/7.
//  Copyright © 2017年 HenryGao. All rights reserved.
//

#import <UIKit/UIKit.h>




@protocol HR_VideoProgressViewDelegate <NSObject>

- (void)HR_VideoProgressViewDelegate:(float )aProgress;

@end


@interface HR_VideoProgressView : UIProgressView

@property (nonatomic,assign) id<HR_VideoProgressViewDelegate> hr_videoProgressViewDelegate;

@property (nonatomic,retain) UISlider *nowProgressSlider;    //播放 进度 拖放




@end
