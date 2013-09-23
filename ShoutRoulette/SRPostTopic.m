//
//  SRPostTopic.m
//  ShoutRoulette
//
//  Created by emin on 5/30/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRPostTopic.h"

@implementation SRPostTopic


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSString *class_name = NSStringFromClass([self class]);
        [[NSBundle mainBundle] loadNibNamed:class_name owner:self options:nil];
        [self addSubview:self.SRPostTopic];
        
        self.textView.delegate = self;
        UIImage *textFieldImage = [UIImage imageNamed:@"shoutTextField"];
        [self.textView setBackgroundColor:[UIColor colorWithPatternImage:textFieldImage]];       
    }
    return self;
}


-(IBAction)post:(id)sender{
    
    NSString *textViewContent = self.textView.text;
    if ([self validatePost:textViewContent]){
        [self.textView resignFirstResponder];
        [self.delegate postTopicButtonPressed:textViewContent];
    } else {
        
        NSString * alertMessage =[NSString stringWithFormat:@"Shouts should be between %i-%i characters", kMinPostLength, kMaxPostLength];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You Big Dummy" message:alertMessage delegate:nil cancelButtonTitle:@"Sorry, ShoutRoulette" otherButtonTitles:nil, nil];
        [alert show];
    }

}
-(bool)validatePost:(NSString *) post{
    if (post.length > kMinPostLength && post.length < kMaxPostLength) {
        return YES;
    } else {
        return NO;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.textView resignFirstResponder];
}


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]){
        [self.textView resignFirstResponder];
        return NO;
    }
    
    NSInteger newLength = (textView.text.length - range.length) + text.length;
    if(newLength <= kMaxPostLength)
    {
        return YES;
    } else {
        NSInteger emptySpace = kMaxPostLength - (textView.text.length - range.length);
        textView.text = [[[textView.text substringToIndex:range.location]
                          stringByAppendingString:[text substringToIndex:emptySpace]]
                          stringByAppendingString:[textView.text substringFromIndex:(range.location + range.length)]];
        return NO;
    }
    
    
}


@end
