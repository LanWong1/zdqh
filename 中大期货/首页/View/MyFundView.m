//
//  MyFundView.m
//  中大期货
//
//  Created by zdqh on 2018/11/22.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import "MyFundView.h"

@implementation MyFundView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+(MyFundView*)instanceMyFundView{
    NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"MyFundView" owner:nil options:nil];
    return nibView[0];
}


@end
