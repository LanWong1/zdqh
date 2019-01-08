//
//  WYLoginVC.m
//  ZYWChart
//
//  Created by IanWong on 2018/7/17.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import "WYLoginVC.h"
#import "AppDelegate.h"
#import "QuickOrder.h"
#import "ICEQuickOrder.h"
#import "ICEQuote.h"
#import "QuickOrderCodeListVCViewController.h"
#import "SQLServerAPI.h"
#import "GDataXMLNode.h"
#import "ContracInfoModel.h"
#import "HomePageViewController.h"
#import "MyVC.h"
#import "InformationVC.h"



#define USERNAME @"063607"
#define PASSWORD @"123456"

@interface WYLoginVC ()<UITextFieldDelegate,NSXMLParserDelegate,CIEQuickOrderDelegate>
@property (nonatomic, strong)  UIButton *LoginButton;//登录按钮
@property (nonatomic, strong)  UITextField *UserNameTextField;//用户名
@property (nonatomic, strong)  UITextField *PassWordTextField;//密码
@property (nonatomic, strong)  dispatch_source_t timer;
@property (nonatomic, strong)  UILabel *connectIndicateLabel;    //登录中
@property (nonatomic, strong)  UIActivityIndicatorView *activeId;//转圈圈
@property (nonatomic, strong)  NSMutableString* strFundAcc;//账户 用户名
@property (nonatomic, copy)    NSString* strAcc; //self.strFundAcc=self.strUserId
@property (nonatomic, copy)    NSMutableString* strUserId;//随机数 当前时间
//@property (nonatomic, assign)  int connectFlag;
@property (copy, nonatomic)    NSString* Pass;//密码
@property (copy, nonatomic)    NSString* strCmd; //self.UserNameTextField.text=self.strUserId=self.PassWordTextField.text
@property (nonatomic, strong)  UITabBarController *tab;//切换
@property (nonatomic, copy)    NSString *countStatus;//账户状态
@property (nonatomic, assign)  BOOL rowChangeFlag;
@property (nonatomic, strong)  NSMutableArray<__kindof ContracInfoModel*> *contractInfoArray;//合约信息
@property (nonatomic, copy)    NSString *loginErro;
@end

@implementation WYLoginVC

//delegate of QuickOrderDelegate
- (void)LoginFailErroinfo:(NSString *)erroInfo{
    self.loginErro = erroInfo;
    NSLog(@"登录消息========== %@",self.loginErro);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //随机数 通过当前时间表示
    self.strUserId   = [[NSMutableString alloc]initWithString: [self getCurrentTime]];
    self.LoginButton = [self addLoginButton];
    self.UserNameTextField = [self addTextField:@"UserName" PositionX:100 PositionY:70];
    self.PassWordTextField = [self addTextField:@"Password" PositionX:100 PositionY:10];
    self.UserNameTextField.text = USERNAME;
    self.PassWordTextField.text = PASSWORD;
    self.PassWordTextField.secureTextEntry = YES;//隐藏密码
   // _connectFlag = 0;
    //全局变量
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.userName = USERNAME;
    app.passWord = PASSWORD;
    app.userID = self.strUserId;
    self.rowChangeFlag = true;
    //账号检查 合约信息
    SQLServerAPI *sql = [SQLServerAPI shareInstance];
    sql.paremetersSeq = [NSMutableArray array];
}

- (NSString*)getCurrentTime{
    NSDate * date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HHmmss";
    NSString *string = [formatter stringFromDate:date];
    return string;
}
//添加转圈圈
- (void)addActiveId{
    self.activeId = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activeId.center = CGPointMake(self.view.centerX ,self.view.centerY+200);
    [self.view addSubview:self.activeId];
}

//登录中。。。。。。
- (void)addLabel{
    
    _connectIndicateLabel = [[UILabel alloc]init];
    [self.view addSubview:_connectIndicateLabel];
    
    [_connectIndicateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.UserNameTextField).offset(-200);
        make.height.equalTo(@20);
        make.centerX.equalTo(self.view);
    }];
    
    [_connectIndicateLabel sizeToFit];
    self.connectIndicateLabel.adjustsFontSizeToFitWidth = YES;
    self.connectIndicateLabel.text = @"登录中...";
}


//重新连接
- (void)reconect{
    
    ICEQuickOrder *quickOrder = [ICEQuickOrder shareInstance];
    ICEQuote      *quote      = [ICEQuote shareInstance];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        @try
        {
            NSLog(@"connect to server");
            int ret  = [quickOrder Connect2ICE];//易捷
            int ret1 = [quote Connect2Quote];//行情登录
            quote.userID = self.strUserId;
        }
        
        @catch(GLACIER2CannotCreateSessionException* ex)
        {
            NSString* s = [NSString stringWithFormat:@"Session creation failed: %@", ex.reason_];
            dispatch_async(dispatch_get_main_queue(), ^ {
                NSLog(@"%@",s);
            });
        }
        @catch(GLACIER2PermissionDeniedException* ex)
        {
            NSString* s = [NSString stringWithFormat:@"Login failed: %@", ex.reason_];
            dispatch_async(dispatch_get_main_queue(), ^ {
                NSLog(@"%@",s);
            });
        }
        @catch(ICEException* s)
        {
            NSLog(@"哈哈哈 :%@",s);
            [self showAlart:s];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"连接完成");
              [self setHeartbeat]; //心跳
        });
    });
    
}
//conncet to server  首次连接
- (void) connect2Server{
    
    ICEQuickOrder *quickOrder = [ICEQuickOrder shareInstance];
    SQLServerAPI  *sql   = [SQLServerAPI shareInstance];
    ICEQuote      *quote = [ICEQuote shareInstance];
    [ICEQuickOrder shareInstance].delegate = self;
    __block int ret;
    __block int ret1;
    [self addLabel];
    [self addActiveId];
    [self.activeId startAnimating];//开始转圈圈
    //开线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        @try
        {
            NSLog(@"connect to server =============");
            //sql 接口
            [sql Connect2ICE];      //sql连接服务器
            [self checkFundAccount];//检查账号信息
            //交易接口登录
            ret = [quickOrder  Connect2ICE];
            [quickOrder queryFund:@"" strCmd:quickOrder.strFunAcc];//资金账户
            NSString *cmd1 = [NSString stringWithFormat:@"%@%@%@",quickOrder.strFunAcc,@"=",self.Pass ];
            [quickOrder queryFund:@"QueryBankInfo" strCmd:cmd1];// 重新登录
            [quickOrder queryFund:@"QueryFutuFund" strCmd:cmd1];

//            [quickOrder queryOrder:cmd1];
//            资金消息
//            NSString *cmd = [NSString stringWithFormat:@"%@%@%@",quickOrder.strFunAcc,@"=",@"49088" ];
//            [quickOrder queryCode:quickOrder.strFunAcc];
            //交易时间
            //[quickOrder.quickOrder QueryCode:@"GetTime" strCmd:@"" strOut:&strOut strErrInfo:&strErroInfo];
            // NSLog(@"queryCode: %@",strOut);
            ret1 = [quote Connect2Quote];//行情接口
            quote.userID = self.strUserId;
            if((ret == -1) || (ret1 == -1) ){
                NSLog(@"登录失败");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:self.loginErro preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.activeId removeFromSuperview]; //转圈圈 消失
                    [self.connectIndicateLabel removeFromSuperview];    //登录中 消失
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
        @catch(GLACIER2CannotCreateSessionException* ex)
        {
            NSString* s = [NSString stringWithFormat:@"Session creation failed,Cannot CreateSessionException: %@", ex.reason_];
            dispatch_async(dispatch_get_main_queue(), ^ {
                NSLog(@"%@",s);
            });
        }
        @catch(GLACIER2PermissionDeniedException* ex)
        {
            NSString* s = [NSString stringWithFormat:@"GLACIER2PermissionDeniedException Login failed: %@", ex.reason_];
            dispatch_async(dispatch_get_main_queue(), ^ {
                NSLog(@"%@",s);
            });
        }
        @catch(ICEException* s)
        {
            NSLog(@"出错了 :%@",s);
            [self showAlart:s];
        }
        @catch(NSException *s){
            [self showAlart:s];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            //登录成功啦
            if((ret != -1) && (ret1 != -1))
            {
                NSLog(@"登录完成");
                AppDelegate *app =(AppDelegate*) [UIApplication sharedApplication].delegate;
                app.loginFlag = 1;  //已登陆
                [self.activeId removeFromSuperview];
                [self.connectIndicateLabel removeFromSuperview];
                [self setHeartbeat];//心跳
                [self addTabBarController];
            }
        });
    });
}

//账号检测
-(void)checkFundAccount{
    SQLServerAPI *sql = [SQLServerAPI shareInstance];
    [sql.paremetersSeq removeAllObjects];
    int ret = -0;
    NSString *erroInfo = @"";
    NSString *outPutString = @"";
    //配置sql参数
    [sql DBAddSqlParameter:@"fund_account" direction:SqlServerInput value:self.strFundAcc];
    [sql DBAddSqlParameter:@"error_no" direction:SqlServerOutput value:@"-1"];
    [sql DBAddSqlParameter:@"error_info" direction:SqlServerOutput value:erroInfo];
    @try{
        //检查账户
        ret =  [sql.SQL ExecProc:@"pd_check_fundaccount" SQLPQS:sql.paremetersSeq strErrInfo:&erroInfo XMLSqlData:&outPutString];
        NSLog(@"account = %@  info = %@  ret = %d",outPutString,erroInfo ,ret);
        if(ret == 0){
            [self setAlertWithMessage:@"账号不存在或未开通交易权限"];
        }
        if(ret == -1){
            [self setAlertWithMessage:@"账号异常"];
        }
        
        NSData *outData = [NSData dataWithBytes:[outPutString UTF8String] length:[outPutString length]];
        NSXMLParser *parser = [[NSXMLParser alloc]initWithData:outData];
        [parser setDelegate:self];
        [parser parse];
        if([self.countStatus isEqualToString:@"1"]){
            NSLog(@"账号正常");
        }
        if([self.countStatus isEqualToString:@"0"]){
            [self setAlertWithMessage:@"账号冻结"];
        }
    }
    @catch(NSException *s){
        [self setAlertWithMessage:@"检查账号异常"];
    }
}

//消息弹窗
-(void)showAlart:(NSException *)s{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:(NSString*)s
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action){
                                                [self connect2Server];
                                                NSLog(@"重新连接");
                                            }]];
    [self presentViewController:alert animated:YES completion:nil];
}


// TabBar
- (void)addTabBarController{
    
    MyVC* my = [[MyVC alloc]init];//我的
    InformationVC* info = [[InformationVC alloc]init];//查询
    QuickOrderCodeListVCViewController *list = [[QuickOrderCodeListVCViewController alloc]init];//行情列表
    HomePageViewController *homeVC = [[HomePageViewController alloc]init];
    //CodeListViewController *list = [[CodeListViewController alloc]init];
    //CodeListVC* list = [[CodeListVC alloc]init];
    
    if(!self.tab){
    self.tab = [[UITabBarController alloc]init];
    UINavigationController* listNav = [[UINavigationController alloc]initWithRootViewController:list];
    UINavigationController* myNav   = [[UINavigationController alloc]initWithRootViewController:my];
    UINavigationController* infoNav = [[UINavigationController alloc]initWithRootViewController:info];
    UINavigationController* homeNav = [[UINavigationController alloc]initWithRootViewController:homeVC];
    homeNav.tabBarItem.title = @"首页";
//    homeVC.tabBarItem.image = [UIImage imageNamed:@"tradeNotSelected"];
//    homeVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"tradeSelected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    listNav.tabBarItem.title = @"行情";
//    listNav.tabBarItem.image = [UIImage imageNamed:@"quoNotSelectet"];
//    listNav.tabBarItem.selectedImage = [[UIImage imageNamed:@"quoSelected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    infoNav.tabBarItem.title = @"资讯";
    //checkNav.tabBarItem.image = [UIImage imageNamed:@"checkNotSelected"];
    //info.tabBarItem.selectedImage = [[UIImage imageNamed:@"checkSelected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    myNav.tabBarItem.title = @"我的";
    _tab.viewControllers = @[homeNav,listNav,infoNav,myNav];
    _tab.selectedIndex = 1;
    
    }
    
    [self presentViewController:_tab animated:NO completion:nil];
}

//设置心跳 20s一次
- (void)setHeartbeat{
    // 创建GCD定时器
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 20 * NSEC_PER_SEC, 0); //每20秒执行 发送心跳频率
    // 事件回调
    dispatch_source_set_event_handler(_timer, ^{

        @try{
            ICEQuickOrder *quickOrder = [ICEQuickOrder shareInstance];
            ICEQuote *quote = [ICEQuote shareInstance];
            [quote HeartBeat:self.strAcc];//行情连接心跳
            [quickOrder HeartBeat:self.strCmd];//快捷交易心跳
        }
        @catch(ICEException* s){
            NSLog(@"heart beat exception ==== %@",s);
            dispatch_source_cancel(self.timer);
            [self reconect];
        }
    });
    // 开启定时器
    dispatch_resume(_timer);
}


//添加 textfield
-(UITextField*)addTextField:(NSString* )placeholder PositionX:(CGFloat)x PositionY:(CGFloat)y{
    
    UITextField* TextField = [[UITextField alloc]initWithFrame:CGRectMake(self.view.centerX-x, self.view.centerY-y, 200, 30)];
    [TextField setPlaceholder:placeholder];
    [TextField setTextColor:[UIColor redColor]];
    TextField.borderStyle = UITextBorderStyleRoundedRect;
    TextField.backgroundColor = [UIColor whiteColor];
    TextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    TextField.clearsOnBeginEditing = YES;
    TextField.textAlignment = NSTextAlignmentCenter;//居中对齐
    TextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    TextField.returnKeyType = UIReturnKeyDone;
    TextField.keyboardType = UIKeyboardTypeASCIICapable;
    TextField.delegate = self;
    [self.view addSubview:TextField];
    return TextField;
}

//登录按钮
-(UIButton*)addLoginButton{
    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.centerX-50, self.view.centerY+50, 100, 80)];
    [btn setTitle:@"登录" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    btn.backgroundColor = DropColor;
    btn.layer.cornerRadius = 20;
    //btn.enabled = NO;
    [btn addTarget:self action:@selector(ButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    return btn;
}
//login button pressed 登录
-(void)ButtonPressed{
    
    if(self.UserNameTextField.text.length ==0|self.PassWordTextField.text.length == 0)
    {
        [self setAlertWithMessage:@"用户名或密码不能为空"];
    }
    else
    {
        self.strFundAcc = [[NSMutableString alloc]initWithString:self.UserNameTextField.text];
        
        AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        app.strCmd = [[NSString alloc]initWithFormat:@"%@%@%@%@%@",self.UserNameTextField.text,@"=",self.strUserId,@"=",self.PassWordTextField.text];
        app.strAcc = [NSString stringWithFormat:@"%@%@%@",self.strFundAcc,@"=",self.strUserId];
        self.strAcc = [NSString stringWithFormat:@"%@%@%@",self.strFundAcc,@"=",self.strUserId];
        self.strCmd = [[NSString alloc]initWithFormat:@"%@%@%@%@%@",self.UserNameTextField.text,@"=",self.strUserId,@"=",self.PassWordTextField.text];
        self.Pass = self.PassWordTextField.text;
        
        ICEQuote *quote = [ICEQuote shareInstance];
        quote.strFunAcc = self.UserNameTextField.text;
        quote.strPassword = self.PassWordTextField.text;
        quote.userID = self.strUserId;
        quote.strAcc = self.strAcc;
        quote.strCmd = self.strCmd;
        
        
        ICEQuickOrder *quickOrder = [ICEQuickOrder shareInstance];
        quickOrder.strFunAcc = self.UserNameTextField.text;
        quickOrder.strUserId = self.strUserId;
        quickOrder.strPassword = self.PassWordTextField.text;
        quickOrder.strAcc = self.strAcc;
        quickOrder.strcmd = self.strCmd;
        [self connect2Server];
        
    }
}



//弹窗现实
- (void)setAlertWithMessage:(NSString*)msg{
    
    UIAlertController* alert=[UIAlertController alertControllerWithTitle:@"警告"
                                                                 message:msg
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"重试"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                NSLog(@"明白了");
                                            }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //Dispose of any resources that can be recreated.
}
#pragma mark     keyboard delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    if(textField.text.length>0)
    {
        self.LoginButton.enabled = YES;
    }
    else{
        self.LoginButton.enabled = NO;
    }
    
    return YES;
}

#pragma --mark parser 代理
// 1.开始解析
-(void)parserDidStartDocument:(NSXMLParser *)parser{
    NSLog(@"开始解析数据");
}

//2.正在解析
- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict{
    
    if([elementName isEqualToString:@"account_status"]){
        self.countStatus = @"account_status";
    }
    if([elementName isEqualToString:@"row"]){
         self.rowChangeFlag = !self.rowChangeFlag;
    }
}
//3.XML文件中每一个元素解析完成
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{

    static BOOL flag;
    if(flag != self.rowChangeFlag){
        flag = self.rowChangeFlag;
    }
    if([self.countStatus isEqualToString:@"account_status"]){
        self.countStatus = string;
    }
}

//4.XML所有元素解析完毕
-(void)parserDidEndDocument:(NSXMLParser *)parser{
    NSLog(@"XML所有元素解析完毕");
}
@end
