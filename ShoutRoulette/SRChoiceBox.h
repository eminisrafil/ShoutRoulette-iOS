//
//  SRChoiceBox.h
//  ShoutRoulette
//
//  Created by emin on 5/12/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SRChoiceBoxDelegate <NSObject>
-(void)buttonWasPressed: (NSString *)choice topicId: (NSNumber *)topicId;
@end

@interface SRChoiceBox : UIView
- (IBAction)buttonPress:(id)sender;
-(id) initWithLabel: (NSString *)label andTopicID: (NSNumber *)topicId andFrame:(CGRect)frame;

@property (nonatomic, weak) IBOutlet UIView *SRChoiceBox;
@property (nonatomic, weak) IBOutlet UILabel *SRLabel;
@property (nonatomic, weak) NSNumber *SRTopicId;
@property (nonatomic, weak) id<SRChoiceBoxDelegate> delegate;


@end

