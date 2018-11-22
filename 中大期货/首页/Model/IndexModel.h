//
//  IndexModel.h
//  中大期货
//
//  Created by zdqh on 2018/11/22.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IndexModel : NSObject


@property(copy,nonatomic) NSString *indexName;
@property(copy,nonatomic) NSString *indexNum;
@property(copy,nonatomic) NSString *indexChange;

@end

NS_ASSUME_NONNULL_END
