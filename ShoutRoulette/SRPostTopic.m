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
        UIImage *textFieldImage = [UIImage imageNamed:@"shoutTextField"];
        [self.textField setBackgroundColor:[UIColor colorWithPatternImage:textFieldImage]];
        
        
        
    }
    return self;
}


-(IBAction)post:(id)sender{
    [self.textField resignFirstResponder];
    NSString *textFieldContent = self.textField.text;
    if ([self validatePost:textFieldContent]){
        [self.delegate postTopicButtonPressed:textFieldContent];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You Big Dummy" message:@"Shouts should be between 4-144 characters" delegate:nil cancelButtonTitle:@"Sorry, ShoutRoulette" otherButtonTitles:nil, nil];
        [alert show];
    }
    //NSLog(textFieldContent);

}
-(bool)validatePost:(NSString *) post{
    if (post.length >3 && post.length<145) {
        return YES;
    } else {
        return NO;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.textField resignFirstResponder];
    
    //[yourSecondTextField resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    return NO;
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }else{
        return YES;
    }
}@end
