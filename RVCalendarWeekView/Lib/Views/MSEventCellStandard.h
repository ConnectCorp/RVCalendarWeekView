//
//  MSEventCellStandard.h
//  RVCalendarWeekView
//
//  Created by Kyle Fleming on 10/14/16.
//  Copyright © 2016 Kyle Fleming. All rights reserved.
//

#import "MSEventCell.h"

@interface MSEventCellStandard : MSEventCell

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *location;
@property (nonatomic, strong) UIView *bottomDragHandle;

- (void)updateColors;

- (NSDictionary *)titleAttributesHighlighted:(BOOL)highlighted;
- (NSDictionary *)subtitleAttributesHighlighted:(BOOL)highlighted;
- (UIColor *)backgroundColorHighlighted:(BOOL)selected;
- (UIColor *)textColorHighlighted:(BOOL)selected;
- (UIColor *)borderColor;

@end
