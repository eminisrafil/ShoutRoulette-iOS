//
//  SRChoiceBox.h
//  ShoutRoulette
//
//  Created by emin on 5/12/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRTopic.h"


@protocol SRChoiceBoxDelegate <NSObject>
- (void)positionWasChoosen:(NSString *)choice topicId:(NSNumber *)topicId;
@end

@interface SRChoiceBox : UIView

@property (weak, nonatomic) IBOutlet UIView *SRChoiceBox;
@property (weak, nonatomic) IBOutlet UILabel *agreeCount;
@property (weak, nonatomic) IBOutlet UILabel *disagreeCount;
@property (weak, nonatomic) IBOutlet UILabel *observeCount;

@property (strong, nonatomic) NSNumber *SRTopicId;
@property (weak, nonatomic) id <SRChoiceBoxDelegate> delegate;

- (IBAction)buttonPress:(id)sender;
- (void)updateWithSRTopic:(SRTopic *)topic;

@end
