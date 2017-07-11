//
//  HR_PalyerView.h
//  HR_Video
//
//  Created by HenryGao on 2017/7/6.
//  Copyright © 2017年 HenryGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import "HR_VideoShowView.h"



typedef enum : NSUInteger {             // 结果
    HR_PalyerViewStatusSuccess = 10,    // 成功
    HR_PalyerViewStatusFial,            // 失败
    HR_PalyerViewStatusUnknow,          // 未知错误
} HR_PalyerViewStatus;


typedef enum : NSUInteger {
    HR_MOVEDIRECTIONNONE  = 1,          // 默认（未识别）
    HR_MOVEDIRECTIONV,                  // 竖屏
    HR_MOVEDIRECTIONH,                  // 横屏
} HR_MOVEDIRECTION;



typedef NS_ENUM(NSUInteger, MovieViewState) {   // 视频切换 状态
    MovieViewStateSmall,        //  小
    MovieViewStateAnimating,    //  正在播放
    MovieViewStateFullscreen,   //  大
};



typedef void(^HR_PalyerViewResults)(NSDictionary *results);         // 传递 结果 与 说明

@interface HR_PalyerView : UIView<HR_VideoShowViewDelegate>


// 视频 切换
@property (nonatomic,assign) CGRect oldFrame;                // 原始大小





#pragma mark --------------HenryGao 资源
@property (nonatomic,retain) NSURL *videoUrl;                //Video地址 （单个）
@property (nonatomic,retain) NSArray<NSURL *> *videoUrlArr;  //Video地址 （多个，默认 自动播放）

#pragma mark --------------HenryGao 操作： 播放 、暂停、 全屏 、 下一个    销毁、全屏
- (void)HR_Play:(HR_PalyerViewResults)aResult;        // 播放
- (void)HR_Suspended:(HR_PalyerViewResults)aResult;   // 暂停
- (void)HR_NextVideo:(HR_PalyerViewResults)aResult;   // 下一个（视频资源数 为 1 不生效）目前没实现

- (void)HR_FullPlayerView:(HR_PalyerViewResults)aResult;    // 全屏 视图
- (void)HR_DissPlayerView:(HR_PalyerViewResults)aResult;    // 销毁 视图




#pragma mark --------------HenryGao 操作的错误 说明：
@property (nonatomic,copy) __block HR_PalyerViewResults hr_PalyResults;







@end
