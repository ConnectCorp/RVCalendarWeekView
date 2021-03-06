//
//  MSEventCellStandard.m
//  RVCalendarWeekView
//
//  Created by Kyle Fleming on 10/14/16.
//  Copyright © 2016 Kyle Fleming. All rights reserved.
//

#import "MSEventCellStandard.h"
#import "MSEventStandard.h"

#define MAS_SHORTHAND
#import "Masonry.h"
#import "UIColor+HexString.h"

@interface MSEventCellStandard ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UIView *borderView;

@end

@implementation MSEventCellStandard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        self.layer.shouldRasterize = YES;
        
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(0.0, 4.0);
        self.layer.shadowRadius = 5.0;
        self.layer.shadowOpacity = 0.0;
        
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.frame = self.contentView.bounds;
        self.gradientLayer.colors = @[(id)[self backgroundColorHighlighted:self.selected].CGColor, (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor];
        [self.contentView.layer addSublayer:self.gradientLayer];
        
        self.borderView = [UIView new];
        [self.contentView addSubview:self.borderView];
        
        CGFloat dragHandleHeight = 14.0;
        self.bottomDragHandle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, dragHandleHeight)];
        self.bottomDragHandle.backgroundColor = [UIColor clearColor];
        
        CGFloat triangleHeight = 10.0;
        CGFloat triangleInset = 4.0;
        UIView *triangleView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width - triangleHeight - triangleInset, dragHandleHeight - triangleHeight - triangleInset, triangleHeight, triangleHeight)];
        triangleView.backgroundColor = [UIColor whiteColor];
        triangleView.layer.mask = [self bottomRightTriangle];
        [self.bottomDragHandle addSubview:triangleView];
        
        [self.contentView addSubview:self.bottomDragHandle];
        
        self.title = [UILabel new];
        self.title.numberOfLines = 0;
        self.title.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.title];
        
        self.location = [UILabel new];
        self.location.numberOfLines = 0;
        self.location.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.location];
        
        [self updateColors];
        
        CGFloat borderWidth = 2.0;
        CGFloat contentMargin = 2.0;
        UIEdgeInsets contentPadding = UIEdgeInsetsMake(5.0, (borderWidth + 4.0), 2.0, 4.0);
        
        [self.borderView makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(self.height);
            make.width.equalTo(@(borderWidth));
            make.left.equalTo(self.left);
            make.top.equalTo(self.top);
        }];
        
        [triangleView makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(triangleHeight));
            make.width.equalTo(@(triangleHeight));
            make.right.equalTo(self.right).offset(-1 * triangleInset);
            make.bottom.equalTo(self.bottom).offset(-1 * triangleInset);
        }];
        
        [self.bottomDragHandle makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(dragHandleHeight));
            make.width.equalTo(self.width);
            make.left.equalTo(self.left);
            make.bottom.equalTo(self.bottom);
        }];
        
        [self.title makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.top).offset(contentPadding.top);
            make.left.equalTo(self.left).offset(contentPadding.left);
            make.right.equalTo(self.right).offset(-contentPadding.right);
        }];
        
        [self.location makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.title.bottom).offset(contentMargin);
            make.left.equalTo(self.left).offset(contentPadding.left);
            make.right.equalTo(self.right).offset(-contentPadding.right);
            make.bottom.lessThanOrEqualTo(self.bottom).offset(-contentPadding.bottom);
        }];
    }
    return self;
}

- (CAShapeLayer *)bottomRightTriangle {
    UIBezierPath *trianglePath = [UIBezierPath new];
    [trianglePath moveToPoint: (CGPoint){10, 0}];
    [trianglePath addLineToPoint: (CGPoint){0, 10}];
    [trianglePath addLineToPoint: (CGPoint){10, 10}];
    [trianglePath addLineToPoint: (CGPoint){10, 0}];
    
    CAShapeLayer *triangleLayer = [CAShapeLayer new];
    triangleLayer.path = trianglePath.CGPath;
    triangleLayer.frame = CGRectMake(0, 0, 10, 10);
    triangleLayer.fillColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
    triangleLayer.fillRule = kCAFillRuleNonZero;
    return triangleLayer;
}

#pragma mark - UICollectionViewCell
- (void)setSelected:(BOOL)selected
{
    if (selected && (self.selected != selected)) {
        [UIView animateWithDuration:0.1 animations:^{
            self.transform = CGAffineTransformMakeScale(1.025, 1.025);
            self.layer.shadowOpacity = 0.2;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                self.transform = CGAffineTransformIdentity;
            }];
        }];
    } else if (selected) {
        self.layer.shadowOpacity = 0.2;
    } else {
        self.layer.shadowOpacity = 0.0;
    }
    [super setSelected:selected]; // Must be here for animation to fire
    [self updateColors];
}


#pragma mark - MSEventCell
- (void)setEvent:(MSEvent *)event
{
    [super setEvent:event];
    if ([event isKindOfClass:MSEventStandard.class]) {
        MSEventStandard *eventStandard = (MSEventStandard *)event;
        self.title.attributedText = [[NSAttributedString alloc] initWithString:eventStandard.title attributes:[self titleAttributesHighlighted:self.selected]];
        self.location.attributedText = [[NSAttributedString alloc] initWithString:eventStandard.location attributes:[self subtitleAttributesHighlighted:self.selected]];
    }
    [self updateColors];
}


- (void)updateColors
{
    self.contentView.backgroundColor         = ([self backgroundHasGradient: self.selected] ? [UIColor clearColor] : [self backgroundColorHighlighted:self.selected]);
    self.gradientLayer.colors                = @[(id)[self backgroundColorHighlighted:self.selected].CGColor, (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor];
    self.gradientLayer.hidden                = ([self backgroundHasGradient: self.selected] ? false : true);
    self.borderView.backgroundColor          = [self borderColor];
    self.contentView.layer.borderColor       = [self borderColor].CGColor;
    self.borderView.hidden                   = [self borderIsAroundEntireCell];
    self.contentView.layer.borderWidth       = ([self borderIsAroundEntireCell] ? 2.0 : 0.0);
    self.title.textColor                     = [self textColorHighlighted:self.selected];
    self.location.textColor                  = [self textColorHighlighted:self.selected];
}

- (NSDictionary *)titleAttributesHighlighted:(BOOL)highlighted
{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.hyphenationFactor = 1.0;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    return @{
             NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0],
             NSForegroundColorAttributeName : [self textColorHighlighted:highlighted],
             NSParagraphStyleAttributeName : paragraphStyle
             };
}

- (NSDictionary *)subtitleAttributesHighlighted:(BOOL)highlighted
{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.hyphenationFactor = 1.0;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    return @{
             NSFontAttributeName : [UIFont systemFontOfSize:12.0],
             NSForegroundColorAttributeName : [self textColorHighlighted:highlighted],
             NSParagraphStyleAttributeName : paragraphStyle
             };
}

- (UIColor *)backgroundColorHighlighted:(BOOL)selected
{
    return selected ? [UIColor colorWithHexString:@"35b1f1"] : [[UIColor colorWithHexString:@"35b1f1"] colorWithAlphaComponent:0.2];
}

- (BOOL)backgroundHasGradient:(BOOL)selected {
    return NO;
}

- (UIColor *)textColorHighlighted:(BOOL)selected
{
    return selected ? [UIColor whiteColor] : [UIColor colorWithHexString:@"21729c"];
}

- (UIColor *)borderColor
{
    return [[self backgroundColorHighlighted:NO] colorWithAlphaComponent:1.0];
}

- (BOOL)borderIsAroundEntireCell {
    return NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.gradientLayer.frame = self.contentView.bounds;
}

@end
