//
//  TopScrollView.m
//  中大期货
//
//  Created by zdqh on 2018/11/21.
//  Copyright © 2018 com.zdqh. All rights reserved.
//

#import "TopScrollView.h"

@interface TopScrollView()<UIScrollViewDelegate>


@property (retain, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger currentIndex;
@property (assign, nonatomic) CGFloat offset;
@end

@implementation TopScrollView



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)init{
    self = [super init];
    if(self){
        //[self addSubview:self.scrollView];
        //[self addSubview:self.pageControl];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
    }
    return self;
}

-(UIScrollView*)scrollView{
    if(!_scrollView){
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _scrollView.delegate = self;
        _scrollView.bounces = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
    }
    return _scrollView;
}

- (UIPageControl*)pageControl{
    if(!_pageControl){
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0,self.bounds.size.height-30, self.bounds.size.width, 20)];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:1 alpha:0.5];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    }
    return _pageControl;
}

- (void)loadView{
    
    [self.timer invalidate];
    _currentIndex = 0;
    self.pageControl.currentPage = 0;
    CGFloat imgWidth = _scrollView.frame.size.width * self.picCount;
    _scrollView.contentSize = CGSizeMake(imgWidth, 0);
    for(int i = 0; i<_picCount;i++){
        UIImageView *imageView = [UIImageView new];
        imageView.clipsToBounds = YES;
        imageView.tag = 1000+i;
        NSString *imageName = [NSString stringWithFormat:@"%d",i+1];
        [imageView setImage:[UIImage imageNamed:imageName]];
        imageView.frame = CGRectMake(self.frame.size.width * i, 0, self.frame.size.width, self.frame.size.height);
        [_scrollView addSubview:imageView];
    }
    _scrollView.contentOffset =CGPointMake(0, 0);
    _pageControl.numberOfPages = self.picCount;
   [self addTimer];
}

- (void)addTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
}

- (void)nextImage{
    
   
    
    typeof(self) __weak weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        
        weakSelf.scrollView.contentOffset = CGPointMake((weakSelf.currentIndex+1) * weakSelf.scrollView.frame.size.width, 0);
        if(weakSelf.currentIndex == self.picCount - 1){
            weakSelf.scrollView.contentOffset = CGPointMake(0, 0);
        }
    } completion:^(BOOL finished) {
        if (finished && weakSelf.currentIndex == self.picCount - 1) {
            self.pageControl.currentPage = 0;
            weakSelf.currentIndex = 0;
        }
        else{
            weakSelf.pageControl.currentPage++;
            weakSelf.currentIndex++;
        }
      
    }];
}



#pragma mark 拖拉图片的时候关闭计时器
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.timer invalidate]; //停止计时器
    self.timer = nil;
}
#pragma mark 结束拖拉的时候开启计时器
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self addTimer];
}
#pragma mark 图片滚轮的方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
 
  

}
#pragma mark 滚动停止事件方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  
    //索引
    for (int i = 0; i < self.picCount; i++) {
        if (scrollView.contentOffset.x == i * self.frame.size.width) {
            self.pageControl.currentPage = i;
            _currentIndex = i;
        }
    }
}
@end
