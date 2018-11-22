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
        [_titleLabel sizeToFit];
       // _titleLabel.backgroundColor = [UIColor greenColor];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self);
            make.height.equalTo(@30);
        }];
    }
    return _titleLabel;
}

- (UILabel*)indexLabel{
    if(!_indexLabel){
        _indexLabel = [[UILabel alloc]init];
        [_indexLabel sizeToFit];
         // _indexLabel.backgroundColor = [UIColor greenColor];
        [self addSubview:_indexLabel];
        [_indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
        }];
    }
    return _indexLabel;
}

- (UILabel*)indexChangeLabel{
    if(!_indexChangeLabel){
        _indexChangeLabel = [[UILabel alloc]init];
        [_indexChangeLabel sizeToFit];
         // _indexChangeLabel.backgroundColor = [UIColor greenColor];
        [self addSubview:_indexChangeLabel];
        [_indexChangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.indexLabel.mas_bottom).offset(5);
        }];
    }
    return _indexChangeLabel;
}
@end
