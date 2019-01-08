//
//  FundModel.h
//  中大期货
//
//  Created by zdqh on 2018/11/22.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FundModel : NSObject 
@property(copy,nonatomic) NSString* unusedInterest;//可用
@property(copy,nonatomic) NSString* interests;//权益
@property(assign,nonatomic) float usedRate;//使用率
+(FundModel *)sharedInstance;
@end

NS_ASSUME_NONNULL_END
