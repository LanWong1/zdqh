//
//  QuickOrderCodeListVCViewController.m
//  ZYWChart
//
//  Created by zdqh on 2018/9/5.
//  Copyright © 2018年 com.zdqh. All rights reserved.
//

#import "QuickOrderCodeListVCViewController.h"
#import "ICEQuickOrder.h"
#import "Y_StockChartViewController.h"
#import "ContracInfoModel.h"
#import "GDataXMLNode.h"
#import "SQLServerAPI.h"
#import "ICEQuote.h"
#import "QuoteModel.h"
#import "QuoteArrayModel.h"
#import "NSDictionary+Extension.h"
#import "CodeListCell.h"
#import "CodeListCoreData.h"
#import "MyFavoriteModel.h"
#import "ContractInfoArrayModel.h"


#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define SCREEN_MAX_LENGTH MAX(kScreenWidth,kScreenHeight)
#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)


@interface QuickOrderCodeListVCViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating, UISearchControllerDelegate,QuoteModelDelegate>

@property (nonatomic,strong)  UIButton *searchBtn; //搜索按钮
@property (nonatomic,strong)  UISearchController *searchController;//搜索栏
@property (nonatomic,strong)  UISearchBar *search;//搜索条
@property (nonatomic,strong)  UIView      *searchView;//搜索视图
@property (nonatomic, copy)   NSString    *filterString;
@property (nonatomic,strong)  UITableView *tableView;//行情列表
@property (nonatomic,strong)  UILabel *label; //下拉刷新
@property (nonatomic,strong)  UIActivityIndicatorView *activeId;//下拉刷新 转圈圈
@property (nonatomic, copy)   NSArray* searchResult; //行情列表 搜索
@property (nonatomic, copy)   NSMutableArray* codeArray; //合约名称
@property (nonatomic, copy)   NSMutableArray* codeList;//合约代码
@property (nonatomic, assign) NSInteger searchRfeshFlag;//标志是否正在搜索 1 搜索 0 取消搜索
@property (nonatomic, assign) NSInteger cntOfDisplayedCell;//显示的tableview cell数量
@property (nonatomic, strong) NSArray<__kindof MyFavoriteModel*> *myFavoriteArray;
@property (nonatomic, strong) NSMutableArray *subscribedIndex;//已经订阅的合约index
@property (nonatomic, strong) QuoteModel *quoteModel;//行情数据
@property (nonatomic, strong) QuoteArrayModel *quoteArrayModel;//行情数据arrray
@property (nonatomic, assign) NSInteger myFavorite;//自选segment是否选中
@property (nonatomic, strong) UISegmentedControl *segment;//segment
@property (nonatomic, strong) UIView *topView;//状态栏和导航栏
@property (nonatomic, strong) UIView *headView; //灰色的那部分 tableview顶部
@end




@implementation QuickOrderCodeListVCViewController

- (void)viewWillAppear:(BOOL)animated{
   
    [super viewWillAppear: animated];
    //_segment.hidden = NO;
    //隐藏导航栏
    self.navigationController.navigationBar.hidden      = YES;
    self.navigationController.navigationBar.translucent = YES;
   //[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;//设置状态时间文字为白色
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}


-(void)viewWillDisappear:(BOOL)animated{
    [self unSubscribeAll];// 取消订阅
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _subscribedIndex = [NSMutableArray array];
    _codeArray       = [NSMutableArray array];
    _searchResult    = [NSArray array];
    _codeList        = [NSMutableArray array];
    _quoteModel      = [QuoteModel shareInstance];
    _quoteModel.delegate = self;
    [self addSegment];//顶部segment  自选/行情
    [self addSearchButton];//搜索框
    [self getCodeList];//获取数据
    
    //注册通知在对象QuoteModel 观察
    [[NSNotificationCenter defaultCenter]addObserver:[QuoteModel shareInstance] selector:@selector(quoteDataChange:) name:@"quoteNotity" object:nil];
}
#pragma mark 获取数据
//获取列表
- (void) getCodeList{

    typeof(self) __weak  weakSelf =self; // block中引用self
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [self getCode];//获取合约信息
//      [QuoteArrayModel shareInstance].quoteModelArray = [NSMutableArray arrayWithCapacity:_codeArray.count];
        
        [weakSelf.codeArray removeAllObjects];
        [weakSelf.codeList removeAllObjects];
        [[ContractInfoArrayModel shareInstance].contractInfoArray enumerateObjectsUsingBlock:^(__kindof ContracInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [weakSelf.codeArray addObject:obj.contract_name];//合约名称
            [weakSelf.codeList addObject:obj.contract_code];//合约代码
            //名称和顺序 当收到消息时 可以通过名称确定index 更新相应的数据code 对应 index  按照tableVIew的code排列顺序
            [[QuoteArrayModel shareInstance].codelistDic setValue:@(idx) forKey:obj.contract_code];
            //初始化quotemodelarray
            QuoteModel *model =[QuoteModel new];
            [[QuoteArrayModel shareInstance].quoteModelArray addObject: model];
        }];
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.searchResult =  weakSelf.codeArray;
            //[weakSelf.activeId stopAnimating];
            //[weakSelf.label removeFromSuperview];
            [weakSelf addHeaderView];
            [weakSelf addTableView];
        //  [self addRefreshControl];
        });
    });
}

//获取合约信息。
-(void)getCode{
    SQLServerAPI *sql = [SQLServerAPI shareInstance];
    [sql.paremetersSeq removeAllObjects];
    int ret = 0;
    NSString *erroInfo = @"";
    NSString *outPutString = @"";
    NSLog(@"%@",sql.paremetersSeq);
    @try{
        //获取画服务器上的合约代码 消息
        ret =  [sql.SQL ExecProc:@"pd_get_contractcode" SQLPQS:sql.paremetersSeq strErrInfo:&erroInfo XMLSqlData:&outPutString];
        GDataXMLDocument * doc = [[GDataXMLDocument alloc]initWithXMLString:outPutString error:nil];
        GDataXMLElement *rootElement = [doc rootElement];
        NSArray *division=[rootElement children];
        for(int i =0; i<division.count;i++){
            GDataXMLElement *ele = [division objectAtIndex:i];
            NSArray *children = [ele children];
            
            ContracInfoModel *model = [[ContracInfoModel alloc]init]; //行情信息
            
            for(int j =0;j<children.count;j++){
                GDataXMLElement *element = [children objectAtIndex:j];
                NSString *value = [element stringValue];
                if([[element name] isEqualToString:@"exchange_type"]){
                    model.exchange_type = value;
                }
                if([[element name] isEqualToString:@"contract_name"]){
                    model.contract_name = value;
                }
                if([[element name] isEqualToString:@"contract_type"]){
                    model.contract_type = value;
                }
                if([[element name] isEqualToString:@"open_limited"]){
                    model.open_limited = value;
                }
                if([[element name] isEqualToString:@"contract_code"]){
                    model.contract_code = value;
                }
                if([[element name] isEqualToString:@"close_limited"]){
                    model.close_limited = value;
                }
                if([[element name] isEqualToString:@"futu_price_step"]){
                    model.futu_price_step = value;
                }
                if([[element name] isEqualToString:@"futu_price_multiplier"]){
                    model.futu_price_multiplier = value;
                }
                if([[element name] isEqualToString:@"futu_bail_rate"]){
                    model.futu_bail_rate = value;
                }
                if([[element name] isEqualToString:@"sortid"]){
                    model.sortid = value;
                }
                if([[element name] isEqualToString:@"memo"]){
                    model.memo = value;
                }
                if([[element name] isEqualToString:@"enabled"]){
                    model.enabled = value;
                }
            }
            [[ContractInfoArrayModel shareInstance].contractInfoArray addObject:model];
        }
        if(ret == 1){
            NSLog(@"正常");
        }
        if(ret == -1){
            [self setAlertWithMessage:@"异常"];
        }
    }
    @catch(NSException *s){
        [self setAlertWithMessage:@"异常"];
    }
}
//设置警告窗口
- (void)setAlertWithMessage:(NSString*)msg{
    UIAlertController* alert=[UIAlertController alertControllerWithTitle:@"警告"
                                                                 message:msg
                                                          preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"重试"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {}]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark 添加View

- (void)addSegment{
    
    NSArray *title = [NSArray arrayWithObjects:@"自选",@"主力", nil];
    _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.navigationController.navigationBar.height + [UIApplication sharedApplication].statusBarFrame.size.height)];
    _topView.backgroundColor = DropColor;
    _segment = [[UISegmentedControl alloc]initWithItems:title];
    _segment.selectedSegmentIndex = 1;
    [_segment setTintColor:RoseColor];
    //_segment.backgroundColor = [UIColor orangeColor];
    [_segment setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} forState:UIControlStateNormal];
    //_segment.frame = CGRectMake(self.view.centerX-50, self.navigationController.navigationBar.centerY-40, 100, 40);
    [_topView addSubview: _segment];
    [_segment mas_makeConstraints:^(MASConstraintMaker *make) {
        // [make.center isEqual:@(view.center)];
        make.bottom.equalTo(self.topView.mas_bottom).offset(-10);
        make.centerX.equalTo(self.topView.mas_centerX);
        make.width.equalTo(@200);
        make.height.equalTo(@30);
    }];
    [_segment addTarget:self action:@selector(touchSegment:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_topView];
}


-(void)touchSegment:(UISegmentedControl*)segment{
    
    switch(segment.selectedSegmentIndex){
            //自选
        case 0:
            _myFavorite = 1;//标志自选列表
            _searchResult = [[CodeListCoreData sharedInstance] findAll];//coredata 保存自选列表
            break;
            //行情
        case 1:
            _myFavorite = 0;
            _searchResult = _codeArray;
            break;
        default:
            break;
    }
    [_tableView reloadData];
    
}
//添加放大镜
- (void)addSearchButton{
    
    UIImage* searchImgNormal   = [UIImage imageNamed:@"searchNormal.png"];
    UIImage* searchImgSelected = [UIImage imageNamed:@"searchSelected.png"];
    self.searchBtn = [[UIButton alloc]init];
    [self.searchBtn setImage:searchImgNormal forState:UIControlStateNormal];
    [self.searchBtn setImage:searchImgSelected forState:UIControlStateHighlighted];
    [self.searchBtn addTarget:self action:@selector(addSearch) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:self.searchBtn];
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@30);
        make.height.equalTo(@30);
        make.bottom.equalTo(self.topView.mas_bottom).offset(-10);
        make.right.equalTo(self.topView.mas_right).offset(-2);
    }];
    
}
//添加searchbar
- (void)addSearch{
        self.searchBtn.enabled = NO;
        [UIView animateWithDuration:0.25f animations:^{
            [self.headView setFrame:CGRectMake(self.headView.frame.origin.x, self.headView.frame.origin.y+55, self.headView.size.width, self.headView.size.height)];
            
            [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y+55, DEVICE_WIDTH, self.tableView.frame.size.height)];
        }];
        self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
        self.searchController.searchResultsUpdater = self;
        self.searchController.dimsBackgroundDuringPresentation = NO;
        self.searchController.hidesNavigationBarDuringPresentation = NO;
        self.searchController.delegate = self;
        self.search = self.searchController.searchBar;
        self.search.backgroundColor = [UIColor whiteColor];
        [self.search sizeToFit];
        self.definesPresentationContext = YES;
        self.extendedLayoutIncludesOpaqueBars  = YES;
        _search.showsCancelButton = YES;
        _search.placeholder = @"search code";
        //消除背景色
        for(UIView *View in self.searchController.searchBar.subviews){
            if([View isKindOfClass:NSClassFromString(@"UIView")]&&View.subviews.count>0){
                [[View.subviews objectAtIndex:0]removeFromSuperview];
                break;
            }
        }
        self.searchView = [[UIView alloc]init];
        [self.view addSubview:self.searchView];
        [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topView.mas_bottom);
            make.bottom.equalTo(self.headView.mas_top);
            make.right.left.equalTo(self.view);
        }];
        self.searchView.backgroundColor = [UIColor redColor];
        [self.searchView addSubview:self.search];

}

//tableview表头
- (void)addHeaderView{
    
    _headView = [[UIView alloc]initWithFrame:CGRectMake(0,self.navigationController.navigationBar.height + [UIApplication sharedApplication].statusBarFrame.size.height, DEVICE_WIDTH, 40)];
   
    _headView.backgroundColor = [UIColor lightGrayColor];
    //view.alpha = 0.8;
    UILabel *lable3 = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 50, _headView.height)];
    lable3.adjustsFontSizeToFitWidth = YES;
    lable3.text = @"名称";
    
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(130, 0, 50, _headView.height)];
    lable.adjustsFontSizeToFitWidth = YES;
    lable.text = @"最新价";
    
    UILabel *lable1 = [[UILabel alloc]initWithFrame:CGRectMake(240, 0, 50, _headView.height)];
    lable1.adjustsFontSizeToFitWidth = YES;
    lable1.text = @"涨跌";
    
    UILabel *lable2 = [[UILabel alloc]initWithFrame:CGRectMake(350, 0, 50, _headView.height)];
    lable2.adjustsFontSizeToFitWidth = YES;
    lable2.text = @"持仓量";
    [_headView addSubview:lable];
    [_headView addSubview:lable1];
    [_headView addSubview:lable2];
    [_headView addSubview:lable3];
    
    [self.view addSubview:_headView];
    
}
//tableview
- (void)addTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.height + [UIApplication sharedApplication].statusBarFrame.size.height+40, DEVICE_WIDTH, DEVICE_HEIGHT - 120) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableHeaderView.hidden = YES;
    [self.view addSubview:_tableView];

}


# pragma mark  行情数据 订阅/取消订阅
//订阅消息
- (void)subscibe:(NSString*)sCode{
    ICEQuote* iceQuote = [ICEQuote shareInstance];
    NSString* cmdType = @"CTP,";
    NSString *strAcc = [NSString stringWithFormat:@"%@%@%@",iceQuote.strFunAcc,@"=",iceQuote.userID];
    cmdType =  [cmdType stringByAppendingString:strAcc];
    [iceQuote SubscribeQuote:cmdType strCmd:sCode];
    //[iceQuote SubscribeQuote1:cmdType strCmd:sCode];
    
}

//取消订阅全部合约
- (void)unSubscribeAll{
    
    ICEQuote* iceQuote = [ICEQuote shareInstance];
    NSString* cmdType = @"CTP,";
    NSString* strAcc = [NSString stringWithFormat:@"%@%@%@",iceQuote.strFunAcc,@"=",iceQuote.userID];
    cmdType = [cmdType stringByAppendingString:strAcc];
    for (ContracInfoModel* model in [ContractInfoArrayModel shareInstance].contractInfoArray) {
        [iceQuote UnSubscribeQuote:cmdType strCmd:model.contract_code];
    }
}


#pragma mark searchbar delegate
//search bar 过滤字符串 setter
- (void)setFilterString:(NSString *)filterString{
    
    _searchRfeshFlag = 1;
    _filterString = filterString;
    if(!filterString||filterString.length<=0){
        
    }
    else{
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"self contains[c]%@",filterString];
        NSArray* allResult = [[NSArray alloc]init];
        NSMutableArray *arrayTemp = [NSMutableArray array];
        // codelist是合约代码 英文的全局搜索
        allResult = [self.codeList filteredArrayUsingPredicate:filterPredicate];
        // 按照找到的合约代码的index来找到对应的合约名称  tableview是以合约名称为DataSource的
        for(int i=0;i<allResult.count;i++){
            [arrayTemp addObject:self.codeArray[[self.codeList indexOfObject:allResult[i]]]];
        }
        self.searchResult = arrayTemp;
        [self.tableView reloadData];//更新数据
    }
    
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
    if(!self.searchController.active){
        return;
    }
    self.filterString = self.searchController.searchBar.text;
}
//取消搜索 显示当前表格
- (void)willDismissSearchController:(UISearchController *)searchController{
    
    _searchRfeshFlag = 0; //取消搜索 搜索标志置0
    
    [UIView animateWithDuration:0.25f animations:^{
        NSLog(@"move");
         [self.headView setFrame:CGRectMake(self.headView.frame.origin.x, self.headView.frame.origin.y-55, self.headView.size.width, self.headView.size.height)];
        [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y-55, DEVICE_WIDTH, self.tableView.frame.size.height)];
    }];
    
    self.searchBtn.enabled = YES;
    
    [self.searchView removeFromSuperview];
   
    if(_myFavorite){
        _searchResult = [[CodeListCoreData sharedInstance] findAll];
    }
    else{
         _searchResult = _codeArray;
    }
    [self.tableView reloadData];
}

#pragma mark  tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_searchResult count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    //当在收藏面时
    if(_myFavorite){
        MyFavoriteModel *model = [MyFavoriteModel new];
        model = _searchResult[indexPath.row];
        index = model.index;
    }
    NSString *sCode = [ContractInfoArrayModel shareInstance].contractInfoArray[index].contract_code;
    NSString *name  = [ContractInfoArrayModel shareInstance].contractInfoArray[index].contract_name;
    NSString *title = [NSString stringWithFormat:@"%@(%@)",name,sCode];
    Y_StockChartViewController* vc = [[Y_StockChartViewController alloc]initWithScode:sCode];
    vc.navigationBarTitle = title;
    vc.futu_price_step = [ContractInfoArrayModel shareInstance].contractInfoArray[indexPath.row].futu_price_step;
    vc.codeIndex = index;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

//cell自定义
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *lastPrice;
    NSString *priceChangePercentage;
    NSString *openInterest;
    CodeListCell *cell = [CodeListCell cellWithTableView:tableView];
    // 不是搜索的条件下 和自选
    if(_myFavorite && !_searchRfeshFlag){
        lastPrice = [QuoteArrayModel shareInstance].quoteModelArray[((MyFavoriteModel*) _searchResult[indexPath.row]).index].lastPrice;
        priceChangePercentage = [QuoteArrayModel shareInstance].quoteModelArray[((MyFavoriteModel*) _searchResult[indexPath.row]).index].priceChangePercentage;
        openInterest = [QuoteArrayModel shareInstance].quoteModelArray[((MyFavoriteModel*) _searchResult[indexPath.row]).index].openInterest;
        NSString* title =((MyFavoriteModel*) _searchResult[indexPath.row]).code;
        cell.textLabel.text = title;
        cell.detailTextLabel.text  = [ContractInfoArrayModel shareInstance].contractInfoArray[((MyFavoriteModel*) _searchResult[indexPath.row]).index].contract_code;
    }
    //搜索 或者 非自选
    if ((!_myFavorite) || _searchRfeshFlag) {
        if(indexPath.row == _searchResult.count){
            _searchRfeshFlag = 0;
        }
        //判断是否已经订阅
        if(![_subscribedIndex containsObject:@(indexPath.row)] ){
            [self subscibe:[ContractInfoArrayModel shareInstance].contractInfoArray[indexPath.row].contract_code];
            [self.subscribedIndex addObject:@(indexPath.row)];
        }
        if([QuoteArrayModel shareInstance].quoteModelArray.count > 0){
            lastPrice = [QuoteArrayModel shareInstance].quoteModelArray[indexPath.row].lastPrice;
            priceChangePercentage = [QuoteArrayModel shareInstance].quoteModelArray[indexPath.row].priceChangePercentage;
            openInterest = [QuoteArrayModel shareInstance].quoteModelArray[indexPath.row].openInterest;
        }
        NSString* title = _searchResult[indexPath.row];
        cell.textLabel.text = title;
        cell.detailTextLabel.text  = [ContractInfoArrayModel shareInstance].contractInfoArray[indexPath.row].contract_code;
    }
    //订阅 只订阅一次
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
    //[cell.contentView setBackgroundColor:RoseColor];
    if([cell.priceChangePercentageLabel.text containsString:@"-"]){
        [cell.priceChangePercentageLabel setTextColor:DropColor];
        [cell.lastPriceLabel setTextColor:DropColor];
        //[cell.contentView setBackgroundColor:DropColor];
    }
    cell.openInsertLabel.text = openInterest;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue; //设置选中的颜色
    cell.textLabel.font = [UIFont systemFontOfSize:16];
//    [UIView animateWithDuration:0.5f animations:^{
//                    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
//               }];
    return cell;
}

// tableview 的操作 添加自选/取消自选
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewRowAction *action = [[UITableViewRowAction alloc]init];
    
    typeof (self) __weak weakSelf = self;
    //行情页面
    if (!_myFavorite) {
        UITableViewRowAction *likeAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"加自选" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            MyFavoriteModel *myFavoriteCode = [[MyFavoriteModel alloc]initWithCode:weakSelf.codeArray[indexPath.row] index:indexPath.row];
            [[CodeListCoreData sharedInstance] create:myFavoriteCode];
            //NSLog(@"myFavoriteCodeIndexArray ==== %@",_myFavoriteCodeIndexArray);
            tableView.editing = NO;
        }];
        likeAction.backgroundColor = [UIColor orangeColor];
        action = likeAction;
    }
    //在自选页面
    if(_myFavorite){
        UITableViewRowAction *disLikeAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"取消自选" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
           MyFavoriteModel *removeModel = [[MyFavoriteModel alloc]init];
            weakSelf.myFavoriteArray = [NSArray array];
            weakSelf.myFavoriteArray = [[CodeListCoreData sharedInstance] findAll];
            removeModel = weakSelf.myFavoriteArray[indexPath.row];
            [[CodeListCoreData sharedInstance] remove:removeModel.code];
            weakSelf.searchResult = [[CodeListCoreData sharedInstance] findAll];
            [tableView reloadData];
        }];
        disLikeAction.backgroundColor = [UIColor redColor];
        action = disLikeAction;
    }
    return @[action];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
#pragma mark    delegate of QuoteModel
- (void)reloadData:(NSInteger)idx{
    
     [_tableView reloadData];
}

#pragma mark  MemoryWarning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
