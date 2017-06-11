//
//  GZRefresh.h
//  GZRefresh
//
//  Created by apple on 17/6/11.
//  Copyright © 2017年 GuangZhou Gu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^refreshBlock)();

@interface GZRefresh : UIView

/**
 加载中... 可修改语言，默认中文
 */
@property (nonatomic, copy) NSString *loadStr;

/**
 下拉刷新，可修改语言,默认中文
 */
@property (nonatomic, copy) NSString *pullDownStr;

/**
 上拉加载，可修改语言，默认中文
 */
@property (nonatomic, copy) NSString *pullUpStr;

/**
 最后更新时间,可修改语言，默认中文
 */
@property (nonatomic, copy) NSString *loadingTimeFinishStr;

/**
 添加GCRefresh控件到tableView上面

 */
- (void)addHeardRefreshTo:(UITableView *)tableView
               heardBlock:(refreshBlock)heardBlock
                footBlock:(refreshBlock)footBlock;

/**
 开始头部刷新
 */
- (void)beginHeardRefresh;

/**
 结束刷新
 */
- (void)endRefresh;

@end
