//
//  KlineModel.h
//  中大期货
//
//  Created by IanWong on 2019/1/8.
//  Copyright © 2019 com.zdqh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Y_KLineGroupModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface KlineModel : NSObject
//线的数据
@property (nonatomic, strong) NSMutableArray *MinData;
@property (nonatomic, strong) NSMutableArray *fiveMinsData;
@property (nonatomic, strong) NSMutableArray *fifteenMinsData;
@property (nonatomic, strong) NSMutableArray *weekData;
@property (nonatomic, strong) NSMutableArray *dayData;
@property (nonatomic, strong) NSMutableArray *monthData;
@property (nonatomic, strong) NSMutableDictionary *dataDic;//数据字典
@property (nonatomic, copy)   NSMutableDictionary <NSString*, Y_KLineGroupModel*> *modelsDict;



+(KlineModel *)sharedInstance;

@end

NS_ASSUME_NONNULL_END
