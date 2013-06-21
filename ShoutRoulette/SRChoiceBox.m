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

-(void) loadViewsFromBundle{
    NSString *class_name = NSStringFromClass([self class]);
    [[NSBundle mainBundle] loadNibNamed:class_name owner:self options:nil];
    [self addSubview:self.SRChoiceBox];
    
}

-(id)initWithLabel:(NSDictionary *)labels andTopicID:(NSNumber *)topicId andFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadViewsFromBundle];
        self.SRTopicId = topicId;
        self.agreeCount.text = [NSString stringWithFormat: @"%@",labels[@"agreeDebaters"]];
        self.disagreeCount.text =  [NSString stringWithFormat: @"%@",labels[@"disagreeDebaters"]];
        self.observeCount.text =  [NSString stringWithFormat: @"%@",labels[@"observers"]];
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
