//
//  ChatView.m
//  ChatUI
//
//  Created by lufly on 11/03/2017.
//  Copyright © 2017 lufly. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "ChatView.h"
#import "ChatButton.h"

NSString *const kHangUpNotification = @"kHangUpNotification";

NSString *const kAcceptNotification = @"kAcceptNotification";

NSString *const kSwitchCameraNotification = @"kSwitchCameraNotification";

NSString *const kMuteNotification = @"kMuteNotification";

NSString *const kVideoCaptureNotification = @"kVideoCaptureNotification";

#define WIN_WIDTH       [UIScreen mainScreen].bounds.size.width
#define WIN_HEIGHT      [UIScreen mainScreen].bounds.size.height
#define WIN_RATE        (WIN_WIDTH / 320.0)

//底部容器的高度
#define kContainerH     (162 * WIN_RATE) 
//每个按钮的宽度
#define kBtnW           (60 * WIN_RATE)
//视频聊天时，小窗口的宽
#define kMicVideoW      (80 * WIN_RATE)
//视频聊天时，小窗口的高
#define kMicVideoH      (120 * WIN_RATE)

@interface ChatView()

@property (nonatomic, assign)   BOOL                isVideo;
@property (nonatomic, assign)   BOOL                caller;
@property (nonatomic, assign)   BOOL                localCamera;
@property (nonatomic, assign)   BOOL                loundSpeaker;

/** 语音聊天背景视图 */
@property (strong, nonatomic)   UIImageView             *bgImageView;
/** 自己的视频画面 */
@property (strong, nonatomic)   UIImageView             *ownImageView;
/** 对方的视频画面 */
@property (strong, nonatomic)   UIImageView             *adverseImageView;
/** 头像 */
@property (strong, nonatomic)   UIImageView             *portraitImageView;
/** 昵称 */
@property (strong, nonatomic)   UILabel                 *nickNameLabel;
/** 连接状态，如等待对方接听...、对方已拒绝、语音电话、视频电话 */
@property (strong, nonatomic)   UILabel                 *connectLabel;
/** 网络状态提示，如对方网络良好、网络不稳定等 */
@property (strong, nonatomic)   UILabel                 *netTipLabel;
/** 前置、后置摄像头切换按钮 */
@property (strong, nonatomic)   ChatButton               *swichBtn;
/** 底部按钮容器视图 */
@property (strong, nonatomic)   UIView                  *btnContainerView;
/** 静音按钮 */
@property (strong, nonatomic)   ChatButton               *muteBtn;
/** 摄像头按钮 */
@property (strong, nonatomic)   ChatButton               *cameraBtn;
/** 扬声器按钮 */
@property (strong, nonatomic)   ChatButton               *loudspeakerBtn;
/** 邀请成员按钮 */
@property (strong, nonatomic)   ChatButton               *inviteBtn;
/** 消息回复按钮 */
@property (strong, nonatomic)   UIButton                *msgReplyBtn;
/** 收到视频通话时，语音接听按钮 */
@property (strong, nonatomic)   ChatButton               *voiceAnswerBtn;
/** 挂断按钮 */
@property (strong, nonatomic)   ChatButton               *hangupBtn;
/** 接听按钮 */
@property (strong, nonatomic)   ChatButton               *answerBtn;
/** 收起按钮 */
@property (strong, nonatomic)   ChatButton               *packupBtn;
/** 视频通话缩小后的按钮 */
@property (strong, nonatomic)   UIButton                *videoMicroBtn;
/** 音频通话缩小后的按钮 */
@property (strong, nonatomic)   ChatButton               *microBtn;
/** 遮罩视图 */
@property (strong, nonatomic)   UIView                  *coverView;
/** 动画用的layer */
@property (strong, nonatomic)   CAShapeLayer            *shapeLayer;

@end

@implementation ChatView

- (instancetype)initWithIsVideo:(BOOL)isVideo isCalled:(BOOL)isCalled{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    
    if (self) {
        self.isVideo = isVideo;
        self.caller = isCalled;
        self.isHanged = YES;
        self.clipsToBounds = YES;
        
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI{
    self.adverseImageView.backgroundColor = [UIColor darkGrayColor];
    self.ownImageView.backgroundColor = [UIColor grayColor];
    self.portraitImageView.backgroundColor = [UIColor clearColor];
    
    if (self.isVideo && !self.caller) {
        //视频通话时，呼叫方的UI
        [self initUIForVideoCaller];
        
        [self performSelector:@selector(connected) withObject:nil afterDelay:3.0];
        _answered = YES;
        _oppositeCamera = YES;
        _localCamera = YES;
    }
    else if (!self.isVideo && !self.caller)
    {
        // 语音通话时，呼叫方UI初始化
        [self initUIForAudioCaller];
        
        [self performSelector:@selector(connected) withObject:nil afterDelay:3.0];
        _answered = YES;
        _oppositeCamera = NO;
        _localCamera = NO;
    }
    else if (!self.isVideo && self.caller)
    {
        // 语音通话时，被叫方UI初始化
        [self initUIForAudioCallee];
    } else {
        // 视频通话时，被呼叫方UI初始化
        [self initUIForVideoCallee];
        
    }
}

/**
 视频通话呼叫方UI
 */
- (void)initUIForVideoCaller{
    self.adverseImageView.frame = self.frame;
    [self addSubview:_adverseImageView];
    
    self.ownImageView.frame = self.frame;
    [self addSubview:_ownImageView];
    
    CGFloat switchBtnW = 45 * WIN_RATE;
    CGFloat topOffset = 30 * WIN_RATE;
    self.swichBtn.frame = CGRectMake(WIN_WIDTH - switchBtnW - 10, topOffset, switchBtnW, switchBtnW);
    [self addSubview:_swichBtn];
    
    self.nickNameLabel.frame = CGRectMake(20, topOffset, WIN_WIDTH - 20 * 3 - switchBtnW, 30);
    self.nickNameLabel.textColor = [UIColor whiteColor];
    self.nickNameLabel.textAlignment = NSTextAlignmentLeft;
    self.nickNameLabel.text = self.nickName ? :@"空白";
    [self addSubview:_nickNameLabel];
    
    self.connectLabel.frame = CGRectMake(20, CGRectGetMaxY(self.nickNameLabel.frame), CGRectGetWidth(self.nickNameLabel.frame), 20);
    self.connectLabel.textColor = [UIColor whiteColor];
    self.connectLabel.textAlignment = NSTextAlignmentLeft;
    self.connectLabel.text = self.connectText;
    [self addSubview:_connectLabel];
    
    self.btnContainerView.frame = CGRectMake(0, WIN_HEIGHT - kContainerH, WIN_WIDTH, kContainerH);
    self.btnContainerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self addSubview:_btnContainerView];
    
    [self initUIForBottomBtns];
    self.cameraBtn.enabled = NO;
    self.inviteBtn.enabled = NO;
    
    self.coverView.frame = self.frame;
    self.coverView.hidden = YES;
    [self addSubview:_coverView];
    
}

- (void)initUIForVideoCallee
{
    [self initUIForTopCommonViews];
    
    CGFloat btnW = kBtnW;
    CGFloat btnH = btnW + 20;
    CGFloat paddingX = (WIN_WIDTH - btnW * 2) / 3;
    self.hangupBtn.frame = CGRectMake(paddingX, kContainerH - btnH - 5, btnW, btnH);
    [self.btnContainerView addSubview:_hangupBtn];
    
    self.answerBtn.frame = CGRectMake(paddingX * 2 + btnW, kContainerH - btnH - 5, btnW, btnH);
    [self.btnContainerView addSubview:_answerBtn];
    
    self.msgReplyBtn.frame = CGRectMake(paddingX, 5, btnW, btnH);
    [self.btnContainerView addSubview:_msgReplyBtn];
    
    self.voiceAnswerBtn.frame = CGRectMake(paddingX * 2 + btnW, 5, btnW, btnH);
    [self.btnContainerView addSubview:_voiceAnswerBtn];
    
    self.coverView.frame = self.frame;
    self.coverView.hidden = YES;
    [self addSubview:_coverView];
    
}

/**
 语音通话呼叫方UI
 */
- (void)initUIForAudioCaller
{
    // 上面 通用部分
    [self initUIForTopCommonViews];
    
    // 下面底部 6按钮视图
    [self initUIForBottomBtns];
    
    self.cameraBtn.enabled = NO;
    self.inviteBtn.enabled = NO;
    
    self.coverView.frame = self.frame;
    self.coverView.hidden = YES;
    [self addSubview:_coverView];
 
}

- (void)initUIForAudioCallee
{
    [self initUIForTopCommonViews];
    
    CGFloat btnW = kBtnW;
    CGFloat btnH = kBtnW + 20;
    CGFloat paddingX = (WIN_WIDTH - btnW * 2) / 3;
    
    self.hangupBtn.frame = CGRectMake(paddingX, kContainerH - btnH - 5, btnW, btnH);
    [self.btnContainerView addSubview:_hangupBtn];
    
    self.answerBtn.frame = CGRectMake(paddingX * 2 + btnW, kContainerH - btnH - 5, btnW, btnH);
    [self.btnContainerView addSubview:_answerBtn];
    
    CGFloat replyW = 110 * WIN_RATE;
    CGFloat replyH = 45 * WIN_RATE;
    
    CGFloat centerX = self.center.x;
    self.msgReplyBtn.frame = CGRectMake(centerX - replyW * 0.5, 20, replyW, replyH);
    [self.btnContainerView addSubview:_msgReplyBtn];
    
    self.coverView.frame = self.frame;
    self.coverView.hidden = YES;
    [self addSubview:_coverView];
}

/**
 顶部通用部分
 */
- (void)initUIForTopCommonViews
{
    CGFloat centerX = self.center.x;
    
    self.bgImageView.frame = self.frame;
    [self addSubview:_bgImageView];
    
    CGFloat portraitW = 130 * WIN_RATE;
    self.portraitImageView.frame = CGRectMake(0, 0, portraitW, portraitW);
    self.portraitImageView.center = CGPointMake(centerX, portraitW);
    self.portraitImageView.layer.cornerRadius = portraitW * 0.5;
    self.portraitImageView.layer.masksToBounds = YES;
    [self addSubview:_portraitImageView];
    
    self.nickNameLabel.frame = CGRectMake(0, 0, WIN_WIDTH, 30);
    self.nickNameLabel.center = CGPointMake(centerX, CGRectGetMaxY(self.portraitImageView.frame) + 40);
    self.nickNameLabel.text = self.nickName ? :@"空白";
    [self addSubview:_nickNameLabel];
    
    self.connectLabel.frame = CGRectMake(0, 0, WIN_WIDTH, 30);
    self.connectLabel.center = CGPointMake(centerX, CGRectGetMaxY(self.nickNameLabel.frame) + 10);
    self.connectLabel.text = self.connectText;
    [self addSubview:_connectLabel];
    
    self.netTipLabel.frame = CGRectMake(0, 0, WIN_WIDTH, 30);
    self.netTipLabel.center = CGPointMake(centerX,CGRectGetMaxY(self.connectLabel.frame) + 40);
    [self addSubview:_netTipLabel];
    
    self.btnContainerView.frame = CGRectMake(0, WIN_HEIGHT - kContainerH, WIN_WIDTH, kContainerH);
    [self addSubview:_btnContainerView];
}

/**
 添加底部6个按钮
 */
- (void)initUIForBottomBtns
{
    CGFloat btnW = kBtnW;
    CGFloat paddingX = (self.frame.size.width - btnW * 3) / 4;
    CGFloat paddingY = (kContainerH - btnW * 2) / 3;
    
    self.muteBtn.frame = CGRectMake(paddingX, paddingY, btnW, btnW);
    [self.btnContainerView addSubview:_muteBtn];
    
    self.cameraBtn.frame = CGRectMake(paddingX * 2 + btnW, paddingY, btnW, btnW);
    [self.btnContainerView addSubview:_cameraBtn];
    
    self.loudspeakerBtn.frame = CGRectMake(paddingX * 3 + btnW * 2, paddingY, btnW, btnW);
    self.loudspeakerBtn.selected = self.loundSpeaker;
    [self.btnContainerView addSubview:_loudspeakerBtn];
    
    self.inviteBtn.frame = CGRectMake(paddingX, paddingY * 2 + btnW, btnW, btnW);
    [self.btnContainerView addSubview:_inviteBtn];
    
    self.hangupBtn.frame = CGRectMake(paddingX * 2 + btnW, paddingY * 2 + btnW, btnW, btnW);
    [self.btnContainerView addSubview:_hangupBtn];
    
    self.packupBtn.frame = CGRectMake(paddingX * 3 + btnW * 2, paddingY * 2 + btnW, btnW, btnW);
    [self.btnContainerView addSubview:_packupBtn];
}

- (void)show
{
    if (self.isVideo && self.caller) {
        self.connectLabel.text = @"视频通话";
    }else if (!self.isVideo && self.caller){
        self.connectLabel.text = @"语音通话";
    }
    
    _portraitImageView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_portraitImageView.frame));
    _nickNameLabel.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_nickNameLabel.frame));
    _connectLabel.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_connectLabel.frame));
    _swichBtn.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_swichBtn.frame));
    _btnContainerView.transform = CGAffineTransformMakeTranslation(0, kContainerH);
    
    self.alpha = 0;
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 animations:^{
            _portraitImageView.transform = CGAffineTransformIdentity;
            _nickNameLabel.transform = CGAffineTransformIdentity;
            _connectLabel.transform = CGAffineTransformIdentity;
            _swichBtn.transform = CGAffineTransformIdentity;
            _btnContainerView.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:1.0 animations:^{
        _portraitImageView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_portraitImageView.frame));
        _nickNameLabel.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_nickNameLabel.frame));
        _connectLabel.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_connectLabel.frame));
        _swichBtn.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_swichBtn.frame));
        _btnContainerView.transform = CGAffineTransformMakeTranslation(0, kContainerH);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)connected
{
    if (self.isVideo) {
       // 视频通话时，对方接听以后
        self.cameraBtn.enabled = YES;
        self.loudspeakerBtn.enabled = YES;
        self.cameraBtn.selected = YES;
        self.inviteBtn.enabled = YES;
        [UIView animateWithDuration:0.5 animations:^{
            self.ownImageView.frame = CGRectMake(WIN_WIDTH - kMicVideoW - 5, WIN_HEIGHT - kContainerH - kMicVideoH - 5, kMicVideoW, kMicVideoH);
        } completion:nil];
    } else {
        self.cameraBtn.enabled = YES;
        self.inviteBtn.enabled = YES;
        self.btnContainerView.alpha = 1.0;
    }
}

- (void)clearAllSubViews
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _bgImageView = nil;
    _nickNameLabel = nil;
    _connectLabel = nil;
    _netTipLabel = nil;
    _swichBtn = nil;
    
    [self clearBottomViews];
    
    _coverView = nil;
}

- (void)clearBottomViews
{
    _btnContainerView = nil;
    _muteBtn = nil;
    _cameraBtn = nil;
    _loudspeakerBtn = nil;
    _inviteBtn = nil;
    _hangupBtn = nil;
    _packupBtn = nil;
    _msgReplyBtn = nil;
    _voiceAnswerBtn = nil;
    _answerBtn = nil;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
    [self clearAllSubViews];
}

#pragma mark - 按钮点击事件
- (void)switchClick
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSwitchCameraNotification object:nil];
}

- (void)muteClick
{
    NSLog(@"静音%s", __func__);
    if (!self.muteBtn.selected) {
        self.muteBtn.selected = YES;
    }else{
        self.muteBtn.selected = NO;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMuteNotification object:nil];
}

- (void)cameraClick
{
    self.localCamera = !self.localCamera;
    if (self.localCamera) {
        self.isVideo = YES;
        [self clearAllSubViews];
        [self initUIForVideoCaller];
        // 在这里添加 开启本地视频采集 的代码
        [[NSNotificationCenter defaultCenter] postNotificationName:kVideoCaptureNotification object:@{@"videoCpture":@(YES)}];
        // 对方和本地都开了摄像头
        if (self.oppositeCamera) {
            self.ownImageView.frame = CGRectMake(WIN_WIDTH - kMicVideoW - 5, WIN_HEIGHT - kContainerH - kMicVideoH - 5, kMicVideoW, kMicVideoH);
            [self addSubview:self.ownImageView];
            self.cameraBtn.enabled = YES;
            self.inviteBtn.enabled = YES;
            self.cameraBtn.selected = YES;
        } else {
            //本地开启， 对方未开启
            [self.adverseImageView removeFromSuperview];
            self.cameraBtn.enabled = YES;
            self.inviteBtn.enabled = YES;
            self.cameraBtn.selected = YES;
        }
    } else {
        // 在这里添加 关闭本地视频采集 的代码
        [[NSNotificationCenter defaultCenter] postNotificationName:kVideoCaptureNotification object:@{@"videoCpture":@(NO)}];
        if (self.oppositeCamera) {
            //本地未开，对方开启摄像头
            [self clearAllSubViews];
            
            [self initUIForVideoCaller];
            [self.ownImageView removeFromSuperview];
            self.cameraBtn.enabled = YES;
            self.inviteBtn.enabled = YES;
        } else {
           //本地，对方都未开启
            self.isVideo = NO;
            [self clearAllSubViews];
            [self initUIForAudioCaller];
            [self connected];
        }

    }
}

- (void)loudspeakerClick
{
    NSLog(@"外放声音%s", __func__);
    if (!self.loudspeakerBtn.selected) {
        self.loudspeakerBtn.selected = YES;
        self.loundSpeaker = YES;
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }else{
        self.loudspeakerBtn.selected = NO;
        self.loundSpeaker = NO;
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }
}

- (void)hangupClick
{
    if (self.isHanged) {
        self.coverView.hidden = NO;
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:2.0];
    }else{
        [self dismiss];
    }
    NSDictionary *dict = @{@"isVideo":@(self.caller), @"isCaller":@(!self.caller), @"answered":@(self.answered)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kHangUpNotification object:dict];
}

- (void)inviteClick
{
    NSLog(@"邀请成员%s", __func__);
    
}

- (void)packupClick
{
    if (!self.isVideo) {
        // 1.获取动画结束时的圆形
        UIBezierPath *endPath = [UIBezierPath bezierPathWithOvalInRect:self.portraitImageView.frame];
        
        // 2.获取动画开始时的圆形
        CGSize startSize = CGSizeMake(self.frame.size.width * 0.5, self.frame.size.height - self.portraitImageView.center.y);
        CGFloat radius = sqrt(startSize.width * startSize.width + startSize.height * startSize.height);
        CGRect startRect = CGRectInset(self.portraitImageView.frame, -radius, -radius);
        
        UIBezierPath *startPath = [UIBezierPath bezierPathWithOvalInRect:startRect];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = endPath.CGPath;
        self.layer.mask = shapeLayer;
        self.shapeLayer = shapeLayer;
        
        //添加动画
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation.fromValue = (id)startPath.CGPath;
        pathAnimation.toValue = (id)endPath.CGPath;
        pathAnimation.duration = 0.5;
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pathAnimation.delegate = self;
        pathAnimation.removedOnCompletion = NO;
        pathAnimation.fillMode = kCAFillModeForwards;
        
        [shapeLayer addAnimation:pathAnimation forKey:@"packupAnimation"];
        
    } else {
        //视频通话收起动画
        _nickNameLabel.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_nickNameLabel.frame));
        _connectLabel.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_connectLabel.frame));
        _swichBtn.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_swichBtn.frame));
        _btnContainerView.transform = CGAffineTransformMakeTranslation(0, kContainerH);
        
        if (self.answered) {
            [UIView animateWithDuration:1.0 animations:^{
                self.frame = CGRectMake(WIN_WIDTH - kMicVideoW - 10, 74, kMicVideoW, kMicVideoH);
                if (self.oppositeCamera && self.localCamera) {
                    _ownImageView.hidden = YES;
                    self.adverseImageView.frame = CGRectMake(0, 0, kMicVideoW, kMicVideoH);
                }
                else if (!self.oppositeCamera && self.localCamera)
                {
                    self.ownImageView.frame = CGRectMake(0, 0, kMicVideoW, kMicVideoH);
                }
                else
                {
                    self.adverseImageView.frame = CGRectMake(0, 0, kMicVideoW, kMicVideoH);
                }
            } completion:^(BOOL finished) {
                self.videoMicroBtn.frame = self.adverseImageView.frame;
                [self addSubview:_videoMicroBtn];
            }];
        } else
        {
            [UIView animateWithDuration:1.0 animations:^{
                self.frame = CGRectMake(WIN_WIDTH - kMicVideoW - 10, 74, kMicVideoW, kMicVideoH);
                self.ownImageView.frame = CGRectMake(0, 0, kMicVideoW, kMicVideoH);
            } completion:^(BOOL finished) {
                self.videoMicroBtn.frame = self.ownImageView.frame;
                [self addSubview:_videoMicroBtn];
            }];
        }
        
    }
}

- (void)msgReplyClick
{
    NSLog(@"%s", __func__);
    
    NSArray *messages = @[@"现在不方便接听", @"马上到"];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    
    for (NSString *message in messages) {
        [sheet addButtonWithTitle:message];
    }
    
    [sheet showInView:self];
    
}

- (void)answerClick
{
    self.answered = YES;
    NSDictionary *dict = nil;
    if (self.isVideo) {
        _localCamera = YES;
        _oppositeCamera = YES;
        
        [self clearAllSubViews];
        
        //视频通话接听之后，UI布局与呼叫方一样
        [self initUIForVideoCaller];
        // 执行一个小动画
        [self connected];
        dict = @{@"isVideo":@(YES), @"audioAccpet":@(NO)};
    } else {
        _localCamera = NO;
        _oppositeCamera = NO;
        
        [UIView animateWithDuration:1.0 animations:^{
            self.btnContainerView.alpha = 0;
        } completion:^(BOOL finished) {
            [self clearAllSubViews];
            
            [self initUIForAudioCaller];
            self.connectLabel.text = @"正在通话中...";
            [self connected];
        }];
        dict = @{@"isVideo":@(NO), @"audioAccpet":@(YES)};
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kAcceptNotification object:nil];
    
}

//视频通话时的语音接听按钮
- (void)voiceAnswerClick
{
    self.answered = YES;
    self.isVideo = YES;
    _localCamera = NO;
    _oppositeCamera = YES;
    
    [self clearAllSubViews];
    [self initUIForVideoCaller];
    
    [self.ownImageView removeFromSuperview];
    self.cameraBtn.enabled = YES;
    self.inviteBtn.enabled = YES;
    
    NSDictionary *dict = @{@"isVideo":@(YES), @"audioAccept":@(YES)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kAcceptNotification object:dict];
}

// 语音通话，缩小后的按钮点击事件
- (void)microClick
{
    [self.microBtn removeFromSuperview];
    self.microBtn = nil;
    
    [UIView animateWithDuration:1.0 animations:^{
        self.center = self.portraitImageView.center;
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.bounds = [UIScreen mainScreen].bounds;
        self.frame = self.bounds;
        
        CAShapeLayer *shapeLayer = self.shapeLayer;
        
        UIBezierPath *startPath = [UIBezierPath bezierPathWithOvalInRect:self.portraitImageView.frame];
        
        CGSize endSize = CGSizeMake(self.frame.size.width * 0.5, self.frame.size.height - self.portraitImageView.center.y);
        CGFloat radius = sqrt(endSize.width * endSize.width + endSize.height * endSize.height);
        CGRect endRect = CGRectInset(self.portraitImageView.frame, -radius, -radius);
        UIBezierPath *endPath = [UIBezierPath bezierPathWithOvalInRect:endRect];
        
        shapeLayer.path = endPath.CGPath;
        
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation.fromValue = (id)startPath.CGPath;
        pathAnimation.toValue = (id)endPath.CGPath;
        pathAnimation.duration = 0.5;
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pathAnimation.delegate = self;
        pathAnimation.removedOnCompletion = NO;
        pathAnimation.fillMode = kCAFillModeForwards;
        
        [shapeLayer addAnimation:pathAnimation forKey:@"showAnimation"];
    }];
}

- (void)videoMicroClick
{
    [self.videoMicroBtn removeFromSuperview];
    _ownImageView.hidden = NO;
 
    if (self.answered) {
        [UIView animateWithDuration:1.0 animations:^{
            self.frame = [UIScreen mainScreen].bounds;
            if (!self.oppositeCamera && self.localCamera) {
                self.ownImageView.frame = [UIScreen mainScreen].bounds;
            }else{
                self.adverseImageView.frame  = [UIScreen mainScreen].bounds;
            }
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1.0 animations:^{
                self.nickNameLabel.transform = CGAffineTransformIdentity;
                self.connectLabel.transform = CGAffineTransformIdentity;
                self.swichBtn.transform = CGAffineTransformIdentity;
                self.btnContainerView.transform = CGAffineTransformIdentity;
            }];
        }];
    } else {
        [UIView animateWithDuration:1.0 animations:^{
            self.frame = [UIScreen mainScreen].bounds;
            self.ownImageView.frame = [UIScreen mainScreen].bounds;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1.0 animations:^{
                self.nickNameLabel.transform = CGAffineTransformIdentity;
                self.connectLabel.transform = CGAffineTransformIdentity;
                self.swichBtn.transform = CGAffineTransformIdentity;
                self.btnContainerView.transform = CGAffineTransformIdentity;
            }];
        }];
    }
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([anim isEqual:[self.shapeLayer animationForKey:@"packupAnimation"]]) {
        CGRect rect = self.frame;
        rect.origin = self.portraitImageView.frame.origin;
        self.bounds = rect;
        rect.size = self.portraitImageView.frame.size;
        self.frame = rect;
        
        [UIView animateWithDuration:1.0 animations:^{
            self.center = CGPointMake(WIN_WIDTH - 60, WIN_HEIGHT - 60);
            self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        } completion:^(BOOL finished) {
            self.microBtn.frame = self.frame;
            self.microBtn.layer.cornerRadius = self.microBtn.frame.size.width * 0.5;
            self.microBtn.layer.masksToBounds = YES;
            [self.superview addSubview:_microBtn];
        }];
    } else if ([anim isEqual:[self.shapeLayer animationForKey:@"showAnimation"]])
    {
        self.layer.mask = nil;
        self.shapeLayer = nil;
    }
}

#pragma mark - 懒加载
- (UIImageView *)bgImageView
{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"im_skin_icon_audiocall_bg.jpg"]];
    }
    
    return _bgImageView;
}

- (UIImageView *)adverseImageView
{
    if (!_adverseImageView) {
        _adverseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"456.png"]];
    }
    
    return _adverseImageView;
}

- (UIImageView *)ownImageView
{
    if (!_ownImageView) {
        _ownImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"123.png"]];
    }
    
    return _ownImageView;
}

- (UIImageView *)portraitImageView
{
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"portrait.jpg"]];
    }
    
    return _portraitImageView;
}

- (UILabel*)nickNameLabel
{
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.text = @"飞翔的昵称";
        _nickNameLabel.font = [UIFont systemFontOfSize:17.0f];
        _nickNameLabel.textColor = [UIColor darkGrayColor];
        _nickNameLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _nickNameLabel;
}

- (UILabel*)connectLabel
{
    if (!_connectLabel) {
        _connectLabel = [[UILabel alloc] init];
        _connectLabel.text = @"等待对方接听...";
        _connectLabel.font = [UIFont systemFontOfSize:15.0f];
        _connectLabel.textColor = [UIColor grayColor];
        _connectLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _connectLabel;
}

- (ChatButton *)swichBtn
{
    if (!_swichBtn) {
        _swichBtn = [[ChatButton alloc] initWithTitle:nil noHandleImageName:@"icon_avp_camera_white"];
        [_swichBtn addTarget:self action:@selector(switchClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _swichBtn;
}

- (UILabel*)netTipLabel
{
    if (!_netTipLabel) {
        _netTipLabel = [[UILabel alloc] init];
        _netTipLabel.text = @"对方网络良好";
        _netTipLabel.font = [UIFont systemFontOfSize:13.0f];
        _netTipLabel.textColor = [UIColor grayColor];
        _netTipLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _netTipLabel;
}

- (UIView *)btnContainerView
{
    if (!_btnContainerView) {
        _btnContainerView = [[UIView alloc] init];
    }
    return _btnContainerView;
}

- (ChatButton *)muteBtn
{
    if (!_muteBtn) {
        _muteBtn = [[ChatButton alloc] initWithTitle:@"静音" imageName:@"icon_avp_mute" isVideo:_isVideo];
        [_muteBtn addTarget:self action:@selector(muteClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _muteBtn;
}

- (ChatButton *)cameraBtn
{
    if (!_cameraBtn) {
        _cameraBtn = [[ChatButton alloc] initWithTitle:@"摄像头" imageName:@"icon_avp_video" isVideo:_isVideo];
        [_cameraBtn addTarget:self action:@selector(cameraClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cameraBtn;
}

- (ChatButton *)loudspeakerBtn
{
    if (!_loudspeakerBtn) {
        _loudspeakerBtn = [[ChatButton alloc] initWithTitle:@"扬声器" imageName:@"icon_avp_loudspeaker" isVideo:_isVideo];
        [_loudspeakerBtn addTarget:self action:@selector(loudspeakerClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _loudspeakerBtn;
}

- (ChatButton *)inviteBtn
{
    if (!_inviteBtn) {
        _inviteBtn = [[ChatButton alloc] initWithTitle:@"邀请成员" imageName:@"icon_avp_invite" isVideo:_isVideo];
        [_inviteBtn addTarget:self action:@selector(inviteClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _inviteBtn;
}

- (ChatButton *)hangupBtn
{
    if (!_hangupBtn) {
        if (_caller && !_answered) {
            _hangupBtn = [[ChatButton alloc] initWithTitle:@"拒绝"  noHandleImageName:@"icon_call_reject_normal"];
        } else {
            _hangupBtn = [[ChatButton alloc] initWithTitle:nil noHandleImageName:@"icon_call_reject_normal"];
        }
        
        [_hangupBtn addTarget:self action:@selector(hangupClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hangupBtn;
}

- (ChatButton *)packupBtn
{
    if (!_packupBtn) {
        _packupBtn = [[ChatButton alloc] initWithTitle:@"收起" imageName:@"icon_avp_reduce" isVideo:_isVideo];
        [_packupBtn addTarget:self action:@selector(packupClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _packupBtn;
}

- (UIButton *)msgReplyBtn
{
    if (!_msgReplyBtn) {
        if (self.isVideo) {
            _msgReplyBtn = [[ChatButton alloc] initWithTitle:@"消息回复" noHandleImageName:@"icon_av_reply_message_normal"];
        } else {
            _msgReplyBtn = [[UIButton alloc] init];
            [_msgReplyBtn setTitle:@"消息回复" forState:UIControlStateNormal];
            _msgReplyBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
            [_msgReplyBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [_msgReplyBtn setImage:[UIImage imageNamed:@"icon_av_reply_message_normal"] forState:UIControlStateNormal];
            [_msgReplyBtn setBackgroundImage:[UIImage imageNamed:@"view_audio_reply_message_bg"] forState:UIControlStateNormal];
        }
        
        [_msgReplyBtn addTarget:self action:@selector(msgReplyClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _msgReplyBtn;
}

- (ChatButton *)voiceAnswerBtn
{
    if (!_voiceAnswerBtn) {
        _voiceAnswerBtn = [[ChatButton alloc] initWithTitle:@"语音接听" noHandleImageName:@"icon_av_audio_receive_normal"];
        [_voiceAnswerBtn addTarget:self action:@selector(voiceAnswerClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceAnswerBtn;
}

- (ChatButton *)answerBtn
{
    if (!_answerBtn) {
        _answerBtn = [[ChatButton alloc] initWithTitle:@"接听" noHandleImageName:@"icon_audio_receive_normal"];
        [_answerBtn addTarget:self action:@selector(answerClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _answerBtn;
}

- (ChatButton *)microBtn
{
    if (!_microBtn) {
        _microBtn = [[ChatButton alloc] initWithTitle:@"等待中" noHandleImageName:@"icon_av_audio_micro_normal"];
        [_microBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _microBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _microBtn.backgroundColor = [UIColor orangeColor];
        [_microBtn addTarget:self action:@selector(microClick) forControlEvents:UIControlEventTouchUpInside];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [_microBtn addGestureRecognizer:pan];
    }
    
    return _microBtn;
}

- (UIButton *)videoMicroBtn
{
    if (!_videoMicroBtn) {
        _videoMicroBtn = [[UIButton alloc] init];
        [_videoMicroBtn addTarget:self action:@selector(videoMicroClick) forControlEvents:UIControlEventTouchDown];
        [_videoMicroBtn addTarget:self action:@selector(dragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];

    }
    
    return _videoMicroBtn;
}

- (UIView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    
    return _coverView;
}

#pragma mark - property setter
- (void)setNickName:(NSString *)nickName
{
    _nickName = nickName;
    self.nickNameLabel.text = _nickName;
}

- (void)setConnectText:(NSString *)connectText
{
    _connectText = connectText;
    self.connectLabel.text = _connectText;
    
    [self.microBtn setTitle:connectText forState:UIControlStateNormal];
}

- (void)setNetTipText:(NSString *)netTipText
{
    _netTipText = netTipText;
    self.netTipLabel.text = _netTipText;
}

- (void)setAnswered:(BOOL)answered
{
    _answered = answered;
    if (!self.caller) {
        [self connected];
    }
}

- (void)setOppositeCamera:(BOOL)oppositeCamera
{
    _oppositeCamera = oppositeCamera;
    
    self.isVideo = YES;
    if (oppositeCamera) {
        [self clearAllSubViews];
        
        [self initUIForVideoCaller];
        
        if (self.localCamera) {
            [self connected];
        } else {
            [self.ownImageView removeFromSuperview];
        }
    } else { // 对方关闭
        if (self.localCamera) {
            
            [self.adverseImageView removeFromSuperview];
            
            [UIView animateWithDuration:1.0 animations:^{
                self.ownImageView.frame = self.frame;
            }];
        } else {
            // 本地和对方都未开始摄像头
            self.isVideo = NO;
            [self clearAllSubViews];
            
            [self initUIForAudioCaller];
            
            [self connected];
        }
    }
}

#pragma mark - 移动缩小后的按钮
- (void)handlePan:(UIPanGestureRecognizer *)gap
{
    CGPoint currentPoint = [gap locationInView:self.superview];
    CGFloat padding = _microBtn.frame.size.width / 2 + 10;
    _microBtn.center = currentPoint;
    self.center = _microBtn.center;
    
    if (gap.state == UIGestureRecognizerStateEnded || gap.state == UIGestureRecognizerStateCancelled) {
        if (currentPoint.x <= WIN_WIDTH / 2) {
            currentPoint.x = padding;
        } else {
            currentPoint.x = WIN_WIDTH - padding;
        }
        
        if (currentPoint.y < padding) {
            currentPoint.y = padding;
        }
        
        if (currentPoint.y > WIN_HEIGHT - padding) {
            currentPoint.y = WIN_HEIGHT - padding;
        }
        [UIView animateWithDuration:0.25 animations:^{
            _microBtn.center = currentPoint;
            self.center = _microBtn.center;
        }];
    }
}

@end
