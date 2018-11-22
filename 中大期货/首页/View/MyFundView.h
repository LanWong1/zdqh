//
//  MyFundView.h
//  中大期货
//
//  Created by zdqh on 2018/11/22.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyFundView : UIView
@property (weak, nonatomic) IBOutlet UILabel *interest;
@property (weak, nonatomic) IBOutlet UILabel *unusedInterest;
@property (weak, nonatomic) IBOutlet UILabel *usedRate;
+(MyFundView*)instanceMyFundView;
@end

NS_ASSUME_NONNULL_END
