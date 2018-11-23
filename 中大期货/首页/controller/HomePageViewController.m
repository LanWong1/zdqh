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
#import "TopChangeView.h"
#import "QuoteArrayModel.h"
#import "Y_StockChartViewController.h"
#import "CodeListCell.h"
#import "MyFavoriteModel.h"
#import "CodeListCoreData.h"
#define heightNavAndStatus self.navigationController.navigationBar.frame.size.height +  [UIApplication sharedApplication].statusBarFrame.size.height
@interface HomePageViewController ()<UITableViewDelegate,UITableViewDataSource,QuoteModelDelegate>

@property (nonatomic, strong) TopScrollView *topScrollView;
@property (nonatomic, strong) NoticeView *noticeView;
@property (nonatomic, strong) MyFundView *myFundView;
@property (nonatomic, strong) UIStackView *stactViewForIndexView;
@property (nonatomic, strong) NSMutableArray<IndexModel *> *indexArray;
@property (nonatomic, strong) FundModel *fundModel;
@property (nonatomic, strong) TopChangeView *topChangeView;
@property (nonatomic, strong) UITableView *topList;
@property (nonatomic, strong) NSMutableArray <QuoteModel*> * listData;//涨跌幅数据
@property (nonatomic, assign) NSInteger dropRiseFlag;
@end

@implementation HomePageViewController
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear: animated];

    [self.topList deselectRowAtIndexPath:[self.topList indexPathForSelectedRow] animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    self.navigationController.navigationBar.hidden = YES;
    _indexArray = [NSMutableArray array];
    // 测试数据
    _listData = [NSMutableArray array];
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
    [self.topChangeView.topRiseBtn addTarget:self action:@selector(changeTopList:) forControlEvents:UIControlEventTouchUpInside];
    [self.topChangeView.topDropBtn addTarget:self action:@selector(changeTopList:) forControlEvents:UIControlEventTouchUpInside];
    self.topList.dataSource = self;
    self.topList.delegate   = self;
    _listData = [[QuoteArrayModel shareInstance].riseModelArray mutableCopy];
}


-(void)changeTopList:(UIButton*)btn{
    [_listData removeAllObjects];
    if(btn.tag==100){
        NSLog(@"涨幅榜");
        _dropRiseFlag = 1;
        _listData = [[QuoteArrayModel shareInstance].riseModelArray mutableCopy];
    }
    else{
        NSLog(@"跌幅榜");
        _topChangeView.topRiseBtn.selected = NO;
        _dropRiseFlag = 0;
        _listData = [[QuoteArrayModel shareInstance].dropModelArray mutableCopy];
    
    }
  
    [_topList reloadData];
}
-(UITableView *)topList{
    
    if(!_topList){
        _topList = [[UITableView alloc]init];
        [self.view addSubview:_topList];
        typeof(self) __weak weakSelf = self;
        [_topList mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.topChangeView.mas_bottom).offset(5);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
   
    }
    return _topList;
}
//KVO 监测资金变化
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
   
    [self.myFundView.interest setText: change[@"new"]];
    
}
-(UIView*)topChangeView{
    
    if(!_topChangeView){
        _topChangeView = [TopChangeView instanceTopChangeView];
        [self.view addSubview:_topChangeView];
         typeof(self) __weak weakSelf = self;
        [_topChangeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.myFundView.mas_bottom);
            make.left.right.equalTo(self.view);
            make.height.equalTo(@60);
        }];
    }
    return _topChangeView;
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
    
    return _myFundView;
    
}
-(void)moreNotice:(UIButton *)btn{
    NSLog(@"see more notice");
    _fundModel.interests = @"sssssssssddd";
}



#pragma mark  tableview delegate
//tableview 的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_listData count];
}
// 选中 cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // NSLog(@"indexpath,row is %d",indexPath.row);
    
    NSString *sCode = _listData[indexPath.row].instrumenID;
    NSString *name = _listData[indexPath.row].exChangeCode;
    
    NSString *title = [NSString stringWithFormat:@"%@(%@)",name,sCode];
    Y_StockChartViewController* vc = [[Y_StockChartViewController alloc]initWithScode:sCode];
    
    vc.navigationBarTitle = title;
    vc.futu_price_step = _listData[indexPath.row].futu_price_step;
    vc.codeIndex = _listData[indexPath.row].codeIndex;
    
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
//每个 cell
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSString *lastPrice;
    NSString *priceChangePercentage;
    NSString *openInterest;
    CodeListCell *cell = [CodeListCell cellWithTableView:tableView];
 
    //订阅 只订阅一次
    lastPrice = _listData[indexPath.row].lastPrice;
    priceChangePercentage = _listData[indexPath.row].priceChangePercentage;
    openInterest = _listData[indexPath.row].openInterest;
    
    cell.textLabel.text = _listData[indexPath.row].exChangeCode;
    cell.detailTextLabel.text = _listData[indexPath.row].instrumenID;
    
    if(lastPrice == NULL){
        lastPrice = @"--";
    }
    if(priceChangePercentage==NULL){
        priceChangePercentage = @"--";
    }
    if(openInterest == NULL){
        openInterest = @"--";
    }
    cell.lastPriceLabel.text = lastPrice;
    [cell.lastPriceLabel setTextColor:RoseColor];
    cell.priceChangePercentageLabel.text = priceChangePercentage;
    [cell.priceChangePercentageLabel setTextColor:RoseColor];
    if([cell.priceChangePercentageLabel.text containsString:@"-"]){
        [cell.priceChangePercentageLabel setTextColor:DropColor];
        [cell.lastPriceLabel setTextColor:DropColor];
    }
    cell.openInsertLabel.text = openInterest;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue; //设置选中的颜色
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    return cell;
}


- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{


        UITableViewRowAction *action = [[UITableViewRowAction alloc]init];
        UITableViewRowAction *likeAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"加自选" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            //            [_myFavoriteCodeIndexArray addObject:@(indexPath.row)];
            //            [_myFavoriteCodeArray addObject:_codeArray[indexPath.row]];
            MyFavoriteModel *myFavoriteCode = [[MyFavoriteModel alloc]initWithCode:self.listData[indexPath.row].exChangeCode index:self.listData[indexPath.row].codeIndex];
            
            [[CodeListCoreData sharedInstance] create:myFavoriteCode];

            //NSLog(@"myFavoriteCodeIndexArray ==== %@",_myFavoriteCodeIndexArray);
            tableView.editing = NO;
        }];
        likeAction.backgroundColor = [UIColor orangeColor];
        action = likeAction;
//    UITableViewRowAction *action = [[UITableViewRowAction alloc]init];
//
//    if (!_myFavorite) {
//        UITableViewRowAction *likeAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"加自选" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//            //            [_myFavoriteCodeIndexArray addObject:@(indexPath.row)];
//            //            [_myFavoriteCodeArray addObject:_codeArray[indexPath.row]];
//            MyFavoriteModel *myFavoriteCode = [[MyFavoriteModel alloc]initWithCode:_codeArray[indexPath.row] index:indexPath.row];
//
//            [[CodeListCoreData sharedInstance] create:myFavoriteCode];
//
//            //NSLog(@"myFavoriteCodeIndexArray ==== %@",_myFavoriteCodeIndexArray);
//            tableView.editing = NO;
//        }];
//        likeAction.backgroundColor = [UIColor orangeColor];
//        action = likeAction;
//
//    }
//
//    if(_myFavorite){
//        UITableViewRowAction *disLikeAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"取消自选" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//            MyFavoriteModel *removeModel = [[MyFavoriteModel alloc]init];
//            _myFavoriteArray = [NSArray array];
//            _myFavoriteArray = [[CodeListCoreData sharedInstance] findAll];
//            removeModel = _myFavoriteArray[indexPath.row];
//            [[CodeListCoreData sharedInstance] remove:removeModel.code];
//            _searchResult = [[CodeListCoreData sharedInstance] findAll];
//            [tableView reloadData];
//        }];
//        disLikeAction.backgroundColor = [UIColor redColor];
//        action = disLikeAction;
//    }
    return @[action];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    return YES;
    
}


- (void)reloadData:(NSInteger)index{
    NSLog(@"reload data toplist");
    [_listData removeAllObjects];
    if(_dropRiseFlag ==1){
        _listData = [[QuoteArrayModel shareInstance].dropModelArray mutableCopy];;
    }
    else{
        _listData = [[QuoteArrayModel shareInstance].riseModelArray mutableCopy];
    }
    [_topList reloadData];
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
