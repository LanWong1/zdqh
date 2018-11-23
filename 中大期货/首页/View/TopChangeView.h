//
//  topChangeView.h
//  中大期货
//
//  Created by zdqh on 2018/11/23.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TopChangeView : UIStackView
@property (weak, nonatomic) IBOutlet UIButton *topRiseBtn;
@property (weak, nonatomic) IBOutlet UIButton *topDropBtn;
+(TopChangeView*)instanceTopChangeView;
@end

NS_ASSUME_NONNULL_END
