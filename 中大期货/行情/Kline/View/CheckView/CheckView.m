//
//  CheckView.m
//  中大期货
//
//  Created by zdqh on 2018/11/19.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import "CheckView.h"

@implementation CheckView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(UISegmentedControl*)segmentControl{
    
    if(!_segmentControl){
        
        NSArray *itemsArray = [NSArray arrayWithObjects:@"持仓",@"委托",@"挂单",@"成交", nil];
        self.segmentControl = [[UISegmentedControl alloc]initWithItems:itemsArray];
        _segmentControl.selectedSegmentIndex = 0;
        _segmentControl.backgroundColor = [UIColor whiteColor];
        [_segmentControl addTarget:self action:@selector(segmentTouched:) forControlEvents:UIControlEventValueChanged];
        //[self.segmentControl setTintColor:RoseColor];
        [self addSubview:self.segmentControl];
        [_segmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.top.equalTo(self);
            make.height.equalTo(@40);
        }];
        
    }
    return _segmentControl;
}


-(void)setSelectedIndex:(NSInteger)selectedIndex{
    
    _selectedIndex = selectedIndex;
    [self setLabelsWithItems:[NSArray arrayWithObjects:@"合约名称",@"多空",@"总仓",@"可用",@"开仓均价",@"逐笔浮盈" ,nil]];
    [self segmentTouched:self.segmentControl];
}

- (void)segmentTouched:(UISegmentedControl*)segmentCotrol{
    
    switch (segmentCotrol.selectedSegmentIndex) {
        case 0:
            NSLog(@"持仓");
           // [self setLabelsWithItems:[NSArray arrayWithObjects:@"合约名称",@"多空",@"总仓",@"可用",@"开仓均价",@"逐笔浮盈" ,nil]];
            break;
        case 1:
            NSLog(@"委托");
        default:
            break;
    }
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(CheckViewDataSourceOfIndex:)] ){
      id a=  [self.dataSource CheckViewDataSourceOfIndex:segmentCotrol.selectedSegmentIndex];
        NSLog(@"%@",a);
    }
}
- (void)setLabelsWithItems:(NSArray*)items{
    
    
    if(!_titleView){
        _titleView = [[UIView alloc]init];
        _titleView.backgroundColor = [UIColor redColor];
        [self addSubview:_titleView];
        [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.equalTo(@30);
            make.top.equalTo(self.segmentControl.mas_bottom);
        }];
    }
    for (UIView* view in _titleView.subviews){
        [view removeFromSuperview];
    }
    UILabel *preLabel=nil;
    for( NSString *labelText in items){
        
        UILabel *label = [[UILabel alloc]init];
   
        [_titleView addSubview:label];
        [label setTextColor:DropColor];
        //[label sizeToFit];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            if(preLabel){
                make.left.equalTo(preLabel.mas_right);
            }
            else{
                make.left.equalTo(self.titleView);
            }
            make.width.equalTo(@(self.titleView.width/items.count));
            make.height.equalTo(self.titleView);
            make.top.equalTo(self.segmentControl.mas_bottom);
        }];
        [label setText:labelText];
        [label setFont:[UIFont systemFontOfSize:12]];
        label.textAlignment = NSTextAlignmentCenter;
        preLabel = label;
        NSLog(@"fffffffffff");
    }
}






@end
