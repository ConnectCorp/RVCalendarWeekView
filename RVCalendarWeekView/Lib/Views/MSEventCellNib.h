//
//  MSEventCellNib.h
//  RVCalendarWeekView
//
//  Created by Kyle Fleming on 10/14/16.
//  Copyright © 2016 Kyle Fleming. All rights reserved.
//

#import "MSEventCell.h"

@interface MSEventCellNib : MSEventCell

@property (nonatomic, strong) NSString *nibName;

/**
 * NSBundle to load the nib from. If nil, defaults to `[NSBundle mainBundle]`.
 */
@property (nonatomic, strong) NSBundle *bundle;

- (void)didLoadNib;

@end
