//
//  ContractInfoModelArray.m
//  中大期货
//
//  Created by zdqh on 2018/11/23.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import "ContractInfoArrayModel.h"

@implementation ContractInfoArrayModel
static ContractInfoArrayModel *contractInfoArrayModel;

+(ContractInfoArrayModel*)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(contractInfoArrayModel == nil){
            contractInfoArrayModel = [[self alloc]init];
            contractInfoArrayModel.contractInfoArray = [NSMutableArray array];
        }
    });
    return contractInfoArrayModel;
}
@end
