//
//  ICEQuote.h
//  ZYWChart
//
//  Created by zdqh on 2018/6/11.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WpQuote.h>
#import <objc/Glacier2.h>
#import <objc/Ice.h>

@class ICEInitializationData;
@protocol ICECommunicator;
@protocol GLACIER2RouterPrx;

@protocol WpQuoteServerCallbackReceiverDelegate <NSObject>

- (void)reloadData:(NSInteger)index;

@end



@interface WpQuoteServerCallbackReceiverI : WpQuoteServerCallbackReceiver
@property (weak,nonatomic) id<WpQuoteServerCallbackReceiverDelegate> delegate;
@end


@interface ICEQuote : NSObject

@property (nonatomic) id<WpQuoteServerClientApiPrx> WpQuoteServerclientApiPrx;

@property (copy, nonatomic) NSString *userID;
@property (nonatomic, copy) NSString* strFunAcc;
@property (nonatomic, copy) NSString* strPassword;
@property (nonatomic, copy) NSString* strAcc;
@property (nonatomic, copy) NSString* strCmd;

+ (ICEQuote*)shareInstance;

- (int)Connect2Quote;
- (void)initiateCallback:(NSString*)strAcc;
- (int)Login:(NSString*)StrCmd;
- (int)HeartBeat:(NSString*)strCmd;
- (void)SubscribeQuote:(NSString*)strCmdType strCmd:(NSString*)strCmd;
- (int)SubscribeQuote1:(NSString*)strCmdType strCmd:(NSString*)strCmd;
- (void)UnSubscribeQuote:(NSString *)strCmdType strCmd:(NSString *)strcmd;
//- (int)GetDayKline:(NSString*)ExchangeID;
//- (NSMutableArray*)getTimeData:(NSString*)sCode;
- (NSMutableArray*)getKlineData:(NSString*)sCode type:(NSString*)type;
//@property(nonatomic,weak) id<ICEQuoteDelegate>delegate;

@end
