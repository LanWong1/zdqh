//
//  CheckView.h
//  中大期货
//
//  Created by zdqh on 2018/11/19.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CheckViewDataSourse <NSObject>

- (id)CheckViewDataSourceOfIndex:(NSInteger)selectedIndex;

@end


@interface CheckView : UIView

@property (strong, nonatomic) UISegmentedControl *segmentControl;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic,strong)  UIView *titleView;
@property (weak, nonatomic) id<CheckViewDataSourse> dataSource;
//-(id)init;

@end

NS_ASSUME_NONNULL_END
