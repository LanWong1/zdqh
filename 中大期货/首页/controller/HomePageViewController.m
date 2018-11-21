//
//  HomePageViewController.m
//  中大期货
//
//  Created by zdqh on 2018/11/16.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import "HomePageViewController.h"
#import "TopScrollView.h"
#import "NoticeView.h"
#import "IndexView.h"
#define heightNavAndStatus self.navigationController.navigationBar.frame.size.height +  [UIApplication sharedApplication].statusBarFrame.size.height
@interface HomePageViewController ()

@property (nonatomic, strong) TopScrollView *topScrollView;
@property (nonatomic, strong) NoticeView *noticeView;



@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
 
    NSArray *array = [NSArray arrayWithObjects:@"上证指数",@"深圳成指",@"恒生指数",nil];
    self.topScrollView.picCount = 3;
    [self.topScrollView loadView];
    self.noticeView.backgroundColor = [UIColor greenColor];
    [_noticeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topScrollView.mas_bottom).offset(2);
        make.height.equalTo(@30);
        make.left.right.equalTo(self.view);
    }];
    [_noticeView.notice setText:@"中大期货盈利一个亿"];
    [_noticeView.moreBtn setTitle:@"More" forState:UIControlStateNormal];
    [_noticeView.moreBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [_noticeView.moreBtn addTarget: self action:@selector(moreNotice:) forControlEvents:UIControlEventTouchUpInside];
    UIStackView *stackView = [[UIStackView alloc]init];
    [self.view addSubview:stackView];
    typeof(self) __weak weakSelf = self;
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.noticeView.mas_bottom).offset(10);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@80);
    }];
    for(int i=0;i<array.count;i++){
        IndexView *view = [[IndexView alloc]init];
        view.backgroundColor = [UIColor redColor];
        [view.titleLabel setText:array[i]];
        [view setSize:CGSizeMake(60, 60)];
        [stackView addArrangedSubview:view];
    }
    stackView.backgroundColor = [UIColor blueColor];
    [stackView setAxis:UILayoutConstraintAxisHorizontal];
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
}
- (void)addIndexViewForArray:(NSArray*)arry{
    IndexView *preView = nil;
    [preView setSize:CGSizeMake(60, 60)];
    
    
}
- (TopScrollView*)topScrollView{
    if(!_topScrollView){
        _topScrollView = [[TopScrollView alloc]init];
        _topScrollView = [[TopScrollView alloc]initWithFrame:CGRectMake(0, heightNavAndStatus, self.view.width, 200)];
        [self.view addSubview:_topScrollView];
    }
    return _topScrollView;
}

-(NoticeView*)noticeView{
    if(!_noticeView){
        _noticeView = [[NoticeView alloc]init];
        [self.view addSubview:_noticeView];
    }
    return _noticeView;
}


-(void)moreNotice:(UIButton *)btn{
    NSLog(@"see more notice");
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
