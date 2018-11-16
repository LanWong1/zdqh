//
//  quoteModel.h
//  ZYWChart
//
//  Created by zdqh on 2018/10/31.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QuoteModelDelegate <NSObject>

- (void)reloadData:(NSInteger)index;
- (void)quoteViewRefresh:(NSInteger)index;
@end


@interface QuoteModel : NSObject

@property(nonatomic, copy) NSString* instrumenID;//合约代码。     1
@property(nonatomic, copy) NSString* lastPrice;//最新价。 4
@property(nonatomic, copy) NSString* preSettlementPrice;//上次结算价 5
@property(nonatomic, copy) NSString* preOpenInterest;//昨持仓量 7
@property(nonatomic, copy) NSString* openInterest;//持仓量 13
@property(nonatomic, copy) NSString* openInterestChange;//持仓量变化
@property(nonatomic, copy) NSString* priceChangePercentage;//涨幅百分比
@property(nonatomic, copy) NSString* priceChange;//涨幅

@property(nonatomic, copy) NSString* upperLimitPrice;//涨停板价格。16
@property(nonatomic, copy) NSString* lowerLimitPrice;//跌停板价格 17
@property(nonatomic, copy) NSString* bidPrice;//买价 22
@property(nonatomic, copy) NSString* bidVolum;//买量 23
@property(nonatomic, copy) NSString* askPrice;//卖价 24
@property(nonatomic, copy) NSString* askVolum;//卖量 25


@property(nonatomic,strong) NSMutableArray <__kindof NSDictionary*> *quoteModelArray;
@property(nonatomic,weak) id<QuoteModelDelegate>delegate;


+ (QuoteModel*)shareInstance;
- (void)calculatePriceChange;
- (void)calculateInterestChange;
- (void)processWithArray:(NSArray*)array;

@end

NS_ASSUME_NONNULL_END
