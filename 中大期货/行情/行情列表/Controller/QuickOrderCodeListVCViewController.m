//
//  QuickOrderCodeListVCViewController.m
//  ZYWChart
//
//  Created by zdqh on 2018/9/5.
//  Copyright © 2018年 zyw113. All rights reserved.
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
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define SCREEN_MAX_LENGTH MAX(kScreenWidth,kScreenHeight)
#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)


@interface QuickOrderCodeListVCViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating, UISearchControllerDelegate,QuoteModelDelegate>

@property (nonatomic,strong)  UIButton *searchBtn;
@property (nonatomic,strong)  UISearchController *searchController;
@property (nonatomic,strong)  UISearchBar *search;
@property (nonatomic,strong)  UIView      *searchView;
@property (nonatomic, copy)   NSString    *filterString;
@property (nonatomic,strong)  UITableView *tableView;
@property (nonatomic,strong)  UILabel *label;
@property (nonatomic,strong)  UIActivityIndicatorView *activeId;
@property (nonatomic,copy)    NSArray* searchResult;
@property (nonatomic,copy)    NSMutableArray* codeArray;

//@property (nonatomic)         ICEInt refreshFlag;
//@property (nonatomic,strong)  UIRefreshControl   *refreshControl;
@property (nonatomic,strong)  NSMutableArray<__kindof ContracInfoModel*> *contractInfoArray;
@property (nonatomic,strong)  NSArray<__kindof MyFavoriteModel*> *myFavoriteArray;
@property (nonatomic,strong)  NSMutableArray *subscribedIndex;
//@property (nonatomic,strong)  NSMutableArray<__kindof QuoteModel*> *quoteModelArray;
@property (nonatomic,strong)  WpQuoteServerCallbackReceiverI* reciver;
@property (nonatomic,strong)  QuoteModel *quoteModel;//行情数据
@property (nonatomic,strong)  QuoteArrayModel *quoteArrayModel;//行情数据arrray
@property (nonatomic,strong)  NSMutableArray *myFavoriteCodeIndexArray;//自选的合约在列表中的位置
@property (nonatomic,strong)  NSMutableArray *myFavoriteCodeArray;//自选合约数组
@property (nonatomic,assign)  NSInteger myFavorite;//自选segment是否选中
@property (nonatomic,strong)  UISegmentedControl *segment;//segment

@end

@implementation QuickOrderCodeListVCViewController



- (void)viewWillAppear:(BOOL)animated{
   
    [super viewWillAppear: animated];
    //_segment.hidden = NO;
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.translucent =YES;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;//设置状态时间文字为白色
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _myFavoriteCodeIndexArray = [NSMutableArray array];
    _subscribedIndex = [NSMutableArray array];
    _codeArray = [NSMutableArray array];
    _searchResult = [NSArray array];
    _myFavoriteCodeArray = [NSMutableArray array];
    _quoteModel = [QuoteModel shareInstance];
    _quoteModel.delegate = self;
    //self.navigationItem.title = @"行情";
     _contractInfoArray = [NSMutableArray array];
    self.reciver = [[WpQuoteServerCallbackReceiverI alloc]init];
    //self.reciver.delegate = self;
    [self addSegment];
    [self addSearchButton];
    [self getCodeList];//获取数据
    
    //注册通知
    //在对象QuoteModel 观察
    
    [[NSNotificationCenter defaultCenter]addObserver:[QuoteModel shareInstance] selector:@selector(quoteDataChange:) name:@"quoteNotity" object:nil];
}

- (void)addSegment{
    NSArray *title = [NSArray arrayWithObjects:@"自选",@"主力", nil];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.navigationController.navigationBar.height + [UIApplication sharedApplication].statusBarFrame.size.height)];
    view.backgroundColor = DropColor;
    _segment = [[UISegmentedControl alloc]initWithItems:title];
    _segment.selectedSegmentIndex = 1;
   // [_segment setTintColor:RoseColor];
    _segment.backgroundColor = [UIColor orangeColor];
    [_segment setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} forState:UIControlStateNormal];
    //    _segment.frame = CGRectMake(self.view.centerX-50, self.navigationController.navigationBar.centerY-40, 100, 40);
    [view addSubview: _segment];
    [_segment mas_makeConstraints:^(MASConstraintMaker *make) {
        [make.center isEqual:@(view.center)];
        make.width.equalTo(@100);
        make.height.equalTo(@30);
    }];
    [_segment addTarget:self action:@selector(touchSegment:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:view];
   
    
    
}


-(void)touchSegment:(UISegmentedControl*)segment{
    
    switch(segment.selectedSegmentIndex){
        case 0:
            _myFavorite = 1;
//            if(!_myFavoriteCodeIndexArray){
//                _myFavoriteCodeIndexArray = [NSMutableArray array];
//            }
//            _searchResult = _myFavoriteCodeArray;
            _searchResult = [[CodeListCoreData sharedInstance] findAll];
            [_tableView reloadData];
            // [self queryOrder];
            break;
        case 1:
            _myFavorite = 0;
            _searchResult = _codeArray;
            [_tableView reloadData];
            break;
        default:
            break;
    }
    
}
#pragma mark    获取数据

//获取列表
- (void) getCodeList{

//    if(self.refreshFlag!= 1)
//    {
//        [self addActiveId];
//        [self addLabel];
//        [self.activeId startAnimating];
//    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [self getCode];//获取合约信息
//        [QuoteArrayModel shareInstance].quoteModelArray = [NSMutableArray arrayWithCapacity:_codeArray.count];
        [_codeArray removeAllObjects];
        [_contractInfoArray enumerateObjectsUsingBlock:^(__kindof ContracInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
            [_codeArray addObject:obj.contract_name];
            //名称和顺序 当收到消息时 可以通过名称确定index 更新相应的数据code 对应 index  按照tableVIew的code排列顺序
            [[QuoteArrayModel shareInstance].codelistDic setValue:@(idx) forKey:obj.contract_code];
            //初始化quotemodelarray
            [[QuoteArrayModel shareInstance].quoteModelArray addObject: [QuoteModel shareInstance]];
        }];
        dispatch_sync(dispatch_get_main_queue(), ^{
            _searchResult =  _codeArray;
            [self.activeId stopAnimating];
            [self.label removeFromSuperview];
            [self addHeaderView];
            [self addTableView];
           // [self addRefreshControl];
        });
    });
}

//获取合约信息
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
            ContracInfoModel *model = [[ContracInfoModel alloc]init];
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
            [_contractInfoArray addObject:model];
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

#pragma -mark 下拉刷新
//- (void)addRefreshControl{
//    _refreshControl = [[UIRefreshControl alloc]init];
//    _refreshControl.tintColor = [UIColor redColor];
//    _refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
//    [_refreshControl addTarget:self action:@selector(refreshControlAction) forControlEvents:UIControlEventValueChanged];
//    [_tableView addSubview:_refreshControl];
//}
//
//- (void)refreshControlAction{
//    if(self.refreshControl.refreshing){
//        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"加载中..."];
//        self.refreshFlag = 1;
//        [self getCodeList];
//        [self.refreshControl endRefreshing];
//
//    }
//}

#pragma mark 添加View
//添加放大镜
- (void)addSearchButton{
    UIImage* searchImgNormal = [UIImage imageNamed:@"searchNormal.png"];
    UIImage* searchImgSelected = [UIImage imageNamed:@"searchSelected.png"];
    self.searchBtn = [[UIButton alloc]init];
    [self.searchBtn setImage:searchImgNormal forState:UIControlStateNormal];
    [self.searchBtn setImage:searchImgSelected forState:UIControlStateHighlighted];
    [self.searchBtn addTarget:self action:@selector(addSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtn = [[UIBarButtonItem alloc]initWithCustomView:self.searchBtn];
    self.navigationItem.rightBarButtonItem = searchBtn;
}



//添加searchbar
- (void)addSearch{
    [UIView animateWithDuration:0.25f animations:^{
        if(IS_IPHONE_X){
            [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y+55+30, DEVICE_WIDTH, self.tableView.frame.size.height)];
        }
        else{
            [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y+55, DEVICE_WIDTH, self.tableView.frame.size.height)];
        }
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
    if(IS_IPHONE_X){
        self.searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 55+30, DEVICE_WIDTH, self.searchController.searchBar.frame.size.height)];
    }
    else{
        self.searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 55, DEVICE_WIDTH, self.searchController.searchBar.frame.size.height)];
    }
    [self.searchView addSubview:self.search];
    [self.view addSubview:self.searchView];

}
//转圈圈
- (void)addActiveId{
    self.activeId = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activeId.center = CGPointMake(self.view.centerX ,self.view.centerY+200);
    [self.view addSubview:self.activeId];
}
//"please wait"
- (void)addLabel{
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(self.view.centerX-40, self.view.centerY-200, 80, 20)];
    self.label.adjustsFontSizeToFitWidth = YES;
    self.label.textAlignment  = NSTextAlignmentCenter;
    self.label.text = @"Please Wait";
    [self.view addSubview:self.label];
}
- (void)addHeaderView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0,60, DEVICE_WIDTH, 40)];
    view.backgroundColor = [UIColor lightGrayColor];
    //view.alpha = 0.8;
    
    UILabel *lable3 = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 50, view.height)];
    lable3.adjustsFontSizeToFitWidth = YES;
    lable3.text = @"名称";
    
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(130, 0, 50, view.height)];
    lable.adjustsFontSizeToFitWidth = YES;
    lable.text = @"最新价";
    
    UILabel *lable1 = [[UILabel alloc]initWithFrame:CGRectMake(240, 0, 50, view.height)];
    lable1.adjustsFontSizeToFitWidth = YES;
    lable1.text = @"涨跌";
    
    UILabel *lable2 = [[UILabel alloc]initWithFrame:CGRectMake(350, 0, 50, view.height)];
    lable2.adjustsFontSizeToFitWidth = YES;
    lable2.text = @"持仓量";

    [view addSubview:lable];
    [view addSubview:lable1];
    [view addSubview:lable2];
    [view addSubview:lable3];
    
    [self.view addSubview:view];
    
}
//tableview
- (void)addTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, DEVICE_WIDTH, DEVICE_HEIGHT - 120) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableHeaderView.hidden = YES;

    [self.view addSubview:_tableView];

}
- (void)subscibe:(NSString*)sCode{
    ICEQuote* iceQuote = [ICEQuote shareInstance];
    NSString* cmdType = @"CTP,";
    NSString *strAcc = [NSString stringWithFormat:@"%@%@%@",iceQuote.strFunAcc,@"=",iceQuote.userID];
    cmdType =  [cmdType stringByAppendingString:strAcc];
    [iceQuote SubscribeQuote:cmdType strCmd:sCode];
}
#pragma mark searchbar delegate
//search bar 过滤字符串 setter
- (void)setFilterString:(NSString *)filterString{
    _filterString = filterString;
    if(!filterString||filterString.length<=0){
        //self.searchResult = self.titlesArray;
    }
    else{
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"self contains[c]%@",filterString];
        NSArray* allResult = [[NSArray alloc]init];
        allResult = self.codeArray;//所有数据 全局搜索
        self.searchResult = [allResult filteredArrayUsingPredicate:filterPredicate];
    }
    [self.tableView reloadData];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
    if(!self.searchController.active){
        return;
    }
    self.filterString = self.searchController.searchBar.text;
}
//取消搜索 显示当前表格
- (void)willDismissSearchController:(UISearchController *)searchController{
    
    [UIView animateWithDuration:0.25f animations:^{
        NSLog(@"move");
        [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y-55, DEVICE_WIDTH, self.tableView.frame.size.height)];
    }];
    [self.searchView removeFromSuperview];
    _searchResult = _codeArray;
    [self.tableView reloadData];
}

#pragma mark  tableview delegate
//tableview 的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_searchResult count];
}
// 选中 cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // NSLog(@"indexpath,row is %d",indexPath.row);
    NSString *sCode = _contractInfoArray[indexPath.row].contract_code;
    NSString *name = _contractInfoArray[indexPath.row].contract_name;
    NSString *title = [NSString stringWithFormat:@"%@(%@)",name,sCode];
    Y_StockChartViewController* vc = [[Y_StockChartViewController alloc]initWithScode:sCode];
    vc.navigationBarTitle = title;
    vc.futu_price_step = _contractInfoArray[indexPath.row].futu_price_step;
    vc.codeIndex = indexPath.row;
    
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
    
    
    if(_myFavorite){
     
        lastPrice = [QuoteArrayModel shareInstance].quoteModelArray[((MyFavoriteModel*) _searchResult[indexPath.row]).index].lastPrice;
        priceChangePercentage = [QuoteArrayModel shareInstance].quoteModelArray[((MyFavoriteModel*) _searchResult[indexPath.row]).index].priceChangePercentage;
        openInterest = [QuoteArrayModel shareInstance].quoteModelArray[((MyFavoriteModel*) _searchResult[indexPath.row]).index].openInterest;
        
        
        
        
        NSString* title =((MyFavoriteModel*) _searchResult[indexPath.row]).code;
        NSLog(@"title = %@",title);
        cell.textLabel.text = title;
        cell.detailTextLabel.text  = _contractInfoArray[((MyFavoriteModel*) _searchResult[indexPath.row]).index].contract_code;
    }
    if (!_myFavorite) {
        if(![_subscribedIndex containsObject:@(indexPath.row)] ){
            [_subscribedIndex addObject:@(indexPath.row)];
            [self subscibe:_contractInfoArray[indexPath.row].contract_code];
        }
        if([QuoteArrayModel shareInstance].quoteModelArray.count > 0){
            lastPrice = [QuoteArrayModel shareInstance].quoteModelArray[indexPath.row].lastPrice;
            priceChangePercentage = [QuoteArrayModel shareInstance].quoteModelArray[indexPath.row].priceChangePercentage;
            openInterest = [QuoteArrayModel shareInstance].quoteModelArray[indexPath.row].openInterest;
        }
        NSString* title = _searchResult[indexPath.row];
        cell.textLabel.text = title;
        cell.detailTextLabel.text  = _contractInfoArray[indexPath.row].contract_code;
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
    
    if (!_myFavorite) {
        UITableViewRowAction *likeAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"加自选" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//            [_myFavoriteCodeIndexArray addObject:@(indexPath.row)];
//            [_myFavoriteCodeArray addObject:_codeArray[indexPath.row]];
            MyFavoriteModel *myFavoriteCode = [[MyFavoriteModel alloc]initWithCode:_codeArray[indexPath.row] index:indexPath.row];
            
            [[CodeListCoreData sharedInstance] create:myFavoriteCode];
            
            //NSLog(@"myFavoriteCodeIndexArray ==== %@",_myFavoriteCodeIndexArray);
            tableView.editing = NO;
        }];
        likeAction.backgroundColor = [UIColor orangeColor];
        action = likeAction;
        
    }
  
    if(_myFavorite){
        UITableViewRowAction *disLikeAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"取消自选" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
           MyFavoriteModel *removeModel = [[MyFavoriteModel alloc]init];
            _myFavoriteArray = [NSArray array];
           _myFavoriteArray = [[CodeListCoreData sharedInstance] findAll];
            removeModel = _myFavoriteArray[indexPath.row];
          [[CodeListCoreData sharedInstance] remove:removeModel.code];
            _searchResult = [[CodeListCoreData sharedInstance] findAll];
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
    
    NSLog(@"reload data ==============");
 //   NSIndexPath *pth = [NSIndexPath indexPathForRow:idx inSection:0];
//    [UIView performWithoutAnimation:^{
//        [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:pth, nil] withRowAnimation:UITableViewRowAnimationNone];
//    }];
     [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
