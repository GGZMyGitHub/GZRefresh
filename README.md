# GZRefresh
Read file

由于项目需求，自己封装了一个刷新类，具体使用如下：

1、导入头文件 #import "GZRefresh.h"
2、初始化方法
-(instancetype)initWithFrame:(CGRect)frame
           addHeardRefreshTo:(UITableView *)tableView
                  heardBlock:(refreshBlock)heardBlock
                   footBlock:(refreshBlock)footBlock;

3
/**
 开始头部刷新
 */
- (void)beginHeardRefresh;

4
/**
 结束刷新
 */
- (void)endRefresh;
