//
//  HR_PalyerView.m
//  HR_Video
//
//  Created by HenryGao on 2017/7/6.
//  Copyright © 2017年 HenryGao. All rights reserved.
//

#define THISWIDTH self.frame.size.width
#define THISHEIGHT self.frame.size.height



#import "HR_PalyerView.h"
#import <MediaPlayer/MediaPlayer.h>



@interface HR_PalyerView ()
// 私有
@property (nonatomic,retain) AVURLAsset *hr_UrlAsset;      // Url 属性
@property (nonatomic,retain) AVPlayerItem *hr_playerItem;  // 视频信息
@property (nonatomic,retain) AVPlayerLayer *hr_ShowLayer;  // 显示
@property (nonatomic,retain) AVPlayer *hr_Player;          // 播放类
@property (nonatomic,retain) HR_VideoShowView *hr_videoView;

@end





@implementation HR_PalyerView{
    
    @private
    BOOL isVideos;                  // 是 一组数据 还是 单个 数据
    BOOL isFullVideo;               // 记录是不是全屏播放 YES : 是全屏。NO：不是
    CGPoint firstPoint;             // 记录 手指移动距离 （第一个点）
    CGPoint moveSingeAdd;           // 记录上一次 点
    
    HR_MOVEDIRECTION isV;           // 横竖移动
    UIImageView *he_MessageView;    // 显示 快进、亮度、 声音 操作提示
    
    UISlider *volumeSlider;         // 音量
}



#pragma mark- ========== INIT ===========
/** Single line comment spreading
 * HenryGao
 * 写点说明。。。。。
 **/
- (instancetype)init{
    self = [super init];
    if (self) {
        [self createVideoView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createVideoView];
    }
    return self;
}
- (void)createVideoView{
    
    if (CGRectIsNull(self.frame)) return;
    _oldFrame = self.frame;                      // 记录当前 Frame
    isV = HR_MOVEDIRECTIONNONE;                  // 未识别
    [self HR_addGesture];                        // 手势 （单击、）
    [self.layer addSublayer:self.hr_ShowLayer];  // 播放层
    [self addSubview:self.hr_videoView];         // 控制层
    
    
    // 提示 View （快进、退 ）
    he_MessageView = [[UIImageView alloc]init];
    he_MessageView.userInteractionEnabled = NO;
    he_MessageView.center = self.center;
    he_MessageView.bounds = CGRectMake(0, 0, 40, 40);
    he_MessageView.hidden = YES;
    [self addSubview:he_MessageView];
    
    
    // 音量
    volumeSlider = [self getSystemVolumSlider];
    volumeSlider.frame = CGRectMake( - 1, - 1, 0.5f, 0.5f);
    volumeSlider.thumbTintColor = [UIColor clearColor];
    [self addSubview:volumeSlider];
    
}





#pragma mark- ========== GET ===========
/** Single line comment spreading
 * HenryGao
 * 写点说明。。。。。
 **/
- (HR_VideoShowView *)hr_videoView{
    if(!_hr_videoView){
        _hr_videoView = [[HR_VideoShowView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
        _hr_videoView.hr_VideoShowViewDelegate = self;
    }
    return _hr_videoView;
}
- (AVPlayerLayer *)hr_ShowLayer{
    if (!_hr_ShowLayer) {
        _hr_ShowLayer = [[AVPlayerLayer alloc]init];
        _hr_ShowLayer.anchorPoint = CGPointMake(0, 0);
        _hr_ShowLayer.bounds = self.bounds;
        _hr_ShowLayer.backgroundColor = [UIColor grayColor].CGColor;
    }
    return _hr_ShowLayer;
}



// Set
- (void)setVideoUrl:(NSURL *)videoUrl{
    
    if (![self HR_isURL:videoUrl]) {  // 加Black 说明 错误
        _hr_PalyResults(@{@"error":@"请检查URL是否正确"});
        return;
    }
    _videoUrl = videoUrl;
    if (_hr_playerItem != nil || _hr_Player != nil) {
        [self dismissObserver];     // 清空 监听
    }
    _hr_UrlAsset = [AVURLAsset assetWithURL:videoUrl];
    _hr_playerItem = [AVPlayerItem playerItemWithAsset:_hr_UrlAsset];
    _hr_Player = [AVPlayer playerWithPlayerItem:_hr_playerItem];
    _hr_ShowLayer.player = _hr_Player;
    [self setOberver];
}

- (void)setVideoUrlArr:(NSArray<NSURL *> *)videoUrlArr{
    
    if(videoUrlArr == nil || videoUrlArr.count == 0) return;
    
    for (NSURL *url in videoUrlArr) {
        if (![self HR_isURL:url]) return;
    }
    //开始
    isVideos = YES;
    
}













#pragma mark- ========== Default ===========
/** Single line comment spreading
 * HenryGao
 * 写点说明。。。。。isVideos、 单击 手势
 **/
- (void)HR_Defalut{
    isVideos = NO;      // 默认 为 NO （单个）
}
- (void)HR_addGesture{  // 添加 手势
    UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(oneClick)];
    oneTap.numberOfTapsRequired     = 1;
    [self addGestureRecognizer:oneTap];
    
}





















#pragma mark- ========== 功能区 ===========
/** Single line comment spreading
 * HenryGao
 * 写点说明。。。。。播放、 暂停 、 下一个 、 
 **/
- (void)HR_Play:(HR_PalyerViewResults)aResult{
    [_hr_Player play];
    aResult(@{@"KEY":@"成功"});
}
- (void)HR_Suspended:(HR_PalyerViewResults)aResult{
    [_hr_Player pause];
    aResult(@{@"KEY":@"成功"});
}
- (void)HR_NextVideo:(HR_PalyerViewResults)aResult{
    
}
- (void)oneClick{   //  显示 隐藏 控制
    _hr_videoView.isHidden ? [_hr_videoView HR_Show] : [_hr_videoView HR_Hidden];
}

- (void)HR_FullPlayerView:(HR_PalyerViewResults)aResult{    //  全屏
    
    // 判断 当前的播放 状态。是不是 全屏
    if(isFullVideo){ // 是全屏 展示 不是全屏
        [self HR_backOldFrame];
        return;
    }
    
    // 记录 Frame
    self.oldFrame = self.frame;
    
    // 判断 视频的信息 长宽 比例 根据 比例 是否让 视频    并 旋转 执行 全屏 操作
    CGSize videoSize = _hr_playerItem.presentationSize;
    
    if (videoSize.width > videoSize.height){    // 宽长的 全屏时-》 横屏显示
        // 隐藏 标题栏
        
        // 旋转 ：重新 设置 Frame：
        [self HR_ChangeFullWidth];
        
        
    }else{
        // 直接改变 frame 为 竖屏 全屏
        [self HR_ChangeFullHeight];
    }
    
    // 改变 记录全屏
    isFullVideo = !isFullVideo;
}
- (void)HR_DissPlayerView:(HR_PalyerViewResults)aResult{    // 停止 播放 并重置 视频状态
    //清空 监听 移除 控件
    
    
}
    


- (void)HR_ChangeFullWidth{
    
    [UIView animateWithDuration:0.5f animations:^{
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    } completion:^(BOOL finished) {
        isFullVideo = YES;
//        for (CALayer *layer in self.layer.sublayers) {
//            NSLog(@"0------------%@",NSStringFromCGRect(layer.frame));
//        }
    }];
}
- (void)HR_ChangeFullHeight{
    [UIView animateWithDuration:0.5f animations:^{
        self.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    } completion:^(BOOL finished) {
        isFullVideo = YES;
//        for (CALayer *layer in self.layer.sublayers) {
//            NSLog(@"0------------%@",NSStringFromCGRect(layer.frame));
//        }
    }];
}
- (void)HR_backOldFrame{    // 返回 yuanframe
    
    [UIView animateWithDuration:0.5f animations:^{
        self.transform = CGAffineTransformIdentity;
        self.frame = self.oldFrame;//CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight(self.bounds));
    } completion:^(BOOL finished) {
        isFullVideo = NO;
    }];
}




#pragma mark- ========== VIEW\ LAYER 位置 ===========
/** Single line comment spreading
 * HenryGao
 * 写点说明。。。。。
 **/
- (void)layoutSubviews{
    [super layoutSubviews];
    _hr_videoView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    he_MessageView.center = _hr_videoView.center;
}
- (void)layoutSublayersOfLayer:(CALayer *)layer{
    [super layoutSublayersOfLayer:layer];
    _hr_ShowLayer.bounds = layer.bounds;
}








#pragma mark- ========== 协议 ===========
/** Single line comment spreading
 * HenryGao
 * 写点说明。。。。。
 **/
- (void)HR_VideoShowViewDelegateAllButton:(UIButton *)aButton{
    
    switch (aButton.tag) {
        case 100:{
            // 判断 是不是 全屏 YES： 返回 原始
            if (isFullVideo){
                [self HR_FullPlayerView:^(NSDictionary *results) {
                    NSLog(@"---------%@",results);
                }];
                return;
            }
            
            [self HR_DissPlayerView:^(NSDictionary *results) {
                NSLog(@"---------%@",results);
            }];
        }
            break;
        case 101:{
            if (aButton.isSelected) {
                [self HR_Play:^(NSDictionary *results) {
                    NSLog(@"---------%@",results);
                }];
            }else{
                [self HR_Suspended:^(NSDictionary *results) {
                    NSLog(@"---------%@",results);
                }];
            }
        }
            break;
        case 102:{
            [self HR_FullPlayerView:^(NSDictionary *results) {
                NSLog(@"---------%@",results);
            }];
        }
            break;
            
        default:
            break;
    }
}



















#pragma mark- ========== 视频 事件状态 ===========
/** Single line comment spreading
 * HenryGao
 * 写点说明。。。。。
 **/
- (void)moviePlayDidEnd:(NSNotification *)aNoF{
    
    [_hr_Player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [_hr_Player play];
    }];
}
- (void)jump:(NSNotification *)aNoF{
    CMTimeShow(_hr_playerItem.currentTime);
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"status"]) {
        
        AVPlayerItemStatus status = AVPlayerItemStatusUnknown;
        NSNumber *statusNumber = change[NSKeyValueChangeNewKey];
        if ([statusNumber isKindOfClass:[NSNumber class]]) {
            status = statusNumber.integerValue;
        }

        switch (status) {  // Switch over the status
            case AVPlayerItemStatusReadyToPlay:{
                CMTimeShow(_hr_playerItem.duration);
                NSString *tempAllTime = [self HR_convertTime:_hr_playerItem.duration]; // 总时间
                _hr_videoView.allTime = tempAllTime;
                _hr_videoView.allProgress = CMTimeGetSeconds(_hr_playerItem.duration);
                [_hr_Player play];
            }
                break;
            case AVPlayerItemStatusFailed:
                // Failed. Examine AVPlayerItem.error
                _hr_PalyResults(@{@"error":_hr_playerItem.error});
                break;
            case AVPlayerItemStatusUnknown:
                // Not ready
                break;
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        
        NSArray *loadedTimeRanges = [_hr_playerItem loadedTimeRanges];
        
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取已缓冲区域
        
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        
        CMTime duration = _hr_playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        
        _hr_videoView.cacheProgress = durationSeconds / totalDuration;
        
//        NSLog(@"------%f======%f-=-=-=-=-=%f========%f",startSeconds,durationSeconds,totalDuration,_hr_videoView.cacheProgress);
        
        
    
    }
    
    
    
}








#pragma mark- ========== 拖动（亮度、进度、声音） ===========
/** Single line comment spreading
 * HenryGao
 * 写点说明。。。。。 实现 控制 视频进度
 **/
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if(touch.view != self) return;
    firstPoint = [touch locationInView:self];
    moveSingeAdd = firstPoint;
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if(touch.view != self) return;
    
    CGPoint endPoint = [touch locationInView:self];
    
    // 判断 移动
    float addMove = 0.f;
    if (isV == HR_MOVEDIRECTIONNONE) {
        float changX = endPoint.x - firstPoint.x;
        float changY = endPoint.y - firstPoint.y;
        
//        NSLog(@"-------%hhu=======%hhu",(UInt8)changX,(UInt8)changY);
        float tempX = changX > 0 ? changX : -changX;
        float tempY = changY > 0 ? changY : -changY;
        
        isV = tempX > tempY  ? HR_MOVEDIRECTIONH: HR_MOVEDIRECTIONV;
        
    }else if (isV == HR_MOVEDIRECTIONH){
        addMove = endPoint.x - moveSingeAdd.x;
        [_hr_Player pause];
        he_MessageView.image = [UIImage imageNamed:endPoint.x - firstPoint.x > 0 ? @"qq" : @"dd"];
        he_MessageView.hidden = NO;
        [self changeVideoBrightnessAndVolumeAndProgressMoveDistance:endPoint.x - firstPoint.x singleAdd:addMove];     // 传递单次移动距离
    }else if(isV == HR_MOVEDIRECTIONV){
       addMove = endPoint.y - moveSingeAdd.y;
        [self changeVideoBrightnessAndVolumeAndProgressMoveDistance:endPoint.y - firstPoint.y singleAdd:addMove];     // 传递单次移动距离
    }
    
    
    
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (isV == HR_MOVEDIRECTIONH) {
        UITouch *touch = [touches anyObject];
        CGPoint endPoint = [touch locationInView:self];
        CMTimeShow(_hr_playerItem.currentTime);
        [_hr_Player seekToTime:CMTimeAdd(_hr_playerItem.currentTime,CMTimeMakeWithSeconds((endPoint.x - firstPoint.x)/4, 1)) completionHandler:^(BOOL finished) {
            //在这里处理进度设置成功后的事情
            CMTimeShow(_hr_playerItem.currentTime);
            [_hr_Player play];
        }];
    }
    
    he_MessageView.hidden = YES;
    isV = HR_MOVEDIRECTIONNONE;
}
- (void)changeVideoBrightnessAndVolumeAndProgressMoveDistance:(float)aDistance singleAdd:(float)aSingle{
    if (isV == HR_MOVEDIRECTIONH) {     // 横屏
        
    }else{
        
        he_MessageView.image = [UIImage imageNamed:(firstPoint.x > THISWIDTH / 2) ? @"vv" : @"ll"];
        he_MessageView.hidden = NO;
        if (firstPoint.x > THISWIDTH / 2) {  // 右边 屏幕。音量
            volumeSlider.value = volumeSlider.value - aSingle / 8000;
        }else{  // 亮度
            [UIScreen mainScreen].brightness = [UIScreen mainScreen].brightness -  aSingle / 1000;
        }
        
    }
}













#pragma mark- ========== 工具转换 验证 URL ===========
/** Single line comment spreading
 * HenryGao
 * 写点说明。。。。。验证 URL 格式化时间 获取音量组件
 **/
- (BOOL)HR_isURL:(NSURL *)aURL{
    
    NSString *tempStr = [NSString stringWithFormat:@"%@",aURL];
    
    NSString *str = @"^((https|http|ftp|rtsp|mms)?:\\/\\/)[^\\s]+";
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    
    return [regextestct evaluateWithObject:tempStr];
}
- (NSString *)HR_convertTime:(CMTime )aTime{ // 时间转换
    CGFloat totalSecond = aTime.value / aTime.timescale;// 转换成秒
    totalSecond = CMTimeGetSeconds(aTime);   // 获取 精准秒
    
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:totalSecond];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (totalSecond/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}
- (UISlider*)getSystemVolumSlider{
    static UISlider * volumeViewSlider = nil;
    if (volumeViewSlider == nil) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(10, 50, 200, 4)];
        for (UIView* newView in volumeView.subviews) {
            if ([newView.class.description isEqualToString:@"MPVolumeSlider"]){
                volumeViewSlider = (UISlider*)newView;
                break;
            }
        }
    }
    
    return volumeViewSlider;
}







#pragma mark 移除监听
- (void)dismissObserver{
    if (_hr_playerItem) {
        [_hr_playerItem removeObserver:self forKeyPath:@"status"];
        [_hr_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    }
    if (_hr_Player){
        [_hr_Player removeTimeObserver:self];
    }
    
}
- (void)setOberver{
    
    // 结束监听 ----  Items
    [_hr_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_hr_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    // 控制 播放进度  ------ Palyer
    __block typeof(HR_PalyerView) *aa = self;
    [_hr_Player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        NSString *tempcurrTime = [aa HR_convertTime:time]; // 当前时间
        aa.hr_videoView.nowTime = tempcurrTime;
        aa.hr_videoView.playProgress = CMTimeGetSeconds(time);
    }];
    
    
}






@end
