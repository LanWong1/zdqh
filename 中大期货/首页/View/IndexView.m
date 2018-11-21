//
//  IndexView.m
//  中大期货
//
//  Created by zdqh on 2018/11/21.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import "IndexView.h"

@interface IndexView()




@end


@implementation IndexView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (UILabel*)titleLabel{
    
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc]init];
        [self addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self);
            make.height.equalTo(@30);
        }];
    }
    return _titleLabel;
}
@end
