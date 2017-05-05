//
//  TagsView.m
//  TagsView
//
//  Created by lidan on 17/5/5.
//  Copyright © 2017年 lidan. All rights reserved.
//


#import "TagsView.h"


static NSString * const tagCellID = @"tagCellID";

#pragma mark - - - TagModel- - -

@interface TagModel : NSObject
@property (nonatomic, copy) NSString * name;
@property (nonatomic, assign) BOOL selected;

//用于计算文字大小
@property (nonatomic, strong) UIFont * font;

@property (nonatomic, readonly) CGSize contentSize;

- (instancetype)initWithName:(NSString *)name font:(UIFont *)font;

@end

@implementation TagModel

-(instancetype)initWithName:(NSString *)name font:(UIFont *)font{
    if (self = [super init]) {
        _name = name;
        self.font = font;
    }
    return self;
}

-(void)setFont:(UIFont *)font{
    _font = font;
    [self calculateContentSize];
}

-(void)calculateContentSize{
    NSDictionary * dic = @{NSFontAttributeName:_font};
    CGSize textSize = [_name boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    _contentSize = CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}
@end

#pragma mark======================TagCell===================

@interface TagCell : UICollectionViewCell

@property (nonatomic, strong) UILabel * tagLabel;
@property (nonatomic) TagModel * tagModel;
@property (nonatomic) UIEdgeInsets contentInsets;

@end

@implementation TagCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        _tagLabel = [[UILabel alloc] init];
        _tagLabel.textAlignment = NSTextAlignmentCenter;
        _tagLabel.userInteractionEnabled = NO;
        [self.contentView addSubview:_tagLabel];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    CGFloat width = bounds.size.width - self.contentInsets.left - self.contentInsets.right;
    CGRect frame = CGRectMake(0, 0, width, [self.tagModel contentSize].height);
    self.tagLabel.frame = frame;
    self.tagLabel.center = self.contentView.center;
}

@end

#pragma mark----------------FMEqualSpaceFlowLayout----------

typedef void (^ContentHeightBlock)(CGFloat allContentHeight); //定义一个block返回值void参数为所有标签之和高度

@interface FMEqualSpaceFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) id<UICollectionViewDelegateFlowLayout> delegate;
@property (nonatomic, strong) NSMutableArray * itemAttributes;
@property (nonatomic, assign) CGFloat contentHeight;

@property (nonatomic) ContentHeightBlock contentHeightBlock;  //所有标签之和高度

@end



@implementation FMEqualSpaceFlowLayout

- (id)init
{
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.minimumInteritemSpacing = 5;
        self.minimumLineSpacing = 5;
        self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);

    }
    
    return self;
}

- (CGFloat)minimumInteritemSpacingAtSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
        return [self.delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
    }
    
    return self.minimumInteritemSpacing;
}

- (CGFloat)minimumLineSpacingAtSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
        return [self.delegate collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:section];
    }
    
    return self.minimumLineSpacing;
}

- (UIEdgeInsets)sectionInsetAtSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        return [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
    }
    
    return self.sectionInset;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(200, 50);
}


#pragma mark - Methods to Override
- (void)prepareLayout
{
    [super prepareLayout];
    
    _contentHeight = 0;
    NSInteger itemCount = [[self collectionView] numberOfItemsInSection:0];
    self.itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];
    
    CGFloat minimumInteritemSpacing = [self minimumInteritemSpacingAtSection:0];
    CGFloat minimumLineSpacing = [self minimumLineSpacingAtSection:0];
    UIEdgeInsets sectionInset = [self sectionInsetAtSection:0];
    
    CGFloat xOffset = sectionInset.left;
    CGFloat yOffset = sectionInset.top;
    CGFloat xNextOffset = sectionInset.left;
    
    for (NSInteger idx = 0; idx < itemCount; idx++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
        CGSize itemSize = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
        
        xNextOffset += (minimumInteritemSpacing + itemSize.width);
        
        if (xNextOffset - minimumInteritemSpacing > [self collectionView].bounds.size.width - sectionInset.right) {
            xOffset = sectionInset.left;
            xNextOffset = (sectionInset.left + minimumInteritemSpacing + itemSize.width);
            yOffset += (itemSize.height + minimumLineSpacing);
        }
        else
        {
            xOffset = xNextOffset - (minimumInteritemSpacing + itemSize.width);
        }
        
        UICollectionViewLayoutAttributes *layoutAttributes =
        [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        layoutAttributes.frame = CGRectMake(xOffset, yOffset, itemSize.width, itemSize.height);
        [_itemAttributes addObject:layoutAttributes];
        
        _contentHeight = MAX(_contentHeight, CGRectGetMaxY(layoutAttributes.frame));
    }
    
    _contentHeight = MAX(_contentHeight + sectionInset.bottom, self.collectionView.frame.size.height);
    
    self.contentHeightBlock(_contentHeight);
    
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.itemAttributes)[indexPath.item];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.itemAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *evaluatedObject, NSDictionary *bindings) {
        return CGRectIntersectsRect(rect, [evaluatedObject frame]);
    }]];
}

- (CGSize)collectionViewContentSize {
    CGSize contentSize  = CGSizeMake(self.collectionView.frame.size.width, self.contentHeight);
    return contentSize;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    CGRect oldBounds = self.collectionView.bounds;
    
    if (CGRectGetHeight(newBounds) != CGRectGetHeight(oldBounds)) {
        return YES;
    }
    return YES;
}

@end


#pragma mark-------------------TagsView-----------------


@interface TagsView ()<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView * collectionView;
@property (strong, nonatomic) NSMutableArray<NSString *> * tagsMutableArray;
@property (strong, nonatomic) NSMutableArray<TagModel *> * tagModels;

@property (strong, nonatomic) FMEqualSpaceFlowLayout * flowLayout;

@end
extern CGFloat tagsViewHeight;


@implementation TagsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    
    self.tagLabel = [[UILabel alloc] init];
    self.tagLabel.backgroundColor = [UIColor whiteColor];
    self.tagLabel.font =  [UIFont systemFontOfSize:14];
    self.tagLabel.textColor = [UIColor blackColor];
    self.tagLabel.layer.borderColor = [UIColor blackColor].CGColor;
    self.tagLabel.layer.borderWidth = 0;
    self.tagLabel.layer.cornerRadius = 0;
    
    self.tagSelectedLabel = [[UILabel alloc] init];
    self.tagSelectedLabel.backgroundColor = [UIColor whiteColor];
    self.tagSelectedLabel.font =  [UIFont systemFontOfSize:14];
    self.tagSelectedLabel.textColor = [UIColor blackColor];
    self.tagSelectedLabel.layer.borderColor = [UIColor blackColor].CGColor;
    self.tagSelectedLabel.layer.borderWidth = 0;
    self.tagSelectedLabel.layer.cornerRadius = 0;
    
    _contentInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    _tagInsets = UIEdgeInsetsMake(5, 5, 5, 5);

    _tagHeight = 28;
    _mininumTagWidth = 0;
    _maximumTagWidth = CGFLOAT_MAX;
    _lineSpace = 10;
    _interitemSpace = 5;
    
    _allowsSelection = YES;
    _allowsMultipleSelection = NO;
    _defaultSelectionFirst = NO;
    
    [self addSubview:self.collectionView];
    
    UICollectionView * collectionView = self.collectionView;
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary * views = NSDictionaryOfVariableBindings(collectionView);
    NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|"
                                                                   options:NSLayoutFormatAlignAllTop
                                                                   metrics:nil
                                                                     views:views];
    constraints = [constraints arrayByAddingObjectsFromArray:
                   [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|"
                                                           options:0
                                                           metrics:nil
                                                             views:views]];
    [self addConstraints:constraints];
}

- (CGSize)intrinsicContentSize {
    CGSize contentSize = self.collectionView.collectionViewLayout.collectionViewContentSize;
    return CGSizeMake(UIViewNoIntrinsicMetric, contentSize.height);
}

- (void)setTagsArray:(NSArray<NSString *> *)tagsArray {
    _tagsMutableArray = [tagsArray mutableCopy];
    [self.tagModels removeAllObjects];
    [tagsArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        TagModel * tagModel = [[TagModel alloc] initWithName:obj font:self.tagLabel.font];

        [self.tagModels addObject:tagModel];
    }];
    [self.collectionView reloadData];

}

- (void)selectTagAtIndex:(NSUInteger)index animate:(BOOL)animate {
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                                      animated:animate
                                scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)deSelectTagAtIndex:(NSUInteger)index animate:(BOOL)animate {
    [self.collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES];
}

#pragma mark -Edit

- (NSUInteger)indexOfTag:(NSString *)tagName {
    __block NSUInteger index = NSNotFound;
    [self.tagsMutableArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:tagName]) {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

- (void)addTag:(NSString *)tagName {
    [self.tagsMutableArray addObject:tagName];
    
    TagModel * tagModel = [[TagModel alloc] initWithName:tagName font:self.tagLabel.font];

    [self.tagModels addObject:tagModel];
    [self.collectionView reloadData];
    [self invalidateIntrinsicContentSize];
}

- (void)insertTag:(NSString *)tagName AtIndex:(NSUInteger)index {
    if (index >= self.tagsMutableArray.count) {
        return;
    }
    
    [self.tagsMutableArray insertObject:tagName atIndex:index];
    
    TagModel * tagModel = [[TagModel alloc] initWithName:tagName font:self.tagLabel.font];

    
    [self.tagModels insertObject:tagModel atIndex:index];
    [self.collectionView reloadData];
    [self invalidateIntrinsicContentSize];
}

- (void)removeTagWithName:(NSString *)tagName {
    return [self removeTagAtIndex:[self indexOfTag:tagName]];
}

- (void)removeTagAtIndex:(NSUInteger)index {
    if (index >= self.tagsMutableArray.count || index == NSNotFound) {
        return ;
    }
    
    [self.tagsMutableArray removeObjectAtIndex:index];
    [self.tagModels removeObjectAtIndex:index];
    [self.collectionView reloadData];
    [self invalidateIntrinsicContentSize];
}

- (void)removeAllTags {
    [self.tagsMutableArray removeAllObjects];
    [self.tagModels removeAllObjects];
    [self.collectionView reloadData];
}

#pragma mark -CollectionViewDataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tagModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TagCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:tagCellID forIndexPath:indexPath];
    
    TagModel * tagModel = self.tagModels[indexPath.row];
    cell.tagModel = tagModel;
    cell.tagLabel.text = tagModel.name;
    cell.layer.cornerRadius = self.tagLabel.layer.cornerRadius;
    cell.layer.masksToBounds = self.tagLabel.layer.cornerRadius > 0;
    cell.contentInsets = self.tagInsets;
    cell.layer.borderWidth = self.tagLabel.layer.borderWidth;
    if (indexPath.row == 0 ) {
        if (_defaultSelectionFirst) {
            tagModel.selected = YES;
        }
    }

    [self setCell:cell selected:tagModel.selected NSIndexPath:nil];
    
    return cell;
}



- (void)setCell:(TagCell *)cell selected:(BOOL)selected NSIndexPath:(NSIndexPath *)indexPath{
    if (_defaultSelectionFirst) {
        if (indexPath != nil) {
            TagCell * firstCell = (TagCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            firstCell.backgroundColor = self.tagLabel.backgroundColor;
            firstCell.tagLabel.font = self.tagLabel.font;
            firstCell.tagLabel.textColor = self.tagLabel.textColor;
            firstCell.layer.borderColor = self.tagLabel.layer.borderColor;
            TagModel * tagModel = self.tagModels[0];
            tagModel.selected = NO;

        }
    }
    if (selected) {
        
        cell.backgroundColor = self.tagSelectedLabel.backgroundColor;
        cell.tagLabel.font = self.self.tagSelectedLabel.font;
        cell.tagLabel.textColor = self.self.tagSelectedLabel.textColor;
        cell.layer.borderColor = self.tagSelectedLabel.layer.borderColor;

        
    }else {
        
        cell.backgroundColor = self.tagLabel.backgroundColor;
        cell.tagLabel.font = self.self.tagLabel.font;
        cell.tagLabel.textColor = self.self.tagLabel.textColor;
        cell.layer.borderColor = self.tagLabel.layer.borderColor;

    }
}




#pragma mark -UICollectionViewDelegate


- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tagsView:shouldSelectTagAtIndex:)]) {
        return [self.delegate tagsView:self shouldSelectTagAtIndex:indexPath.row];
    }
    
    return _allowsSelection;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tagsView:didDeSelectTagAtIndex:)]) {
        return [self.delegate tagsView:self shouldDeselectItemAtIndex:indexPath.row];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.delegate respondsToSelector:@selector(tagsView:didSelectTagAtIndex:)]) {
        [self.delegate tagsView:self didSelectTagAtIndex:indexPath.row];
    }
    
    TagModel * tagModel = self.tagModels[indexPath.row];
    TagCell * cell = (TagCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.allowsMultipleSelection) {
        tagModel.selected = YES;
        [self setCell:cell selected:YES NSIndexPath:nil];
        return;
    }
    
    if (tagModel.selected) {
        cell.selected = NO;
        collectionView.allowsMultipleSelection = YES;
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        [self collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
        collectionView.allowsMultipleSelection = NO;
        return;
    }
    
    tagModel.selected = YES;
    [self setCell:cell selected:YES NSIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tagsView:didDeSelectTagAtIndex:)]) {
        [self.delegate tagsView:self didDeSelectTagAtIndex:indexPath.row];
    }
    
    TagModel * tagModel = self.tagModels[indexPath.row];
    TagCell * cell = (TagCell *)[collectionView cellForItemAtIndexPath:indexPath];
    tagModel.selected = NO;
    [self setCell:cell selected:NO NSIndexPath:nil];
}

#pragma mark - ......::::::: UICollectionViewDelegateFlowLayout :::::::......

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    TagModel *tagModel = self.tagModels[indexPath.row];
    
    CGFloat width = tagModel.contentSize.width + self.tagInsets.left + self.tagInsets.right;
    if (width < self.mininumTagWidth) {
        width = self.mininumTagWidth;
    }
    if (width > self.maximumTagWidth) {
        width = self.maximumTagWidth;
    }    
    
    return CGSizeMake(width, self.tagHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.interitemSpace;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.lineSpace;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return self.contentInsets;
}



#pragma mark - Getter and Setter 

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        _flowLayout = [[FMEqualSpaceFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:_flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        
        [_collectionView registerClass:[TagCell class] forCellWithReuseIdentifier:tagCellID];
        
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _flowLayout.delegate = self;
        
        _collectionView.allowsSelection = _allowsSelection;
        _collectionView.allowsMultipleSelection = _allowsMultipleSelection;
     
    }
    
    __weak typeof(self) wself = self;
    
    _flowLayout.contentHeightBlock = ^(CGFloat allContentHeight){
        
        wself.frame = CGRectMake(wself.frame.origin.x, wself.frame.origin.y, wself.frame.size.width, allContentHeight);
        
        wself.tagsViewHeightBlock(allContentHeight);
    };
        
    
    return _collectionView;
}


- (NSUInteger)selectedIndex {
    return self.collectionView.indexPathsForSelectedItems.firstObject.row;
}

- (NSMutableArray<TagModel *> *)tagModels {
    if (!_tagModels) {
        _tagModels = [[NSMutableArray alloc] init];
    }
    return _tagModels;
}

- (NSArray<NSString *> *)tagsArray {
    return [self.tagsMutableArray copy];
}



@end

