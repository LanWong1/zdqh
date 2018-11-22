//
//  FundModel.m
//  中大期货
//
//  Created by zdqh on 2018/11/22.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import "FundModel.h"

@implementation FundModel
static FundModel *sharedSingleton = nil;
+(FundModel *)sharedInstance{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedSingleton = [[self alloc] init];
    });
    return sharedSingleton;
}
@end
