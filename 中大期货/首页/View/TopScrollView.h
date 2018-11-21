//
//  TopScrollView.h
//  中大期货
//
//  Created by zdqh on 2018/11/21.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TopScrollView : UIView

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property(assign, nonatomic) NSInteger picCount;
- (void)loadView;
@end

NS_ASSUME_NONNULL_END
