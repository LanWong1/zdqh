//
//  IndexView.h
//  中大期货
//
//  Created by zdqh on 2018/11/21.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IndexView : UIView

@property (copy, nonatomic) NSString* title;//指数名称
@property (copy, nonatomic) NSString* index;//指数
@property (copy, nonatomic) NSString* indexChange;//指数涨跌幅

@property (strong, nonatomic) UILabel* titleLabel;
@property (strong,nonatomic) UILabel* indexLabel;
@property (strong, nonatomic) UILabel* indexChangeLabel;

@end

NS_ASSUME_NONNULL_END
