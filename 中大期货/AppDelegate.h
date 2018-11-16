//
//  AppDelegate.h
//  ZYWChart
//
//  Created by 张有为 on 2016/12/17.
//  Copyright © 2016年 zyw113. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICETool.h"
#import "ICENpTrade.h"

#import "ICEQuote.h"
#import "ICEQuickOrder.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) BOOL isEable;


@property (strong, nonatomic) ICETool* iceTool;
@property (strong, nonatomic) ICENpTrade* iceNpTrade;
@property (strong, nonatomic) ICEQuote* iceQuote;
@property (strong, nonatomic) ICEQuickOrder* QuickOrder;
@property (strong,nonatomic) NSString* userName;
@property (strong,nonatomic) NSString* passWord;
@property (strong,nonatomic) NSString* userID;
@property (strong,nonatomic) NSString* strAcc;
@property (strong,nonatomic) NSString* strFundAcc;
//@property (strong,nonatomic) LoginVC* loginVC;
@property (nonatomic) int loginFlag;
@property (strong,nonatomic) NSString* strCmd;
@property (strong,nonatomic) WpTradeAPIServerCallbackReceiverI* wpTradeAPIServerCallbackReceiverI;
@property (strong,nonatomic) NpTradeAPIServerCallbackReceiverI* npTradeAPIServerCallbackReceiverI;
@property (strong,nonatomic) WpQuoteServerCallbackReceiverI* wpQuoteServerCallbackReceiverI;

@property (strong,nonatomic) autoTradeCallbackReceiver* autoTradeCallback;

@property (copy, nonatomic) NSString *strErroInfo;
@end

