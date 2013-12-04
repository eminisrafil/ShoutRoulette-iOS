//
//  SRMasterViewController.m
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRMasterViewController.h"
#import "SRDetailViewController.h"
#import "SRCollapsibleCell.h"
#import "SRAPI.h"
#import "SRUserStats.h"

#import "SRUrlHelper.h"
#import "SRNavBarHelper.h"
#import "SRAnimationHelper.h"

#import "UIScrollView+SVPullToRefresh.h"
#import "UIScrollView+SVInfiniteScrolling.h"


@interface SRMasterViewController ()
@property NSInteger offset;
@property NSMutableArray *topicsArray;
@property BOOL isPaginatorLoading;

@end

@implementation SRMasterViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    
	[self configureTableView];
	[self configureNavBar];
	[SRAPI sharedInstance];
	[self paginate];
	self.openTokHandler = [SROpenTokVideoHandler new];
	[self configureNotifications];
	[self configurePostTopicContainer];
}



-(void)displayUserInstallationMessage{
    SRUserStats *userStats = [SRUserStats new];
    [userStats displayUserInstallationMessage];
    [userStats incrementStat:@"logins"];
}

- (void)configureNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchNewTopicsAndReloadTableData) name:kSRFetchNewTopicsAndReloadTableData object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchRoomWithUrl:) name:kSRFetchRoomFromUrl object:nil];
}

- (void)fetchNewTopicsAndReloadTableData {
	self.offset = 1;
	[self.topicsTableView.infiniteScrollingView startAnimating];
	[self paginate];
}

- (void)fetchRoomWithUrl:(NSNotification *)notificaiton {
	NSURL *url = notificaiton.userInfo[@"url"];
	NSDictionary *query = [SRUrlHelper parseQueryString:[url query]];
	SRRoom *room = [[SRRoom alloc] init];
	room.position  = (NSString *)[url pathComponents][3];
	room.topicId = [url pathComponents][2];
	room.sessionId = query[@"q"];
    
	[self performSegueWithIdentifier:kSRMasterVCPushToDetailVC sender:room];
}

- (void)configureNavBar {
	UIBarButtonItem *rightPostTopicButton =
    [SRNavBarHelper buttonForNavBarWithImage:[UIImage imageNamed:@"logo"]
                            highlightedImage:nil
                                    selector:@selector(openClosePostTopicContainer)
                                      target:self
     ];
	self.navigationItem.rightBarButtonItem = rightPostTopicButton;
    
	UIBarButtonItem *leftShuffleButton =
    [SRNavBarHelper buttonForNavBarWithImage:[UIImage imageNamed:@"shuffle.png"]
                            highlightedImage:[UIImage imageNamed:@"shufflePressed.png"]
                                    selector:@selector(joinRandomRoom)
                                      target:self
     ];
	self.navigationItem.leftBarButtonItem = leftShuffleButton;
}

- (void)joinRandomRoom {
	NSMutableArray *activeTopics = [self activeTopicsWithPeopleInThem];
	SRRoom *randomRoom = [self randomRoom:activeTopics];
    
	[self performSegueWithIdentifier:kSRMasterVCPushToDetailVC sender:randomRoom];
}

- (NSMutableArray *)activeTopicsWithPeopleInThem {
	NSMutableArray *activeTopics = [NSMutableArray new];
    
	for (SRTopic *topic in self.topicsArray) {
		if ([topic.agreeDebaters integerValue] > 0 || [topic.disagreeDebaters integerValue] > 0) {
			[activeTopics addObject:topic];
		}
	}
    
	return activeTopics;
}

- (SRRoom *)randomRoom:(NSMutableArray *)topicsArray {
	SRTopic *randomTopic;
	SRRoom *randomRoom = [SRRoom new];
	int numberOfTopics = topicsArray.count;
    
	if (numberOfTopics > 0) {
		int randomNum = arc4random() % numberOfTopics;
		randomTopic = (SRTopic *)topicsArray[randomNum];
        
		if (randomTopic.agreeDebaters.intValue > randomTopic.disagreeDebaters.intValue) {
			randomRoom.position  = @"disagree";
		}
		else if (randomTopic.agreeDebaters.intValue < randomTopic.disagreeDebaters.intValue) {
			randomRoom.position  = @"agree";
		}
		else {
			randomRoom.position = [self randomlyChooseAgreeDisagree];
		}
	}
	else {
		int randomNum = arc4random() % self.topicsArray.count;
		randomTopic = (SRTopic *)self.topicsArray[randomNum];
		randomRoom.position = [self randomlyChooseAgreeDisagree];
	}
	randomRoom.topicId = randomTopic.topicId;
	return randomRoom;
}


- (NSString *)randomlyChooseAgreeDisagree {
	int r = arc4random() % 2;
	return (r == 0) ? @"agree" : @"disagree";
}

- (void)configureTableView {
	self.offset = 1;
    
	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	[refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
	[self.topicsTableView addSubview:refreshControl];
    
	[self addInfiniteScrolling:self.topicsTableView];
    
	self.openCellIndex = nil;
    
	self.topicsTableView.layer.shouldRasterize = YES;
	self.topicsTableView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

- (void)configurePostTopicContainer {
	SRPostTopic *postTopic = [[SRPostTopic alloc]initWithFrame:CGRectMake(0, 0, 320, 133)];
	[self.postTopicContainer addSubview:postTopic];
	postTopic.delegate = self;
}

- (void)addInfiniteScrolling:(UITableView *)tableView {
	[tableView addInfiniteScrollingWithActionHandler: ^(void) {
	    self.offset += 1;
	    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
	        [self paginate];
	        double delayInSeconds = 0.8;
	        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
	            [self.topicsTableView.infiniteScrollingView stopAnimating];
			});
		});
	}];
    
	self.topicsTableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
}

- (void)refresh:(UIRefreshControl *)refreshControl {
	self.offset = 1;
	self.openCellIndex = nil;
    
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
	    [self paginate];
	    double delayInSeconds = 1;
	    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
	        [refreshControl endRefreshing];
		});
	});
}

- (void)paginate {
	__weak typeof(self) weakSelf = self;
    
	if (!self.paginator) {
		self.paginator.perPage = 20;
		NSString *requestString = kSRPaginationParamterString;
		self.paginator = [[RKObjectManager sharedManager] paginatorWithPathPattern:requestString];
        
		[self.paginator setCompletionBlockWithSuccess: ^(RKPaginator *paginator, NSArray *objects, NSUInteger page) {
		    NSMutableArray *topicsArrayTemp = [objects mutableCopy];
		    weakSelf.isPaginatorLoading = NO;
            
		    if (weakSelf.offset == 1) {
		        [weakSelf replaceRowsInTableView:topicsArrayTemp];
			}
		    else {
		        [weakSelf insertRowsInTableView:topicsArrayTemp];
			}
		    [weakSelf.topicsTableView.infiniteScrollingView stopAnimating];
            [weakSelf performSelector:@selector(displayUserInstallationMessage) withObject:nil afterDelay:3];
		} failure: ^(RKPaginator *paginator, NSError *error) {
		    weakSelf.isPaginatorLoading = NO;
		    [weakSelf.topicsTableView.infiniteScrollingView stopAnimating];
		    [weakSelf noResults];
		}];
	}
    
	if (!self.isPaginatorLoading) {
        [self.paginator cancel];
		self.isPaginatorLoading = YES;
		[self.paginator loadPage:self.offset];
	}
}

- (void)noResults {
	double delayInSeconds = 0.6;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
	    [self performSegueWithIdentifier:kSRMasterVCPushToNoResults sender:nil];
	});
}

#pragma mark - Posting a new topic
- (void)openClosePostTopicContainer {
	[self.view endEditing:YES];
	CGRect newTableViewFrame = self.topicsTableView.frame;
	CGRect newPostTopicFrame = self.postTopicContainer.frame;
	float duration, alpha;
    
	if ([self isPostTopicContainerOpen]) {
		newTableViewFrame.origin.y -= 133;
		newPostTopicFrame.origin.y -= 133;
		duration = .3;
		alpha = 0;
	}
	else {
		newTableViewFrame.origin.y += 133;
		newPostTopicFrame.origin.y += 133;
		duration = .4;
		alpha = 1;
	}
    
	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations: ^{
	    self.postTopicContainer.alpha = alpha;
	    self.topicsTableView.frame = newTableViewFrame;
	    self.postTopicContainer.frame = newPostTopicFrame;
	} completion:nil];
}

- (BOOL)isPostTopicContainerOpen {
	return (self.postTopicContainer.frame.origin.y < 0) ? NO : YES;
}

- (void)statusUpdate:(NSString *)message {
	self.statusLabel.text = message;
	[self.statusLabel.layer addAnimation:[SRAnimationHelper fadeOfSRMasterViewStatusLabel] forKey:nil];
}

- (void)postTopicButtonPressed:(NSString *)contents {
    
	NSDictionary *newTopic = @{ @"topic":contents };
    
	[[RKObjectManager sharedManager] postObject:nil path:@"topics/new" parameters:newTopic success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
	    if ([self isPostTopicContainerOpen]) {
	        //close post box if it's open
	        [self openClosePostTopicContainer];
		}
	    [self statusUpdate:@"Topic Posted!"];
	} failure: ^(RKObjectRequestOperation *operation, NSError *error) {
	    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
	                                                    message:@"We weren't able to post your shout. Try again soon!"
	                                                   delegate:nil
	                                          cancelButtonTitle:@"Sure"
	                                          otherButtonTitles:nil, nil];
	    [alert show];
	}];
}

//Delegate for SRChoiceBox - user chooses Agree/Disagree/Observe
- (void)positionWasChoosen:(NSString *)choice topicId:(NSNumber *)topicId {
	SRRoom *room = [[SRRoom alloc] init];
	room.position  = choice;
	room.topicId = topicId;
    
	if ([choice isEqualToString:@"observe"]) {
		[self performSegueWithIdentifier:kSRMasterVCPushToObserveVC sender:room];
	}
	else {
		[self performSegueWithIdentifier:kSRMasterVCPushToDetailVC sender:room];
	}
}

- (void)segueToRoomWithTopicID:(NSNumber *)topicId andPosition:(NSString *)choice {
	SRRoom *room = [[SRRoom alloc] init];
	room.position  = choice;
	room.topicId = topicId;
    
	if ([choice isEqualToString:@"observe"]) {
		[self performSegueWithIdentifier:kSRMasterVCPushToObserveVC sender:room];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([self isPostTopicContainerOpen]) {
		[self openClosePostTopicContainer];
	}
    
	if ([[segue identifier] isEqualToString:kSRMasterVCPushToDetailVC] || [[segue identifier] isEqualToString:kSRMasterVCPushToObserveVC]) {
		if (self.openTokHandler) {
			[self.openTokHandler safetlyCloseSession];
		}
		[[segue destinationViewController] setOpenTokHandler:self.openTokHandler];
		[[segue destinationViewController] setRoom:sender];
	}
	sender = nil;
}

#pragma mark - UITABLEVIEW
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.topicsArray count];
}

- (void)insertRowsInTableView:(NSMutableArray *)topics {
	if (topics.count < 1) {
		[self noNewResults];
		return;
	}
    
	NSMutableArray *temp = [NSMutableArray new];
	int lastRowNumber = [self.topicsTableView numberOfRowsInSection:0] - 1;
    
	for (SRTopic *topic in topics) {
		if (![self.topicsArray containsObject:topic]) {
			[self.topicsArray addObject:topic];
			NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
			[temp addObject:ip];
			++lastRowNumber;
		}
	}
	if (temp.count < 1) {
		[self noNewResults];
		return;
	}
    
	[self.topicsTableView beginUpdates];
	[self.topicsTableView insertRowsAtIndexPaths:temp
	                            withRowAnimation:UITableViewRowAnimationTop];
	[self.topicsTableView endUpdates];
}

- (void)noNewResults {
	int lastRowNumber = [self.topicsTableView numberOfRowsInSection:0] - 1;
	[self statusUpdate:@"No New Topics. Check Back Soon!"];
	[self.topicsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastRowNumber - 6 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	self.offset--;
}

- (void)replaceRowsInTableView:(NSMutableArray *)topics {
	self.topicsArray = topics;
    
    
	[UIView animateWithDuration:.3 delay:.5 options:UIViewAnimationOptionCurveEaseInOut animations: ^{
	    self.topicsTableView.layer.opacity = 0;
	} completion: ^(BOOL finished) {
	    self.topicsTableView.layer.opacity = 1;
	    [[self.topicsTableView layer] addAnimation:[SRAnimationHelper tableViewReloadDataAnimation] forKey:@"UITableViewReloadDataAnimationKey"];
        
	    self.topicsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	    [self.topicsTableView reloadData];
	}];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = kSRCollapsibleCellClosed;
	SRCollapsibleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[SRCollapsibleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    
	SRTopic *topic = [self.topicsArray objectAtIndex:indexPath.row];
	[cell updateWithTopic:topic];
    
	if ([self isCellOpen:indexPath]) {
		CGAffineTransform transformation = CGAffineTransformMakeRotation(M_PI / 2);
		cell.arrow.transform = transformation;
		if (![self hasChoiceBox:cell]) {
			[self insertChoiceBox:cell atIndex:indexPath];
		}
	}
	else {
		CGAffineTransform transformation = CGAffineTransformMakeRotation(0);
		cell.arrow.transform = transformation;
	}
    
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self isCellOpen:indexPath]) {
		[self closeCellAtIndexPath:indexPath];
	}
	else {
		NSIndexPath *openCell = self.openCellIndex;
		NSIndexPath *newOpenCell = indexPath;
		[self closeCellAtIndexPath:openCell];
		[self openCellAtIndexPath:newOpenCell];
	}
	[tableView beginUpdates];
	[tableView endUpdates];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath isEqual:self.openCellIndex]) {
		return 217.0;
	}
	else {
		return 63.0;
	}
}

- (void)rotateCellArrowAtIndexPath:(NSIndexPath *)indexPath willOpen:(BOOL)willOpen animated:(BOOL)animated {
	SRCollapsibleCell *cell = (SRCollapsibleCell *)[self.topicsTableView cellForRowAtIndexPath:indexPath];
    
	CGAffineTransform transformation;
    
	if (willOpen) {
		transformation = CGAffineTransformMakeRotation(M_PI / 2);
	}
	else {
		transformation = CGAffineTransformMakeRotation(0);
	}
    
	if (animated) {
		[UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveLinear animations: ^{
		    cell.arrow.transform = transformation;
		}  completion:nil];
	}
	else {
		cell.arrow.transform = transformation;
	}
}

- (BOOL)isCellOpen:(NSIndexPath *)indexPath {
	return [indexPath isEqual:self.openCellIndex];
}

- (void)closeCellAtIndexPath:(NSIndexPath *)indexPath {
	[self rotateCellArrowAtIndexPath:indexPath willOpen:NO animated:YES];
	[self removeSRChoiceBoxFromCellAtIndexPath:indexPath];
	self.openCellIndex = nil;
}

- (void)openCellAtIndexPath:(NSIndexPath *)indexPath {
	[self rotateCellArrowAtIndexPath:indexPath willOpen:YES animated:YES];
	SRCollapsibleCell *cell = (SRCollapsibleCell *)[self.topicsTableView cellForRowAtIndexPath:indexPath];
	[self insertChoiceBox:cell atIndex:indexPath];
	self.openCellIndex = indexPath;
}

- (void)removeSRChoiceBoxFromCellAtIndexPath:(NSIndexPath *)indexPath {
	SRCollapsibleCell *cell = (SRCollapsibleCell *)[self.topicsTableView cellForRowAtIndexPath:indexPath];
	for (id subview in cell.SRCollapsibleCellContent.subviews) {
		if ([subview isKindOfClass:[SRChoiceBox class]]) {
			[subview removeFromSuperview];
		}
	}
}

- (void)insertChoiceBox:(SRCollapsibleCell *)cell atIndex:(NSIndexPath *)indexPath {
	SRChoiceBox *newBox = [[SRChoiceBox alloc] initWithFrame:CGRectMake(0, 0, 310, 141)];
	SRTopic *topic = [self.topicsArray objectAtIndex:indexPath.row];
	[newBox updateWithSRTopic:topic];
	newBox.delegate = self;
    
	[cell.SRCollapsibleCellContent addSubview:newBox];
}

- (BOOL)hasChoiceBox:(SRCollapsibleCell *)cell {
	for (UIView *subview in cell.SRCollapsibleCellContent.subviews) {
		if ([subview isKindOfClass:[SRChoiceBox class]]) {
			return true;
		}
	}
	return false;
}

- (void)dealloc {
	//In theory, this VC should not be deallocated
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
