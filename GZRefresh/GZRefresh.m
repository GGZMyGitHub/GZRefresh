//
//  GZRefresh.m
//  GZRefresh
//
//  Created by apple on 17/6/11.
//  Copyright © 2017年 GuangZhou Gu. All rights reserved.
//

#define GZRefreshScreenW     [UIScreen mainScreen].bounds.size.width
#define GZRefreshDropHeight  40

#import "GZRefresh.h"

@interface GZRefresh ()<UITableViewDelegate>

@property (nonatomic, weak)   UITableView *RefreshTableView;
@property (nonatomic, copy)   refreshBlock heardRefresh;
@property (nonatomic, copy)   refreshBlock footRefresh;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UIActivityIndicatorView *refreshLoadingView;
@property (nonatomic, strong) UILabel *tipLb;
@property (nonatomic, strong) UILabel *timeLb;

@property (nonatomic, assign) BOOL isHeard;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isFootFreshing;

@end

@implementation GZRefresh

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)changeTime
{
    if (self.isHeard && self.timeLb.hidden) {
        self.tipLb.frame = CGRectMake((GZRefreshScreenW - 100)/2, 5, 100, 15);
        self.timeLb.hidden = NO;
    }
    
    if (!self.isHeard && !self.timeLb.hidden) {
        self.tipLb.frame = CGRectMake((GZRefreshScreenW - 100)/2, 12.5, 100, 15);
        self.timeLb.hidden = YES;
    }
}

- (void)changeFrameWithoffY:(CGFloat)offY
{
    [self changeTime];
    
    if (offY <= 0 && !self.isHeard && !self.isFootFreshing) {
        
        if (self.pullDownStr) {
            self.tipLb.text = self.pullDownStr;
        }else
        {
            self.tipLb.text = @"下拉刷新";
        }
        
        self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI * 2);
        self.isHeard = YES;
        CGRect frame = self.RefreshTableView.frame;
        frame.origin.x = 0;
        frame.origin.y = - GZRefreshDropHeight;
        frame.size.height = GZRefreshDropHeight;
        self.frame = frame;
    }
    if (offY > 0 && self.isHeard && !self.isRefreshing) {
        self.isHeard = NO;
     
        if (self.pullUpStr) {
            
            self.tipLb.text = self.pullUpStr;
        }else
        {
            
            self.tipLb.text = @"上拉加载更多";
        }
        
        self.frame = CGRectMake(0, self.RefreshTableView.contentSize.height,
                                self.frame.size.width, GZRefreshDropHeight);
        self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
    }
}

//2、当监听的属性值发生变化时，触发此方法，任何KVO都要执行此方法
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    
    CGPoint offSetPoint = [[change valueForKey:@"new"] CGPointValue];
    [self changeFrameWithoffY:offSetPoint.y];
    
    self.arrowImageView.alpha = 1.0;
    if (offSetPoint.y <= -GZRefreshDropHeight && (!self.isRefreshing) && !self.isFootFreshing) {
        self.isRefreshing = YES;
        [UIView animateWithDuration:0.25 animations:^{
            self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
        } completion:^(BOOL finished) {
            self.arrowImageView.hidden = YES;
            self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI * 2);
            [self.refreshLoadingView startAnimating];
        }];
        self.RefreshTableView.contentInset = UIEdgeInsetsMake(GZRefreshDropHeight, 0, 0, 0);
        if (self.heardRefresh) {
            self.heardRefresh();
        }
    }
    if (offSetPoint.y == 0.0) {
        [self.refreshLoadingView stopAnimating];
        self.isRefreshing = NO;
    }
    
    
    if (offSetPoint.y + self.RefreshTableView.frame.size.height  >= self.RefreshTableView.contentSize.height +GZRefreshDropHeight && !self.isFootFreshing && self.RefreshTableView.contentSize.height > self.RefreshTableView.frame.size.height && !self.isRefreshing) {
        self.arrowImageView.hidden = NO;
        self.isFootFreshing = YES;
        [UIView animateWithDuration:0.25 animations:^{
            self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI * 2);
        } completion:^(BOOL finished) {
            self.arrowImageView.hidden = YES;
            self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
            [self.refreshLoadingView startAnimating];
        }];
        self.RefreshTableView.contentInset = UIEdgeInsetsMake(0, 0, GZRefreshDropHeight, 0);
        if (self.footRefresh) {
            self.footRefresh();
        }
    }
}

-(void)addHeardRefreshTo:(UITableView *)tableView
              heardBlock:(refreshBlock)heardBlock
               footBlock:(refreshBlock)footBlock
{
    
    [tableView addSubview:self];
    
    self.RefreshTableView = tableView;
    self.heardRefresh = heardBlock;
    self.footRefresh = footBlock;
    
    //1、在你想要监听该属性的地方注册，监听tableView的contentOffset的变化
    [tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)beginHeardRefresh{
    [UIView animateWithDuration:0.25 animations:^{
        
        self.RefreshTableView.contentOffset = CGPointMake(0, -GZRefreshDropHeight);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)endRefresh{
    if (self.loadingTimeFinishStr) {
        
        self.timeLb.text = [NSString stringWithFormat:@"%@:%@",self.loadingTimeFinishStr,[self getNowTime]];
    }else
    {
        self.timeLb.text = [NSString stringWithFormat:@"最后更新时间:%@",[self getNowTime]];

    }
    
    [self.refreshLoadingView stopAnimating];
    [UIView animateWithDuration:0.25 animations:^{
        if (self.isFootFreshing) {
            self.frame = CGRectMake(0, self.RefreshTableView.contentSize.height,self.frame.size.width, GZRefreshDropHeight);
        }
        self.RefreshTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.isFootFreshing = NO;
        self.isRefreshing   = NO;
    }completion:^(BOOL finished) {
        self.arrowImageView.hidden = NO;
    }];
}

- (NSString *)getNowTime{
   
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
   
    return dateTime;
}

#pragma mark - Getter
- (UIActivityIndicatorView *)refreshLoadingView{
    if (!_refreshLoadingView) {
        
        CGPoint point = CGPointMake(self.arrowImageView.frame.size.width/2 + self.arrowImageView.frame.origin.x, self.arrowImageView.frame.size.height/2 + self.arrowImageView.frame.origin.y);
        _refreshLoadingView = [[UIActivityIndicatorView alloc]init];
        CGSize size = CGSizeMake(GZRefreshDropHeight, GZRefreshDropHeight);
        _refreshLoadingView.frame = CGRectMake(point.x - size.width/2, point.y - size.height/2, size.width, size.height);
        _refreshLoadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        [self addSubview:_refreshLoadingView];
    }
    return _refreshLoadingView;
}

- (UIImageView *)arrowImageView{
    if (_arrowImageView == nil) {
        _arrowImageView = [[UIImageView alloc]initWithFrame:CGRectMake((GZRefreshScreenW-100)/2-25, 0, 15, GZRefreshDropHeight)];
        _arrowImageView.image = [UIImage imageNamed:@"WJRefreshArrow"];
        [self addSubview:_arrowImageView];
    }
    return _arrowImageView;
}

-(UILabel *)timeLb
{
    if (!_timeLb) {
        
        _timeLb = [[UILabel alloc]initWithFrame:CGRectMake((GZRefreshScreenW-100)/2, 20, 100, 15)];
        _timeLb.textAlignment = NSTextAlignmentCenter;
        _timeLb.textColor = [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1];
        _timeLb.font = [UIFont systemFontOfSize:10];
        if (self.loadStr) {
            
            _timeLb.text = [NSString stringWithFormat:@"%@...",self.loadStr];
        }else
        {
            _timeLb.text = @"加载中...";

        }
        
        [self addSubview:_timeLb];
    }
    return _timeLb;
}


- (UILabel *)tipLb{
    if (!_tipLb) {
        _tipLb = [[UILabel alloc]initWithFrame:CGRectMake((GZRefreshScreenW-100)/2, 5, 100, 15)];
        _tipLb.textAlignment = NSTextAlignmentCenter;
        _tipLb.textColor = [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1];
        _tipLb.font = [UIFont systemFontOfSize:10];
        [self addSubview:_tipLb];
    }
    return _tipLb;
}

//3、最重要的一步在self对象释放的时候，移除监听
-(void)dealloc
{
    [self.RefreshTableView removeObserver:self forKeyPath:@"contentOffset"];
}

@end
