//
//  ViewController.m
//  GZRefresh
//
//  Created by apple on 17/6/11.
//  Copyright © 2017年 GuangZhou Gu. All rights reserved.
//

#import "ViewController.h"
#import "GZRefresh.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)   UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) GZRefresh *refresh;

@end

@implementation ViewController

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64) style:UITableViewStylePlain];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1];
        
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"GZRefresh";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    
    _refresh = [[GZRefresh alloc] init];
    
    __weak typeof(self)weakSelf = self;
    [_refresh addHeardRefreshTo:self.tableView heardBlock:^{
        
        [weakSelf createData];

    } footBlock:^{
        [weakSelf createFootData];

    }];
    
    [_refresh beginHeardRefresh];
}

- (void)createData{
    NSLog(@"-----------头部刷新数据-----------");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.dataSource removeAllObjects];
        self.dataSource = [NSMutableArray array];
        for (int i = 100; i < 120; i ++) {
            [self.dataSource addObject:[NSString stringWithFormat:@"%d",i]];
        }
        [self.tableView reloadData];
        [_refresh endRefresh];
    });
    
}

- (void)createFootData{
    NSLog(@"-----------尾部加载更多数据-----------");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (int i = 200; i < 210; i ++) {
            [self.dataSource addObject:[NSString stringWithFormat:@"%d",i]];
        }
        [self.tableView reloadData];
        [_refresh endRefresh];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
