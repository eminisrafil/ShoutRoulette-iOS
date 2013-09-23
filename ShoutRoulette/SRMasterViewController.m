
//
//  SRMasterViewController.m
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRMasterViewController.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIScrollView+SVInfiniteScrolling.h"



@interface SRMasterViewController () {
    NSMutableArray *_objects;
}
@property NSInteger offset;
@end

@implementation SRMasterViewController

-(void) viewWillAppear:(BOOL)animated{
    //setup nav button
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
    
    //set offset for loading tabledata
    self.offset = 1;
    
    //configure container for posting shouts
    SRPostTopic *postShout = [[SRPostTopic alloc]initWithFrame:CGRectMake(0, 0, 320, 133)];
    [self.postShoutContainer addSubview:postShout];
    postShout.delegate = self;
    
    //Collapseable Click "TableView"
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CCUpdate:) name:@"CollapseClickUpdated" object:nil];
    self.CollapseClickCell.CollapseClickDelegate = self;
    [self loadTableData];
    
    //attach pulltorefresh/infinite scroll
    [self attachPullToRefresh:self.CollapseClickCell];
    self.CollapseClickCell.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
}

-(void)loadTableData{
    NSNumber *NSNumberOffset = @(self.offset);
    NSDictionary * param = @{@"?page=": NSNumberOffset};
    [[RKObjectManager sharedManager] getObjectsAtPath:@"http://srapp.herokuapp.com/" parameters:param success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
        NSArray* topicsArray = [mappingResult array];
        _objects = [topicsArray copy];
        if(self.isViewLoaded){
            [self.CollapseClickCell.pullToRefreshView stopAnimating];
            [self.CollapseClickCell.infiniteScrollingView stopAnimating];
            [self.CollapseClickCell reloadCollapseClick];
            
            NSLog(@"%d offset", self.offset);
        }
    }failure:^(RKObjectRequestOperation *operation, NSError *error){
        [self.CollapseClickCell.pullToRefreshView stopAnimating];
        [self noResults];
    }];
}

-(void)noResults{
    //clear table data
    UIView *retain = self.CollapseClickCell.subviews[0];
    [self.CollapseClickCell.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    //reset pull to refresh
    [self.CollapseClickCell removePullToRefresh];
    
    //load imageView
    UIImageView *noResultsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noInternet.png"]];
    
    //center it + add it
    noResultsImageView.frame = CGRectOffset(noResultsImageView.frame, (self.view.frame.size.width -  noResultsImageView.frame.size.width)/2, (self.view.frame.size.height -  noResultsImageView.frame.size.height)/2);
    [self.CollapseClickCell addSubview:noResultsImageView];
    
    //ensure contentsize large enough to allow pull to refresh
    self.CollapseClickCell.contentSize =CGSizeMake(320, 420+retain.frame.size.height);
    
    [self.CollapseClickCell addPullToRefreshWithActionHandler:^(void){
        [self loadTableData];
    }];
    //[self attachPullToRefresh:self.CollapseClickCell];
    
    
    [self statusUpdate:@"Try Again"];
}

-(void)attachPullToRefresh:(id)object{
    //pull to refresh
    [object addPullToRefreshWithActionHandler:^(void){
        [self loadTableData];
    }];
    
    
    //infinite scroll
    [object addInfiniteScrollingWithActionHandler:^(void){
        self.offset = self.offset + 1;
        [self loadTableData];
    }];
}

//update fading status UILabel at the bottom of the screen
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

#pragma mark - Posting a new shout/topic
//open/close container for posting shouts
-(void)showPostShout{
    [self.view endEditing:YES];
    CGRect newCCFrame = self.CollapseClickCell.frame;
    CGRect newPostShoutFrame = self.postShoutContainer.frame;
    
    if ([self isPostShoutContainerOpen]) {
        newCCFrame.origin.y -= 133;
        newPostShoutFrame.origin.y -= 133;
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.postShoutContainer.alpha = 0;
            self.CollapseClickCell.frame= newCCFrame;
            self.postShoutContainer.frame = newPostShoutFrame;
        } completion: ^(BOOL finished){
            //delete
        }];
    } else{
        newCCFrame.origin.y += 133;
        newPostShoutFrame.origin.y += 133;
        [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.postShoutContainer.alpha = 1;
            self.CollapseClickCell.frame= newCCFrame;
            self.postShoutContainer.frame = newPostShoutFrame;
        } completion: ^(BOOL finished){
            //delete
        }];
    }
}

-(BOOL) isPostShoutContainerOpen{
    return (self.CollapseClickCell.frame.origin.y==0)? NO : YES;
}

//New shout was sent
-(void)postTopicButtonPressed:(NSString *)contents {
    NSDictionary *newTopic = @{@"topic":contents};
    [[RKObjectManager sharedManager] postObject:nil path:@"topics/new" parameters:newTopic success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
            if([self isPostShoutContainerOpen]){
                [self showPostShout];
            }
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"We weren't able to post your shout. Try again soon!" delegate:nil cancelButtonTitle:@"Sure" otherButtonTitles:nil, nil];
        [alert show];
    }];
}
#pragma mark -Collapse Click
-(void) CCUpdate:(NSNotification*)notification{
    //Do something when scrollview is updated
}

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

//Displays content for expanded cell
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

-(void)didClickCollapseClickCellAtIndex:(int)index isNowOpen:(BOOL)open{

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //close Post Shout Container
    if (self.CollapseClickCell.frame.origin.y>0) {
        [self showPostShout];
    }

    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        //self.RoomViewController = [segue destinationViewController];

        SRDetailViewController *newRoomVC = [segue destinationViewController];
        newRoomVC.room = sender;
    }
}

@end
