//
//  ViewController.m
//  ChatUI
//
//  Created by lufly on 11/03/2017.
//  Copyright © 2017 lufly. All rights reserved.
//

#import "ViewController.h"
#import "ChatView.h"

@interface ViewController ()

@property (nonatomic, copy) NSString *name;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSMutableString*str = [NSMutableString stringWithFormat:@"aaa"];
    _name = str;
    [str appendString:@"bbb"];
    NSLog(@"str= %@",str);
    NSLog(@"name = %@",_name);
    NSLog(@"%p,%p",str,_name);
    
    
    UILabel *callerLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, 100, 30)];
    callerLabel.text = @"呼叫方";
    callerLabel.textColor = [UIColor blackColor];
    callerLabel.font = [UIFont systemFontOfSize:13.f];
    [self.view addSubview:callerLabel];
    
    UIButton *btn1 = [[UIButton alloc] init];
    btn1.tag = 1;
    btn1.frame = CGRectMake(50, 160, 200, 30);
    btn1.backgroundColor = [UIColor blueColor];
    [btn1 setTitle:@"语音聊天" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [[UIButton alloc] init];
    btn2.tag = 2;
    btn2.frame = CGRectMake(50, 200, 200, 30);
    btn2.backgroundColor = [UIColor blueColor];
    [btn2 setTitle:@"视频聊天" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];

    UILabel *callerLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(50, 250, 100, 30)];
    callerLabel1.text = @"被叫方";
    callerLabel1.textColor = [UIColor blackColor];
    callerLabel1.font = [UIFont systemFontOfSize:13.f];
    [self.view addSubview:callerLabel1];

    UIButton *btn3 = [[UIButton alloc] init];
    btn3.tag = 3;
    btn3.frame = CGRectMake(50, 300, 200, 30);
    btn3.backgroundColor = [UIColor blueColor];
    [btn3 setTitle:@"语音聊天" forState:UIControlStateNormal];
    [btn3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn3];

    UIButton *btn4 = [[UIButton alloc] init];
    btn4.tag = 4;
    btn4.frame = CGRectMake(50, 350, 200, 30);
    btn4.backgroundColor = [UIColor blueColor];
    [btn4 setTitle:@"视频聊天" forState:UIControlStateNormal];
    [btn4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn4 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn4];

}

- (void)tapAction:(UIButton *)sender
{
    ChatView *presentView;
    if (sender.tag == 1) {
        presentView = [[ChatView alloc] initWithIsVideo:NO isCalled:NO];
    } else if (sender.tag == 2) {
        presentView = [[ChatView alloc] initWithIsVideo:YES isCalled:NO];
    } else if (sender.tag == 3) {
        presentView = [[ChatView alloc] initWithIsVideo:NO isCalled:YES];
    } else {
        presentView = [[ChatView alloc] initWithIsVideo:YES isCalled:YES];
    }
    
    presentView.nickName = @"小萝莉";
    presentView.connectText = @"通话时长";
    presentView.netTipText = @"对方的网络状况不是很好";
    
    [presentView show];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
