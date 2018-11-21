//
//  NoticeView.m
//  中大期货
//
//  Created by zdqh on 2018/11/21.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import "NoticeView.h"


@interface NoticeView()



@end


@implementation NoticeView



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(UILabel*)notice{
    if(!_notice){
        _notice = [[UILabel alloc]init];
        [self addSubview:_notice];
        [_notice mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            
        }];
        [_notice sizeToFit];
        [_notice setFont:[UIFont systemFontOfSize:15]];
    }
    return _notice;
}

-(UIButton*)moreBtn{
    if(!_moreBtn){
        _moreBtn = [[UIButton alloc]init];
        [self addSubview:_moreBtn];
        [_moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.width.equalTo(@50);
            make.right.equalTo(self.mas_right).offset(-20);
            
        }];
        
    }
    return _moreBtn;
}

@end
