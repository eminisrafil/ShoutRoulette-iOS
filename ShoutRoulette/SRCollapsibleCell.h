//
//  SRCollapsibleCell.h
//  ShoutRoulette
//
//  Created by emin on 8/29/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRTopic.h"

@interface SRCollapsibleCell : UITableViewCell

@property (strong, nonatomic) NSNumber *topicId;
@property (strong, nonatomic) NSDictionary *topicStats;

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;
@property (weak, nonatomic) IBOutlet UILabel *agreeDebaters;
@property (weak, nonatomic) IBOutlet UILabel *disagreeDebaters;
@property (weak, nonatomic) IBOutlet UILabel *observers;

@property (weak, nonatomic) IBOutlet UIImageView *arrow;
@property (weak, nonatomic) IBOutlet UIView *SRCollapsibleCellContent;

- (void)formatTitle:(NSString *)title;
- (void)updateWithTopic:(SRTopic *)topic;

@end
