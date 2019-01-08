//
//  InformationVC.m
//  中大期货
//
//  Created by zdqh on 2018/11/16.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import "InformationVC.h"

@interface InformationVC ()

@property (nonatomic,strong)  UISegmentedControl *segment;//segment
@property (nonatomic, assign) NSInteger InformFlag;

@end

@implementation InformationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSegment];
    
    {
        
        _InformFlag = 1; //选中资讯
        NSLog(@"To Do Fetch resource from service");
        /*
         获取网络资源
         */
        
    }
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear: animated];
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.translucent =YES;
}
- (void)addSegment{
    NSArray *title = [NSArray arrayWithObjects:@"资讯",@"直播", nil];
    //导航栏 + 状态栏的高度  不同设备自适应
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.navigationController.navigationBar.height + [UIApplication sharedApplication].statusBarFrame.size.height)];
    
    view.backgroundColor = DropColor;
    
    _segment = [[UISegmentedControl alloc]initWithItems:title];
    
    _segment.selectedSegmentIndex = 1;
    
    [_segment setTintColor:RoseColor];
    [_segment setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [view addSubview: _segment];
    
    [_segment mas_makeConstraints:^(MASConstraintMaker *make) {
        // [make.center isEqual:@(view.center)];
        make.bottom.equalTo(view.mas_bottom).offset(-10);
        make.centerX.equalTo(view.mas_centerX);
        make.width.equalTo(@200);
        make.height.equalTo(@30);
    }];
    [_segment addTarget:self action:@selector(touchSegment:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:view];
}


-(void)touchSegment:(UISegmentedControl*)segment{
    
    switch(segment.selectedSegmentIndex){
        case 0:
            _InformFlag = 1;
            {
                NSLog(@"Fetch news from server");
            }
            NSLog(@"咨询");
            break;
            
        case 1:
            
            _InformFlag = 0;
           //_searchResult = _codeArray;
//            [_tableView reloadData];
        {
            NSLog(@"To Do Fetch Viedo Source from server");
            
        }
            NSLog(@"直播");
            break;
        default:
            break;
    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
