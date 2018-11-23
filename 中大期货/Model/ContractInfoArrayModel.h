//
//  ContractInfoModelArray.h
//  中大期货
//
//  Created by zdqh on 2018/11/23.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContracInfoModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ContractInfoArrayModel : NSObject
@property (nonatomic,strong)  NSMutableArray<__kindof ContracInfoModel*> *contractInfoArray;
+(ContractInfoArrayModel*)shareInstance;
@end

NS_ASSUME_NONNULL_END
