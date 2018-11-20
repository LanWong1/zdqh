//
//  CheckView.m
//  中大期货
//
//  Created by zdqh on 2018/11/19.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import "CheckView.h"
#import "NSArray+Extension.h"
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
   // [self setLabelsWithItems:[NSArray arrayWithObjects:@"合约名称",@"多空",@"总仓",@"可用",@"开仓均价 ", ,nil]];
    [self segmentTouched:self.segmentControl];
}

- (void)segmentTouched:(UISegmentedControl*)segmentCotrol{
    NSArray *array = [NSArray new];
    switch (segmentCotrol.selectedSegmentIndex) {
        case 0:
            NSLog(@"持仓");
            array = [NSArray arrayWithObjects:@"合约名称",@"多空",@"开仓均价",@"总仓",@"逐笔浮盈" ,@"可用",nil];
           
            break;
        case 1:
            array = [NSArray arrayWithObjects:@"合约名称",@"状态",@"委托量",@"开平",@"委托价",@"委托时间" ,nil];
            NSLog(@"委托");
            break;
        case 2:
            array = [NSArray arrayWithObjects:@"合约名称",@"开平",@"委托",@"挂大量",@"委托价" ,nil];
            break;
        case 3:
            array = [NSArray arrayWithObjects:@"合约名称",@"开平",@"成交价",@"成交量",@"成交时间" ,nil];
        
        default:
            break;
    }
    
    
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(CheckViewDataSourceOfIndex:)] ){
      NSArray *array1 =  [self.dataSource CheckViewDataSourceOfIndex:segmentCotrol.selectedSegmentIndex];
      NSArray<NSArray*>*array2 = [NSArray arrayWithObjects:array,array1,nil];
        [self setLabelsWithItems:array2 forIndex:segmentCotrol.selectedSegmentIndex];
    }
}
- (void)setLabelsWithItems:(NSArray<NSArray*>*)items forIndex:(NSInteger)index{
    
    

    for(UIView* view in _titleView.subviews){
        [view removeFromSuperview];
    }

 //   UILabel *preLabel=nil;
//    for(int i = 0;i<items.count;i++){
//        UILabel *label = [[UILabel alloc]init];
//        [self.titleView addSubview:label];
//        [label setTextColor:DropColor];
//        [label mas_makeConstraints:^(MASConstraintMaker *make) {
//            if(preLabel){
//                make.left.equalTo(preLabel.mas_right);
//            }
//            else{
//                make.left.equalTo(self);
//            }
//            make.width.equalTo(self).multipliedBy(1.0f/items.count);
//            make.height.equalTo(@40);
//            make.top.equalTo(self.segmentControl.mas_bottom);
//
//        }];
//
//        [label setText:items[i]];
//        [label setFont:[UIFont systemFontOfSize:16]];
//        label.textAlignment = NSTextAlignmentCenter;
//        preLabel = label;
//    }
    for(int i=0;i<items.count;i++){
        NSLog(@"%@",items[i]);
        UILabel *preLabel=nil;
     
        for( NSString* title in items[i]){
            UILabel *label = [[UILabel alloc]init];
        
            [self.titleView addSubview:label];
            [label setTextColor:[UIColor blackColor]];
            if(i==0){
                [label setTextColor:DropColor];
            }
            
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                if(preLabel){
                    make.left.equalTo(preLabel.mas_right);
                }
                else{
                    make.left.equalTo(self);
                }
                make.width.equalTo(self).multipliedBy(1.0f/items[i].count);
                make.height.equalTo(@40);
                make.top.equalTo(self.segmentControl.mas_bottom).offset(i*40);
            }];
            [label setText:title];
            [label setFont:[UIFont systemFontOfSize:16]];
            label.textAlignment = NSTextAlignmentCenter;
            preLabel = label;
        }
    }
}

-(UIView *)titleView{
    
        if(!_titleView){
            _titleView = [[UIView alloc]init];
            [self addSubview:_titleView];
            [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self);
                make.height.equalTo(@30);
                make.bottom.equalTo(self.mas_bottom);
                //make.top.equalTo(self.segmentControl.mas_bottom);
            }];
        }
    return _titleView;
}


@end
