//
//  topChangeView.m
//  中大期货
//
//  Created by zdqh on 2018/11/23.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import "TopChangeView.h"

@implementation TopChangeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+(TopChangeView*)instanceTopChangeView{
    NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"topChangeView" owner:nil options:nil];
    return nibView[0];
}
@end
