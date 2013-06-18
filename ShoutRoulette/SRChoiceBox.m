//
//  SRChoiceBox.m
//  ShoutRoulette
//
//  Created by emin on 5/12/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRChoiceBox.h"
#import "SRDetailViewController.h"

@implementation SRChoiceBox
@synthesize SRChoiceBox = _SRChoiceBox, SRLabel =_SRLabel, SRTopicId = _SRTopicId, delegate;

-(void) loadViewsFromBundle{
    NSString *class_name = NSStringFromClass([self class]);
    [[NSBundle mainBundle] loadNibNamed:class_name owner:self options:nil];
    _SRLabel.text = @"Hello";
    [self addSubview:self.SRChoiceBox];
    
}

-(id)initWithLabel:(NSString *)label andTopicID:(NSNumber *)topicId andFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadViewsFromBundle];
        _SRLabel.text = label;
        _SRTopicId = topicId;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadViewsFromBundle];
    }
    return self;
}


- (IBAction)buttonPress:(id) sender {

    int tag = [sender tag];
    switch (tag) {
        case 0:
            [self.delegate  buttonWasPressed:@"agree" topicId:self.SRTopicId];
            break;
        case 1:
            [self.delegate buttonWasPressed: @"disagree" topicId:self.SRTopicId];
            break;
        case 2:
            [self.delegate buttonWasPressed: @"observe" topicId:self.SRTopicId];
            break;
        default:
            break;
    }
}
@end
