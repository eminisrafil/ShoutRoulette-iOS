//
//  SRChoiceBox.m
//  ShoutRoulette
//
//  Created by emin on 5/12/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRChoiceBox.h"
//#import "SRDetailViewController.h"

@implementation SRChoiceBox

- (void)loadViewsFromBundle {
	NSString *class_name = NSStringFromClass([self class]);
	[[NSBundle mainBundle] loadNibNamed:class_name owner:self options:nil];
	[self addSubview:self.SRChoiceBox];
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self loadViewsFromBundle];
	}
	return self;
}

- (void)updateWithSRTopic:(SRTopic *)topic {
	self.SRTopicId = topic.topicId;
	self.agreeCount.text = [NSString stringWithFormat:@"%@", topic.agreeDebaters];
	self.disagreeCount.text =  [NSString stringWithFormat:@"%@", topic.disagreeDebaters];
	self.observeCount.text =  [NSString stringWithFormat:@"%@", topic.observers];
}

- (IBAction)buttonPress:(id)sender {
	int tag = [sender tag];
	switch (tag) {
		case 0:
			[self.delegate positionWasChoosen:@"agree" topicId:self.SRTopicId];
			break;
            
		case 1:
			[self.delegate positionWasChoosen:@"disagree" topicId:self.SRTopicId];
			break;
            
		case 2:
			[self.delegate positionWasChoosen:@"observe" topicId:self.SRTopicId];
			break;
            
		default:
			break;
	}
}

- (void)dealloc {
	self.SRChoiceBox = nil;
	self.SRTopicId = nil;
	self.delegate = nil;
	self.agreeCount = nil;
	self.disagreeCount = nil;
	self.observeCount = nil;
}

@end
