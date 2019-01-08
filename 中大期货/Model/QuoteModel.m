//
//  quoteModel.m
//  ZYWChart
//
//  Created by zdqh on 2018/10/31.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import "QuoteModel.h"
#import "QuoteArrayModel.h"
#import "ContractInfoArrayModel.h"
@implementation QuoteModel
//单例模式 全局变量


static QuoteModel* quoteModel = nil;
+ (QuoteModel*)shareInstance{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (quoteModel == nil){
            quoteModel = [[self alloc]init];
        }
        
    });
    return quoteModel;
}


- (void)quoteDataChange:(NSNotification *)notify{
    
    [[QuoteArrayModel shareInstance].riseModelArray removeAllObjects];;
    [[QuoteArrayModel shareInstance].dropModelArray removeAllObjects];
    NSMutableArray *dropArray = [NSMutableArray array];
    NSMutableArray *riseArray = [NSMutableArray array];
    NSInteger index = [notify.userInfo[@"index"] integerValue];
    //NSLog(@"indexModel ========== %d",index);
    [QuoteArrayModel shareInstance].quoteModelArray[index] = notify.userInfo[@"model"];//更新第index个的数据
    
    
    [QuoteArrayModel shareInstance].quoteModelArray[index].exChangeCode = [ContractInfoArrayModel shareInstance].contractInfoArray[index].contract_name;
    
    
     [QuoteArrayModel shareInstance].quoteModelArray[index].futu_price_step = [ContractInfoArrayModel shareInstance].contractInfoArray[index].futu_price_step;
    
    [QuoteArrayModel shareInstance].quoteModelArray[index].codeIndex = index;
    
   // NSLog(@"quoteModelArray[%d] == %@",index,[[QuoteArrayModel shareInstance].quoteModelArray[index] description]);
    
    for(QuoteModel * model in  [QuoteArrayModel shareInstance].quoteModelArray ){
        
        if([model.priceChangePercentage floatValue] >= 0){
            [riseArray addObject:model];
        }
        else{
            [dropArray addObject:model];
        }
    }
    
    
    
    [[QuoteArrayModel shareInstance].riseModelArray addObjectsFromArray:  [riseArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        QuoteModel *model1 = obj1;
        QuoteModel *model2 = obj2;
        float v1 = [model1.priceChangePercentage floatValue];
        float v2 = [model2.priceChangePercentage floatValue];
        if(v1 > v2){
            
            return NSOrderedAscending;
        }
        else if(v1 == v2){
            return NSOrderedSame;
        }
        else{
            return NSOrderedDescending;
        }
        
    }]];
    
    
    
    [[QuoteArrayModel shareInstance].dropModelArray addObjectsFromArray:[dropArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        QuoteModel *model1 = obj1;
        QuoteModel *model2 = obj2;
        float v1 = [model1.priceChangePercentage floatValue];
        float v2 = [model2.priceChangePercentage floatValue];
        if(v1 > v2){
            return NSOrderedDescending;
        }
        else if(v1 == v2){
            return NSOrderedSame;
        }
        else{
            return NSOrderedAscending;
        }
        
    }]];
    
//
//    [[QuoteArrayModel shareInstance].riseModelArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        QuoteModel *model = obj;
//        NSLog(@"rise %@:%@", model.instrumenID ,model.priceChangePercentage);
//    }];
//    [[QuoteArrayModel shareInstance].dropModelArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        QuoteModel *model = obj;
//        NSLog(@"drop    %@:%@", model.instrumenID ,model.priceChangePercentage);
//    }];
    
    
    
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(reloadData:)]){
      
        [self.delegate reloadData:index];
    }
//    if(self.delegate && [self.delegate respondsToSelector:@selector(quoteViewRefresh:)]){
//
//        [self.delegate quoteViewRefresh:index];
//    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"topQuoteNotity" object:nil userInfo:@{@"index":@(index)}];
    
}


- (void)processWithArray:(NSArray*)array{
    
        self.instrumenID = array[1];
        self.lastPrice = array[4];
        self.preSettlementPrice = array[5];
        self.preOpenInterest = array[7];
        self.openInterest = array[13];
        self.upperLimitPrice = array[16];
        self.lowerLimitPrice = array[17];
        self.bidPrice = array[22];
        self.bidVolum = array[23];
        self.askPrice = array[24];
        self.askVolum = array[25];
        [self calculatePriceChange];
        [self calculateInterestChange];
}

- (void)calculatePriceChange{
  
    float priceChange = [self.lastPrice floatValue] - [self.preSettlementPrice floatValue];//涨幅
    float priceChangePercentage = 100*priceChange/([self.preSettlementPrice floatValue]);//涨幅百分比
    
    self.priceChangePercentage = [NSString stringWithFormat:@"%.2f%@",priceChangePercentage,@"%"];
    self.priceChange = [NSString stringWithFormat:@"%.1f",priceChange];
   
}
- (void)calculateInterestChange{
    
    
    NSInteger interestChange = [self.openInterest integerValue] - [self.preOpenInterest integerValue];
    self.openInterestChange = [NSString stringWithFormat:@"%ld",(long)interestChange ];
    
}


@end
