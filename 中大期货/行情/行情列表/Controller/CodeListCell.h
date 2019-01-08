//
//  CodeListCell.h
//  ZYWChart
//
//  Created by IanWong on 2018/11/12.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN
@interface CodeListCell : UITableViewCell
@property (strong,nonatomic) UILabel *lastPriceLabel; //最新价
@property (strong,nonatomic) UILabel *priceChangePercentageLabel;//涨跌幅
@property (strong,nonatomic) UILabel *openInsertLabel;//开盘价
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
