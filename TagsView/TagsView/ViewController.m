//
//  ViewController.m
//  TagsView
//
//  Created by lidan on 2017/5/5.
//  Copyright © 2017年 lidan. All rights reserved.
//

#import "ViewController.h"
#import "TagsView.h"

@interface ViewController ()<TagsViewDelegate>

@property (nonatomic, strong) TagsView * tagsView;
@property (nonatomic, strong) NSArray * dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tagsView = [[TagsView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 10)];
    _tagsView.contentInsets = UIEdgeInsetsMake(0, 20, 0, 20);
    _tagsView.tagInsets = UIEdgeInsetsMake(5, 15, 5, 15);
    _tagsView.lineSpace = 17;
    _tagsView.interitemSpace = 15;
    
    _tagsView.tagLabel.font = [UIFont systemFontOfSize:14];
    _tagsView.tagSelectedLabel.font = [UIFont systemFontOfSize:14];;
    _tagsView.tagLabel.textColor = [UIColor blackColor];
    _tagsView.tagSelectedLabel.textColor = [UIColor redColor];
    _tagsView.tagLabel.backgroundColor = [UIColor whiteColor];
    _tagsView.tagSelectedLabel.backgroundColor = [UIColor yellowColor];
    _tagsView.tagLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _tagsView.tagSelectedLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    _tagsView.tagLabel.layer.borderWidth = 1;
    _tagsView.tagLabel.layer.cornerRadius = 2;

    _tagsView.delegate = self;
    _tagsView.defaultSelectionFirst = YES;
    
    _dataArray = @[@"我的",@"demo",@"测试项目",@"通过吧sczscddvdvdfd",@"小米",@"iPhone6 Plus",@"咖啡机",@"华为荣耀",@"1111111",@"2222222222",@"3333333333",@"4444444444",@"55555555555555",@"666666666666666"];
    
    _tagsView.tagsArray = _dataArray;
    
    [self.view addSubview:_tagsView];
    
    _tagsView.tagsViewHeightBlock = ^(CGFloat tagsViewHeigh){
        //需要的时候 可以获取到tagsView区域的高度 tagsViewHeigh
    };

}

#pragma mark TagsViewDelegate
- (void)tagsView:(TagsView *)tagsView didSelectTagAtIndex:(NSUInteger)index {
    NSString *selectedKey = self.dataArray[index];
    NSLog(@"%@",selectedKey);

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
