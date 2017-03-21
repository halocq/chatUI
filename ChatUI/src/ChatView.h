//
//  ChatView.h
//  ChatUI
//
//  Created by lufly on 11/03/2017.
//  Copyright © 2017 lufly. All rights reserved.
//

#import <UIKit/UIKit.h>

/* 挂断的通知，object中自带参数
 @{
    @"isVideo":@(self.isVideo),   //是否为视频通话
    @"isCaller":@(!self.caller), //是否为发起方挂断
    @"answered":@(self.answerd)   //通话是否已接通
 }
 */

UIKIT_EXTERN NSString *const kHangUpNotification;

/* 接听按钮事件处理的通知，参数在object中，示例如下
@{
    @"isVideo":@(YES),          //是否为视频通话
    @"audioAccpet":@(YES)       //是否为语音接听，视频通话和音频通话的语音接听都为YES
 }
 */
UIKIT_EXTERN NSString *const kAcceptNotification;

// 摄像头切换的通知，接收到该通知时，需要切换摄像头，默认是前置摄像头
UIKIT_EXTERN NSString *const kSwitchCameraNotification;

/* 静音按钮事件通知，静音之后，对方听不到自己这边的任何声音
@{
   @"isMute":@(self.muteButton.selected)
 }
 */
UIKIT_EXTERN NSString *const kMuteNotification;

/* 本地摄像头开启/关闭
    @"videoCapture":@(YES)
 */
UIKIT_EXTERN NSString *const kVideoCaptureNotification;

@interface ChatView : UIView

@property (nonatomic, copy) NSString *nickName;
//连接信息，等待对方接听...、对方已拒绝、语音通话、视频通话
@property (nonatomic, copy) NSString *connectText;
@property (nonatomic, copy) NSString *netTipText;
@property (nonatomic, assign)   BOOL isHanged;
@property (nonatomic, assign)   BOOL answered;
@property (nonatomic, assign)   BOOL oppositeCamera; //对方是否开启摄像头

@property (nonatomic, strong, readonly) UIImageView *portraitImageView; //头像
@property (nonatomic, strong, readonly) UIImageView *ownImageView;      //自己的视频画面
@property (nonatomic, strong, readonly) UIImageView *adverseImageView;  //对方的视频画面

- (instancetype)initWithIsVideo:(BOOL)isVideo isCalled:(BOOL)isCalled;

- (void)show;

- (void)dismiss;


@end
