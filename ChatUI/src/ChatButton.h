//
//  ChatButton.h
//  ChatUI
//
//  Created by lufly on 11/03/2017.
//  Copyright © 2017 lufly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatButton : UIButton

- (instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName isVideo:(BOOL)isVideo;

+ (instancetype)chatButtonWithTitle:(NSString *)title imageName:(NSString *)imageName isVideo:(BOOL)isViedeo;

- (instancetype)initWithTitle:(NSString *)title noHandleImageName:(NSString *)noHandleImageName;

+ (instancetype)chatButtonWithTitle:(NSString *)title noHandleImageName:(NSString *)noHandleImageName;

@end
