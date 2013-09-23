
//
//  SRMasterViewController.m
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRMasterViewController2.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIScrollView+SVInfiniteScrolling.h"




@interface SRMasterViewController2 () {
   
}
@property NSInteger offset;
@property NSInteger totalPages;
@property NSMutableArray *topicsArray;
@property bool isPaginatorLoading;

typedef void(^animationBlock)(BOOL);

@end

@implementation SRMasterViewController2



- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configureTableView];
    [self configureNavBar];
    [self configurePostShoutContainer];
    [SRAPI sharedInstance];
    //[self loadTableData];
    [self paginate];
    self.openTokHandler = [SROpenTokVideoHandler new];
      
    
}

-(void) configureNavBar{
    //setup shout button - Displays container for posting shouts
    UIImage *rightButtonImage = [UIImage imageNamed:@"logo"];
    
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(0, 0, 30, 30)];
    [rightButton addTarget:self action:@selector(showPostShout) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setImage:rightButtonImage forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    
    UIImage *leftButtonImage = [UIImage imageNamed:@"shuffle.png"];
    UIImage *leftButtonImagePressed = [UIImage imageNamed:@"shufflePressed.png"];
    
    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0, 0, 30, 24)];
    [leftButton addTarget:self action:@selector(joinRandomRoom) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setImage:leftButtonImage forState:UIControlStateNormal];
    [leftButton setImage:leftButtonImagePressed forState:UIControlStateHighlighted];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
}

-(void)joinRandomRoom{
    NSMutableArray *activeTopics = [NSMutableArray new];
    for(SRTopic *topic in self.topicsArray){
        if([topic.agreeDebaters integerValue]>0 || [topic.disagreeDebaters integerValue] >0){
            [activeTopics addObject:topic];
        }
    }
    int numberOfActiveTopics = activeTopics.count;
    
    if(numberOfActiveTopics>0){
        int random = arc4random() % numberOfActiveTopics;
        SRTopic *randomTopic = (SRTopic*) activeTopics[random];
        SRRoom *randomRoom = [[SRRoom alloc] init];
        
        if ([randomTopic.agreeDebaters integerValue]> [randomTopic.agreeDebaters integerValue]){
            randomRoom.position  = @"disagree";
        } else if ([randomTopic.agreeDebaters integerValue]< [randomTopic.agreeDebaters integerValue]){
            randomRoom.position  = @"agree";
        } else{
            int r = arc4random() %2;
            if (r==0) {
                randomRoom.position  = @"agree";
            } else{
                randomRoom.position  = @"disagree";
            }
        }
        randomRoom.topicId = randomTopic.topicId;
        [self performSegueWithIdentifier: @"showDetail2" sender:randomRoom];
    } else{
        int random = arc4random() % self.topicsArray.count;
        SRTopic *randomTopic = (SRTopic*) self.topicsArray[random];
        SRRoom *randomRoom = [[SRRoom alloc] init];
        int r = arc4random() %2;
        if (r==0) {
            randomRoom.position  = @"agree";
        } else{
            randomRoom.position  = @"disagree";
        }
        
        randomRoom.topicId = randomTopic.topicId;
        [self performSegueWithIdentifier: @"showDetail2" sender:randomRoom];
    }
    
}

-(void) configureTableView{
    //set offset for loading tabledata
    self.offset = 1;
    NSLog(@"offset in config tableview: %i", self.offset);
    
//    //set delegate
//    self.shoutsTableView.delegate = self;
//    self.shoutsTableView.dataSource = self;

    
    //add pull to refresh controls
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.shoutsTableView addSubview:refreshControl];
    
    //add infinite scrolling
    [self.shoutsTableView addInfiniteScrollingWithActionHandler:^(void){
        self.offset += 1;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //[self loadTableData];
            [self paginate];
            double delayInSeconds = 0.8;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.shoutsTableView.infiniteScrollingView stopAnimating];
            });
        });
    }];
    
    //configure infinite scrolling
    self.shoutsTableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    
    //close all cells
    self.openCellIndex = nil;
    
    //Smooth scrolling
    self.shoutsTableView.layer.shouldRasterize = YES;
    self.shoutsTableView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    //[self.shoutsTableView setDecelerationRate:UIScrollViewDecelerationRateFast];
    
    //self.shoutsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"logo.png"]];
}
-(void)configurePostShoutContainer{
    //configure container for posting shouts
    SRPostTopic *postShout = [[SRPostTopic alloc]initWithFrame:CGRectMake(0, 0, 320, 133)];
    [self.postShoutContainer addSubview:postShout];
    postShout.delegate = self;
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    self.offset = 1;
    self.openCellIndex = nil;
    //stop refresh after successful AJAX call for topics
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self paginate];
        double delayInSeconds = 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
           [refreshControl endRefreshing];
        });
    });
}

-(void)paginate{
    // Create weak reference to self to use within the paginators completion block
    __weak typeof(self) weakSelf = self;
    NSLog(@"offset in load table data %i", self.offset);
    // Setup paginator
    if (!self.paginator) {
        self.paginator.perPage = 20;
        
        NSString *requestString = [NSString stringWithFormat:@"?page=:currentPage&per_page=:perPage"];
        
        self.paginator = [[RKObjectManager sharedManager] paginatorWithPathPattern:requestString];

        
        [self.paginator setCompletionBlockWithSuccess:^(RKPaginator *paginator, NSArray *objects, NSUInteger page) {
            
            NSMutableArray* topicsArrayTemp = [objects mutableCopy];
            weakSelf.isPaginatorLoading = NO;
            //self.totalPages = topicsArrayTemp
            
            if(weakSelf.offset==1){
                [weakSelf replaceRowsInTableView:topicsArrayTemp];
            }else  {
                [weakSelf insertRowsInTableView:topicsArrayTemp];
            }

            for(id x in objects){
                NSLog(@"%@", objects);
            }
            
        } failure:^(RKPaginator *paginator, NSError *error) {
            NSLog(@"Failure: %@", error);
            weakSelf.isPaginatorLoading = NO;
            [weakSelf.self noResults];
        }];
    }
    
    if(!weakSelf.isPaginatorLoading){
        weakSelf.isPaginatorLoading = YES;
        [self.paginator loadPage:self.offset];
    }
    
}



-(void)insertRowsInTableView:(NSMutableArray*)topics{
    NSMutableArray *temp =[NSMutableArray new];
    
    //add error checking here
    //when nothing loads this gets triggered
    int lastRowNumber = [self.shoutsTableView numberOfRowsInSection:0]-1;

    for( SRTopic* topic in topics){
        if(![self.topicsArray containsObject:topic]){
            [self.topicsArray addObject:topic];
            NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
            [temp addObject:ip];
            ++lastRowNumber;
        }
    }
    
    [self.shoutsTableView beginUpdates];
    [self.shoutsTableView  insertRowsAtIndexPaths:temp
                                 withRowAnimation:UITableViewRowAnimationTop];
    [self.shoutsTableView endUpdates];
    
    if(temp.count ==0){
        [self statusUpdate:@"No New Topics. Check Back Soon!"];
        [self.shoutsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastRowNumber-6 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        self.offset--;
    }
}

-(void)replaceRowsInTableView:(NSMutableArray*)topics{
    self.topicsArray = topics;
    
    [UIView animateWithDuration:.3 delay:.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.shoutsTableView.layer.opacity = 0;
        
    } completion: ^(BOOL finished){
        CATransition *animation = [CATransition animation];
        self.shoutsTableView.layer.opacity = 1;
        [animation setType:kCATransitionMoveIn];
        [animation setSubtype:kCATransitionFromTop];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [animation setFillMode:kCAFillModeForwards];
        [animation setDuration:1];
        [[self.shoutsTableView layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
        [self.shoutsTableView reloadData];
    }];
}

-(void)noResults{
    double delayInSeconds = 0.6;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self performSegueWithIdentifier:@"noResults" sender:nil];
    });
}


#pragma mark - Posting a new shout/topic
//open/close container for posting shouts
-(void)showPostShout{
    [self.view endEditing:YES];
    CGRect newTableViewFrame = self.shoutsTableView.frame;
    CGRect newPostShoutFrame = self.postShoutContainer.frame;
    
    if ([self isPostShoutContainerOpen]) {
        newTableViewFrame.origin.y -= 133;
        newPostShoutFrame.origin.y -= 133;
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.postShoutContainer.alpha = 0;
            self.shoutsTableView.frame= newTableViewFrame;
            self.postShoutContainer.frame = newPostShoutFrame;
        } completion: ^(BOOL finished){
            //delete
        }];
    } else{
        newTableViewFrame.origin.y += 133;
        newPostShoutFrame.origin.y += 133;
        [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.postShoutContainer.alpha = 1;
            self.shoutsTableView.frame= newTableViewFrame;
            self.postShoutContainer.frame = newPostShoutFrame;
        } completion: ^(BOOL finished){
            //delete
        }];
    }
}

-(BOOL) isPostShoutContainerOpen{
    return (self.postShoutContainer.frame.origin.y<0)? NO : YES;
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
    
    [self.statusLabel.layer addAnimation:animation forKey:nil];
}

//Post a new shout to the Server
-(void)postTopicButtonPressed:(NSString *)contents {
    //set up params
    NSDictionary *newTopic = @{@"topic":contents};
    
    //send new topic posting
    [[RKObjectManager sharedManager] postObject:nil path:@"topics/new" parameters:newTopic success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
        if([self isPostShoutContainerOpen]){
            //close post box if it's open
            [self showPostShout];
        }
        [self statusUpdate:@"Topic Posted!"];
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"We weren't able to post your shout. Try again soon!" delegate:nil cancelButtonTitle:@"Sure" otherButtonTitles:nil, nil];
        [alert show];
    }];
}


//returns stats for each topic
-(NSDictionary*)statsForCollapseClick:(int)index{
    SRTopic *loadedTopic = [self.topicsArray objectAtIndex:index];
    NSDictionary *stats = @{
                            @"agreeDebaters": loadedTopic.agreeDebaters,
                            @"disagreeDebaters": loadedTopic.disagreeDebaters,
                            @"observers": loadedTopic.observers
                            };
    return stats;
}



//Delegate for SRChoiceBox - user chooses Agree/Disagree/Observe
-(void) buttonWasPressed:(NSString *)choice topicId:(NSNumber *)topicId{
    if([choice isEqualToString:@"observe"]){
        return;
    }
    SRRoom *room = [[SRRoom alloc] init];
    room.position  = choice;
    room.topicId = topicId;
    
    [self performSegueWithIdentifier:@"showDetail2" sender:room];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //close Post Shout Container
    if ([self isPostShoutContainerOpen]) {
        [self showPostShout];
    }
    
    if ([[segue identifier] isEqualToString:@"showDetail2"]) {
        if(self.openTokHandler){
            [self.openTokHandler safetlyCloseSession];
        }
   
        SRDetailViewController *newRoomVC = [segue destinationViewController];
        newRoomVC.room = sender;
        newRoomVC.openTokHandler = self.openTokHandler; 
    }
}

#pragma mark - UITABLEVIEW
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.topicsArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //static NSString *CellIdentifier = @"SRCollapsibleCell";
    static NSString *CellIdentifier2 = @"SRCollapsibleCellClosed";
    SRCollapsibleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
    if (cell == nil) {
        cell = [[SRCollapsibleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
    }

    // Set the data for this cell:
    SRTopic *newTopic = [self.topicsArray objectAtIndex:indexPath.row];
    cell.subtitle.text = nil;
    [cell formatTitle:newTopic.title];
    cell.topicId = newTopic.topicId;
    cell.topicStats = [self statsForCollapseClick:indexPath.row];
    cell.agreeDebaters.text = [NSString stringWithFormat:@"%@", newTopic.agreeDebaters];
    cell.disagreeDebaters.text = [NSString stringWithFormat:@"%@", newTopic.disagreeDebaters];
    cell.observers.text = [NSString stringWithFormat:@"%@", newTopic.observers];
    
    if([self isCellOpen:indexPath]){
        CGAffineTransform transformation = CGAffineTransformMakeRotation(M_PI/2);
        cell.arrow.transform = transformation;
        if(![self hasChoiceBox:cell]){
            [self insertChoiceBox:cell];
        }
    } else{
        CGAffineTransform transformation = CGAffineTransformMakeRotation(0);
        cell.arrow.transform = transformation;
    }    
    [self.shoutsTableView setSeparatorStyle: UITableViewCellSeparatorStyleSingleLine];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([self isCellOpen:indexPath]){
        [self closeCellAtIndexPath:indexPath];
    }
    else{
        [self closeCellAtIndexPath:self.openCellIndex];
        [self openCellAtIndexPath:indexPath];
    }
    [tableView beginUpdates];
    [tableView endUpdates];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView: (UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath {

    if([indexPath isEqual:self.openCellIndex]){
        return 217.0;
    } else {
        return 63.0;
    }
}

-(void)rotateCellArrowAtIndexPath:(NSIndexPath*)indexPath willOpen:(bool)willOpen Animated:(bool)animated{
    // Change Arrow orientation
    SRCollapsibleCell *cell = (SRCollapsibleCell*) [self.shoutsTableView cellForRowAtIndexPath:indexPath];
    
    CGAffineTransform transformation;
    
    if(willOpen){
        transformation = CGAffineTransformMakeRotation(M_PI/2);
    } else {
        transformation = CGAffineTransformMakeRotation(0);
    }
    
    if(animated){
        [UIView animateWithDuration:.2 delay:0 options:nil animations:^{
            cell.arrow.transform = transformation;
         }  completion:^(BOOL finished){
         
         }];
    }
    else{
        cell.arrow.transform = transformation;
    }
}

-(void)rotateCellArrowCloseAtIndexPAth:(NSIndexPath*)indexPath{
    // Change Arrow orientation
    SRCollapsibleCell *cell = (SRCollapsibleCell*) [self.shoutsTableView cellForRowAtIndexPath:indexPath];
    CGAffineTransform transform = CGAffineTransformMakeRotation(0);
    //cell.arrow = transform;
}

-(BOOL)isCellOpen:(NSIndexPath *)indexPath{
    return [indexPath isEqual:self.openCellIndex];
}

-(void)closeCellAtIndexPath:(NSIndexPath*)indexPath{
    NSLog(@"Cell closing");
    [self rotateCellArrowAtIndexPath:indexPath willOpen:NO Animated:YES];
    [self removeSRChoiceBoxFromCellAtIndexPath:indexPath];
    self.openCellIndex = nil;
}

-(void)openCellAtIndexPath:(NSIndexPath*)indexPath{
    NSLog(@"Cell Opening");
    [self rotateCellArrowAtIndexPath:indexPath willOpen:YES Animated:YES];
    SRCollapsibleCell *cell = (SRCollapsibleCell*)[self.shoutsTableView cellForRowAtIndexPath:indexPath];
    [self insertChoiceBox:cell];
    self.openCellIndex = indexPath;
}

-(void)removeSRChoiceBoxFromCellAtIndexPath:(NSIndexPath *)indexPath{
    SRCollapsibleCell *cell = (SRCollapsibleCell*) [self.shoutsTableView cellForRowAtIndexPath:indexPath];
    NSLog(@"Title of cell being closed:%@", cell.title.text);
    for(UIView *subview in cell.SRCollapsibleCellContent.subviews){
        if([subview isKindOfClass:[SRChoiceBox class]]){
            //NSLog(@"SRCHOICEBOX REMOVED");
            [subview removeFromSuperview];
        }
    }
}


-(void)insertChoiceBox: (SRCollapsibleCell*)cell{
    SRChoiceBox *newBox = [[SRChoiceBox alloc] initWithLabel:cell.topicStats andTopicID:cell.topicId andFrame: CGRectMake(0, 0, 310, 141)];
    newBox.delegate = self;

    [cell.SRCollapsibleCellContent addSubview:newBox];
}

-(bool)hasChoiceBox:(SRCollapsibleCell *)cell{
    
    for(UIView *subview in cell.SRCollapsibleCellContent.subviews){
        if([subview isKindOfClass:[SRChoiceBox class]]){
            return true;
        }
    }
    return false;
}

@end




//-(int) numberOfCellsForCollapseClick{
//    return _objects.count;
//}
//
//-(NSString *)titleForCollapseClickAtIndex:(int)index{
//    SRTopic *loadedTopic = [_objects objectAtIndex:index];
//    return loadedTopic.title;
//}

//
//-(void)didClickCollapseClickCellAtIndex:(int)index isNowOpen:(BOOL)open{
//
//}
//Displays contents of expanded cell
//-(UIView *)viewForCollapseClickContentViewAtIndex:(int)index{
//    SRTopic *loadedTopic = [_objects objectAtIndex:index];
//    SRChoiceBox *newBox = [[SRChoiceBox alloc] initWithLabel:[self statsForCollapseClick:index] andTopicID:loadedTopic.topicId andFrame: CGRectMake(5, 5, 310, 150)];
//    newBox.delegate = self;
//    return newBox;
//}

//
//-(void)loadTableData{
//    //set up request params
//    NSLog(@"offset in load table data %i", self.offset);
//    NSDictionary * param = @{@"page": @(self.offset)};
//    
//    //make request
//    [[RKObjectManager sharedManager] getObjectsAtPath:@"http://srapp.herokuapp.com/" parameters:param success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
//        
//        NSMutableArray* topicsArrayTemp = [[mappingResult array] mutableCopy];
//        //self.totalPages = topicsArrayTemp
//        
//        if(self.offset==1){
//            [self replaceRowsInTableView:topicsArrayTemp];
//        }else if(self.offset <self.totalPages) {
//            [self insertRowsInTableView:topicsArrayTemp];
//        }
//        
//        
//    }failure:^(RKObjectRequestOperation *operation, NSError *error){
//        [self noResults];
//    }];
//}

////////////////////Eperiment


//
//-(void)blockAnimate:(NSMutableArray*)topics{
//    __block NSMutableArray* animationBlocks = [NSMutableArray new];
//    
//    float duration = 1;
//    
//    
//    
//    
//    
//    // getNextAnimation
//    // removes the first block in the queue and returns it
//    animationBlock (^getNextAnimation)() = ^{
//        
//        if ([animationBlocks count] > 0){
//            animationBlock block = (animationBlock)[animationBlocks objectAtIndex:0];
//            [animationBlocks removeObjectAtIndex:0];
//            return block;
//        } else {
//            return ^(BOOL finished){
//                animationBlocks = nil;
//            };
//        }
//    };
//    
//    [animationBlocks addObject:^(BOOL finished){
//        [UIView animateWithDuration:duration delay:1.2 options:UIViewAnimationOptionCurveLinear animations:^{
//            int lastRowNumber = [self.shoutsTableView numberOfRowsInSection:0]-1;
//            NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
//            [self.topicsArray addObject:topics[0]];
//            //                        [CATransaction begin];
//            //
//            //                        [self.shoutsTableView beginUpdates];
//            //                        [CATransaction setAnimationDuration:1];
//            //
//            //
//            //
//            //                        [CATransaction setCompletionBlock: ^{
//            //
//            //                        }];
//            //
//            //                        [self.shoutsTableView  insertRowsAtIndexPaths: [NSArray arrayWithObject:ip]
//            //                                         withRowAnimation: UITableViewRowAnimationTop];
//            //
//            //
//            //                        [self.shoutsTableView  endUpdates];
//            //
//            //                        [CATransaction commit];
//            
//            self.topicsArray = topics;
//            [self.shoutsTableView reloadData];
//            
//            
//            CATransition *animation = [CATransition animation];
//            [animation setType:kCATransitionMoveIn];
//            [animation setSubtype:kCATransitionFromTop];
//            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//            [animation setFillMode:kCAFillModeForwards];
//            [animation setDuration:2];
//            [[self.shoutsTableView layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
//            NSLog(@"%@", ip);
//            
//        } completion: getNextAnimation()];
//    }];
//    
//    
//    [animationBlocks addObject:^(BOOL finished){
//        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
//            int lastRowNumber = [self.shoutsTableView numberOfRowsInSection:0]-1;
//            NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
//            [self.shoutsTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
//            
//            NSLog(@"%@", ip);
//        } completion: getNextAnimation()];
//    }];
//    
//    // execute the first block in the queue
//    getNextAnimation()(YES);
//    
//}
//



//-(void)blockAnimate:(NSMutableArray*)topics{
//__block NSMutableArray* animationBlocks = [NSMutableArray new];
//
//    float duration = 5;
//
//
//
//
//
//    // getNextAnimation
//    // removes the first block in the queue and returns it
//    animationBlock (^getNextAnimation)() = ^{
//
//        if ([animationBlocks count] > 0){
//            animationBlock block = (animationBlock)[animationBlocks objectAtIndex:0];
//            [animationBlocks removeObjectAtIndex:0];
//            return block;
//        } else {
//            return ^(BOOL finished){
//                animationBlocks = nil;
//            };
//        }
//    };
//
//    [animationBlocks addObject:^(BOOL finished){
//        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
//            int lastRowNumber = [self.shoutsTableView numberOfRowsInSection:0]-1;
//            NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
//            [self.topicsArray addObject:topics[0]];
//            [self.shoutsTableView  insertRowsAtIndexPaths: [NSArray arrayWithObject:ip]
//                                         withRowAnimation: UITableViewRowAnimationTop];
//            NSLog(@"%@", ip);
//
//        } completion: getNextAnimation()];
//    }];
//
//
//    [animationBlocks addObject:^(BOOL finished){
//        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
//            int lastRowNumber = [self.shoutsTableView numberOfRowsInSection:0]-1;
//            NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
//            [self.shoutsTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
//            double delayInSeconds = 3;
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//
//            });
//
//
//            NSLog(@"%@", ip);
//        } completion: getNextAnimation()];
//    }];
//
//
//
//    [animationBlocks addObject:^(BOOL finished){
//        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
//            int lastRowNumber = [self.shoutsTableView numberOfRowsInSection:0]-1;
//            NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
//            [self.topicsArray addObject:topics[0]];
//            [self.shoutsTableView  insertRowsAtIndexPaths: [NSArray arrayWithObject:ip]
//                                         withRowAnimation: UITableViewRowAnimationTop];
//            NSLog(@"%@", ip);
//        } completion: getNextAnimation()];
//    }];
//
//
//    [animationBlocks addObject:^(BOOL finished){
//        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
//            int lastRowNumber = [self.shoutsTableView numberOfRowsInSection:0]-1;
//            NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
//            [self.shoutsTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
//            double delayInSeconds = 3;
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//
//            });
//            NSLog(@"%@", ip);
//        } completion:getNextAnimation()];
//    }];
//
//    // execute the first block in the queue
//    getNextAnimation()(YES);
//
//}






//////////////////////END


//        if(willOpen){
//
//            cell.arrow.transform = transform;
////            UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:cell.arrow.bounds];
////            [cell.arrow.layer setShadowColor:[[UIColor whiteColor] CGColor]];
////            [cell.arrow.layer setShadowOffset:CGSizeMake(5, -5)];
////            cell.arrow.layer.masksToBounds = NO;
////            cell.arrow.layer.shadowRadius = 5;
////            cell.arrow.layer.ShadowPath = shadowPath.CGPath;
//
//
//        } else{
//            CGAffineTransform transform = CGAffineTransformMakeRotation(0);
//            cell.arrow.transform = transform;
//
////            [cell.arrow.layer setShadowColor:nil];
////            [cell.arrow.layer setShadowOffset:CGSizeMake(0, 0)];
////            [cell.arrow.layer setShadowPath:nil];
//        }





//
//NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
//// Example: 1   UIKit                               0x00540c89 -[UIApplication _callInitializationDelegatesForURL:payload:suspended:] + 1163
//NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
//NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
//[array removeObject:@""];
//
//NSLog(@"Stack = %@", [array objectAtIndex:0]);
//NSLog(@"Framework = %@", [array objectAtIndex:1]);
//NSLog(@"Memory address = %@", [array objectAtIndex:2]);
//NSLog(@"Class caller = %@", [array objectAtIndex:3]);
//NSLog(@"Function caller = %@", [array objectAtIndex:4]);
//NSLog(@"Line caller = %@", [array objectAtIndex:5]);
//
//
//
//
//
//



