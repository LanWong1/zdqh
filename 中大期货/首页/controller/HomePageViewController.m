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
#import "IndexModel.h"
#import "MyFundView.h"
#import "FundModel.h"

#define heightNavAndStatus self.navigationController.navigationBar.frame.size.height +  [UIApplication sharedApplication].statusBarFrame.size.height
@interface HomePageViewController ()

@property (nonatomic, strong) TopScrollView *topScrollView;
@property (nonatomic, strong) NoticeView *noticeView;
@property (nonatomic, strong) MyFundView *myFundView;
@property (nonatomic, strong) UIStackView *stactViewForIndexView;
@property (nonatomic, strong) NSMutableArray<IndexModel *> *indexArray;
@property (nonatomic, strong) FundModel *fundModel;

@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    self.navigationController.navigationBar.hidden = YES;
    _indexArray = [NSMutableArray array];
    // 测试数据
    
    
    _fundModel = [FundModel sharedInstance];
    
    [_fundModel addObserver:self forKeyPath:@"interests" options:NSKeyValueObservingOptionNew context:nil];
    
    
    
    [self testData];
    self.topScrollView.picCount = 3;
    [self.topScrollView loadView];
    [self addNoticeView];
    [self addIndexViewForArray:_indexArray];
    [self.myFundView.interest setText:@"10000"];
    [self.myFundView.usedRate setText:@"60%"];
    [self.myFundView.unusedInterest setText:@"4000"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
   
    [self.myFundView.interest setText: change[@"new"]];
    
}

-(void)addNoticeView{
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
}
- (TopScrollView*)topScrollView{
    if(!_topScrollView){
        _topScrollView = [[TopScrollView alloc]init];
        _topScrollView = [[TopScrollView alloc]initWithFrame:CGRectMake(0, -[UIApplication sharedApplication].statusBarFrame.size.height, self.view.width, 200)];
        [self.view addSubview:_topScrollView];
    }
    return _topScrollView;
}
- (void)testData{
    NSArray *name = [NSArray arrayWithObjects:@"上证指数",@"深圳成指",@"恒生指数",nil];
    NSArray *index = [NSArray arrayWithObjects:@"3000",@"8000",@"3000", nil];
    NSArray *indexChange = [NSArray arrayWithObjects:@"10%",@"-5.0%",@"10%", nil];
    
    for(int i=0; i<3;i++){
        IndexModel *model = [IndexModel new];
        model.indexName = name[i];
        model.indexNum = index[i];
        model.indexChange = indexChange[i];
        [_indexArray addObject:model];
        
    }
}
-(NoticeView*)noticeView{
    if(!_noticeView){
        _noticeView = [[NoticeView alloc]init];
        [self.view addSubview:_noticeView];
    }
    return _noticeView;
}

-(void)addIndexViewForArray:(NSArray<IndexModel*>*)array{
    
    _stactViewForIndexView = [[UIStackView alloc]init];
    [self.view addSubview:_stactViewForIndexView];
    typeof(self) __weak weakSelf = self;
    [_stactViewForIndexView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.noticeView.mas_bottom).offset(10);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@80);
    }];
    
    [_stactViewForIndexView setAxis:UILayoutConstraintAxisHorizontal];
    _stactViewForIndexView.distribution = UIStackViewDistributionEqualSpacing;
    for(int i=0;i<array.count;i++){
        IndexView *view = [[IndexView alloc]init];
        //view.backgroundColor = [UIColor redColor];
        view.layer.borderWidth=1.f;
        view.layer.borderColor = [UIColor blackColor].CGColor;
        view.layer.masksToBounds = YES;
        [view.titleLabel setText:array[i].indexName];
        [view.indexLabel setText:array[i].indexNum];
        [view.indexChangeLabel setText:array[i].indexChange];
        if([array[i].indexChange floatValue] < 0){
           // [view.titleLabel setTextColor:DropColor];
            [view.indexLabel setTextColor:DropColor];
            [view.indexChangeLabel setTextColor:DropColor];
        }
        else{
            //[view.titleLabel setTextColor:RoseColor];
            [view.indexLabel setTextColor:RoseColor];
            [view.indexChangeLabel setTextColor:RoseColor];
        }
        [_stactViewForIndexView addArrangedSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@90);
            make.height.equalTo(@60);
            if(i == 0){
                make.left.equalTo(self.stactViewForIndexView.mas_left).offset(10);
            }
            if(i == array.count -1){
                make.right.equalTo(self.view.mas_right).offset(-10);
            }
            make.top.equalTo(self.stactViewForIndexView);
        }];
    }
}

- (MyFundView*)myFundView{
    if(!_myFundView){
        _myFundView = [MyFundView instanceMyFundView];
        [self.view addSubview:_myFundView];
        [_myFundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.stactViewForIndexView.mas_bottom).offset(10);
            make.height.equalTo(@60);
            make.left.right.equalTo(self.view);
        }];
    }
    NSLog(@"aksdjaskldjklasjdklasdjlka");
    return _myFundView;
    
}
-(void)moreNotice:(UIButton *)btn{
    NSLog(@"see more notice");
    _fundModel.interests = @"sssssssssddd";
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
