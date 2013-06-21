//
//  SRPostTopic.h
//  ShoutRoulette
//
//  Created by emin on 5/30/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SRPostTopicDelegate <NSObject>
@required
-(void)postTopicButtonPressed: (NSString *)contents;
@end

@interface SRPostTopic : UIView<UITextViewDelegate>

@property IBOutlet SRPostTopic  *SRPostTopic;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) id<SRPostTopicDelegate> delegate;

-(IBAction)post:(id)sender;

@end

