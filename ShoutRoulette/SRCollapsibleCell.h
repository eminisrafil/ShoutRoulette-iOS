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


@property (strong) NSNumber *topicId;
@property (strong) NSDictionary *topicStats;

@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *subtitle;
@property (strong) IBOutlet UILabel *agreeDebaters;
@property (weak, nonatomic) IBOutlet UILabel *disagreeDebaters;
@property (weak, nonatomic) IBOutlet UILabel *observers;


@property (weak, nonatomic) IBOutlet UIImageView *arrow;
@property (strong, nonatomic) IBOutlet UIView *SRCollapsibleCellContent;

//-(void)updateWithTopic:(NSDictionary *) stats;
-(void)formatTitle:(NSString *)title;
@end
