//
//  KlineModel.m
//  中大期货
//
//  Created by IanWong on 2019/1/8.
//  Copyright © 2019 com.zdqh. All rights reserved.
//

#import "KlineModel.h"
#import "Y_KLineGroupModel.h"
@implementation KlineModel

static KlineModel *sharedSingleton = nil;
+(KlineModel *)sharedInstance{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedSingleton = [[self alloc] init];
        sharedSingleton.MinData          = [NSMutableArray array];
        sharedSingleton.fiveMinsData     = [NSMutableArray array];
        sharedSingleton.fifteenMinsData  = [NSMutableArray array];
        sharedSingleton.monthData        = [NSMutableArray array];
        sharedSingleton.weekData         = [NSMutableArray array];
        sharedSingleton.dayData          = [NSMutableArray array];
        sharedSingleton.dataDic          = [NSMutableDictionary dictionary];
        sharedSingleton.modelsDict       = [NSMutableDictionary dictionary];
    });
    return sharedSingleton;
}

- (NSMutableDictionary<NSString *,Y_KLineGroupModel *> *)modelsDict
{
    NSLog(@"modeldict=============");
    if (!_modelsDict) {
        _modelsDict = @{}.mutableCopy;
    }
    return _modelsDict;
}
@end

