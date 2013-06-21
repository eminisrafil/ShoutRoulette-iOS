
//
//  SRMasterViewController.m
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRMasterViewController.h"
#import "SRDetailViewController.h"
#import "UIScrollView+SVPullToRefresh.h"



@interface SRMasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation SRMasterViewController

-(void) viewWillAppear:(BOOL)animated{
    UIImage *rightButtonImage = [UIImage imageNamed:@"logo"];
    
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(0, 0, 30, 30)];
    [rightButton addTarget:self action:@selector(showPostShout) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setImage:rightButtonImage forState:UIControlStateNormal];
    
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [SRAPI sharedInstance];
    
    //configure container for posting shouts
    SRPostTopic *postShout = [[SRPostTopic alloc]initWithFrame:CGRectMake(0, 0, 320, 133)];
    [self.postShoutContainer addSubview:postShout];
    postShout.delegate = self;
    
    //MyCollapseable Click "TableView"
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CCUpdate:) name:@"CollapseClickUpdated" object:nil];
    myCollapseClick.CollapseClickDelegate = self;
    [self loadTableData];
}

-(void) CCUpdate:(NSNotification*)notification{
    [myCollapseClick removePullToRefresh];
    [myCollapseClick addPullToRefreshWithActionHandler:^(void){
        [self loadTableData];
    }];

}

//open/close container for posting shouts
-(void)showPostShout{
    [self.view endEditing:YES];
    CGRect newCCFrame = myCollapseClick.frame;
    CGRect newPostShoutFrame = self.postShoutContainer.frame;
    
    if ([self isPostShoutContainerOpen]) {
        newCCFrame.origin.y -= 133;
        newPostShoutFrame.origin.y -= 133;
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.postShoutContainer.alpha = 0;
            myCollapseClick.frame= newCCFrame;
            self.postShoutContainer.frame = newPostShoutFrame;
        } completion: ^(BOOL finished){
            //delete
        }];
    } else{
        newCCFrame.origin.y += 133;
        newPostShoutFrame.origin.y += 133;
        [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.postShoutContainer.alpha = 1;
            myCollapseClick.frame= newCCFrame;
            self.postShoutContainer.frame = newPostShoutFrame;
        } completion: ^(BOOL finished){
            //delete
        }];
    }
}

-(BOOL) isPostShoutContainerOpen{
    return (myCollapseClick.frame.origin.y==0)? NO : YES;
}

//New shout was sent
-(void)postTopicButtonPressed:(NSString *)contents {
    NSDictionary *newTopic = @{@"topic":contents};
    [[RKObjectManager sharedManager] postObject:nil path:@"topics/new" parameters:newTopic
     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
         if([self isPostShoutContainerOpen]){
             [self showPostShout];
         }
    } failure:^(RKObjectRequestOperation *operation, NSError *error){

    }];
}

-(void)loadTableData{    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"http://srapp.herokuapp.com/" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
        NSArray* topicsArray = [mappingResult array];
        _objects = [topicsArray copy];
        if(self.isViewLoaded){
            [myCollapseClick.pullToRefreshView stopAnimating];
            [myCollapseClick reloadCollapseClick];
            //[self statusUpdate:@"Updated"];
        }
    }failure:^(RKObjectRequestOperation *operation, NSError *error){
        [myCollapseClick.pullToRefreshView stopAnimating];
        [self noResults];
    }];
}

-(void)noResults{
    //clear table data
    [myCollapseClick.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    //load imageView
    UIImageView *noResultsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noInternet.png"]];
    
    //center it + add it
    noResultsImageView.frame = CGRectOffset(noResultsImageView.frame, (self.view.frame.size.width -  noResultsImageView.frame.size.width)/2, (self.view.frame.size.height -  noResultsImageView.frame.size.height)/2);
    [myCollapseClick addSubview:noResultsImageView];
    
    //ensure contentsize large enough to allow pull to refresh
     myCollapseClick.contentSize =CGSizeMake(320, 430);
    
    [self attachPullToRefresh:myCollapseClick];
    
    [self statusUpdate:@"Try Again"];
}

-(void)attachPullToRefresh:(id)object{
    [object removePullToRefresh];
    [object addPullToRefreshWithActionHandler:^(void){
        [self loadTableData];
    }];
}

-(void)statusUpdate:(NSString *) message{
    
    self.statusLabel.text = message;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.FromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat:1.0f];
    animation.autoreverses = YES;
    animation.BeginTime = CACurrentMediaTime()+.8;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseOut];
    animation.removedOnCompletion = NO;
    animation.duration = 2;
    
    [self.statusLabelContainer.layer addAnimation:animation forKey:nil];
}

#pragma mark -Collapse Click
//returns stats for each topic
-(NSDictionary*)statsForCollapseClick:(int)index{
    SRTopic *loadedTopic = [_objects objectAtIndex:index];
    NSDictionary *stats = @{
                        @"agreeDebaters": loadedTopic.agreeDebaters,
                        @"disagreeDebaters": loadedTopic.disagreeDebaters,
                        @"observers": loadedTopic.observers
                        };
    return stats;
}

-(int) numberOfCellsForCollapseClick{
    return _objects.count;
}

-(NSString *)titleForCollapseClickAtIndex:(int)index{
    SRTopic *loadedTopic = [_objects objectAtIndex:index];
    return loadedTopic.title;
}


-(UIView *)viewForCollapseClickContentViewAtIndex:(int)index{
    SRTopic *loadedTopic = [_objects objectAtIndex:index];
    SRChoiceBox *newBox = [[SRChoiceBox alloc] initWithLabel:[self statsForCollapseClick:index] andTopicID:loadedTopic.topicId andFrame: CGRectMake(5, 5, 310, 150)];
    newBox.delegate = self;
    return newBox;
}

//Delegate for SRChoiceBox - user chooses Agree/Disagree/Observe
-(void) buttonWasPressed:(NSString *)choice topicId:(NSNumber *)topicId{
    if([choice isEqualToString:@"observe"]){
        return;
    }
    SRRoom *room = [[SRRoom alloc] init];
    room.position  = choice;
    room.topicId = topicId;
    [self performSegueWithIdentifier:@"showDetail" sender:room];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (myCollapseClick.frame.origin.y>0) {
        [self showPostShout];
    }
    if ([[segue identifier] isEqualToString:@"showDetail"]) {       
        [[segue destinationViewController] setDetailItem:sender];
    }
}

@end
