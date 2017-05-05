//
//  TagsView.h
//  TagsView
//
//  Created by lidan on 17/5/5.
//  Copyright © 2017年 lidan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TagsViewDelegate;

typedef void (^TagsViewHeightBlock)(CGFloat tagsViewHeigh); //定义一个block返回值void参数为所有标签之和高度

@interface TagsView : UIView

@property (nonatomic) UIEdgeInsets contentInsets;  //default is (10,10,10,10)

@property (nonatomic) NSArray<NSString *> * tagsArray;  //数据源
@property (nonatomic, weak) id<TagsViewDelegate>delegate;

@property (nonatomic) CGFloat lineSpace;  //行间距, 默认为10
@property (nonatomic) CGFloat interitemSpace; //元素之间的间距，默认为5


@property (nonatomic) TagsViewHeightBlock tagsViewHeightBlock;  //所有标签之和高度


#pragma mark ---------标签属性--------

@property (nonatomic) UIEdgeInsets tagInsets; // default is (5,5,5,5)
/*- tagLabel 和 tagSelectedLabel 用于设置非选中和选中状态下标签背景色,边框宽度(default is 0)、颜色、圆角度(default is 0),字体颜色、大小等 -*/
@property (nonatomic, strong) UILabel * tagLabel;
@property (nonatomic, strong) UILabel * tagSelectedLabel;


@property (nonatomic) CGFloat tagHeight;        //标签高度，默认28
@property (nonatomic) CGFloat mininumTagWidth;  //tag 最小宽度值, 默认是0，即不作最小宽度限制
@property (nonatomic) CGFloat maximumTagWidth;  //tag 最大宽度值, 默认是CGFLOAT_MAX， 即不作最大宽度限制


#pragma mark - ......::::::: 选中 :::::::......

@property (nonatomic) BOOL allowsSelection;             //是否允许选中, default is YES
@property (nonatomic) BOOL allowsMultipleSelection;     //是否允许多选, default is NO
@property (nonatomic) BOOL defaultSelectionFirst;       //是否允许默认选中第一个选, default is NO


@property (nonatomic) CGFloat tagsHeight; //所有标签之和高度



@property (nonatomic, readonly) NSUInteger selectedIndex;   //选中索引
@property (nonatomic, readonly) NSArray<NSString *> * selecedTags;     //多选状态下，选中的Tags

- (void)selectTagAtIndex:(NSUInteger)index animate:(BOOL)animate;
- (void)deSelectTagAtIndex:(NSUInteger)index animate:(BOOL)animate;

#pragma mark - ......::::::: Edit :::::::......

//if not found, return NSNotFount
- (NSUInteger)indexOfTag:(NSString *)tagName;

- (void)addTag:(NSString *)tagName;
- (void)insertTag:(NSString *)tagName AtIndex:(NSUInteger)index;

- (void)removeTagWithName:(NSString *)tagName;
- (void)removeTagAtIndex:(NSUInteger)index;
- (void)removeAllTags;

@end



@protocol TagsViewDelegate <NSObject>

@optional
- (BOOL)tagsView:(TagsView *)tagsView shouldSelectTagAtIndex:(NSUInteger)index;
- (void)tagsView:(TagsView *)tagsView didSelectTagAtIndex:(NSUInteger)index;

- (BOOL)tagsView:(TagsView *)tagsView shouldDeselectItemAtIndex:(NSUInteger)index;
- (void)tagsView:(TagsView *)tagsView didDeSelectTagAtIndex:(NSUInteger)index;

@end
