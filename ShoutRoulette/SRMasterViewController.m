
//
//  SRMasterViewController.m
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRMasterViewController.h"
#import "SRDetailViewController.h"
#import "SRTopic.h"
#import "SRRoom.h"
#import "UIScrollView+SVPullToRefresh.h"



@interface SRMasterViewController () {
    NSMutableArray *_objects;
    BOOL isPostShoutOpen;
}
@end

@implementation SRMasterViewController
- (void)awakeFromNib
{
    [super awakeFromNib];
}
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CCUpdate:) name:@"CollapseClickUpdated" object:nil];
    
    myCollapseClick.CollapseClickDelegate = self;
	[SRAPI sharedInstance];
    [self loadTableData];
    [myCollapseClick addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    isPostShoutOpen = NO;
    SRPostTopic *postTopicBox = [[SRPostTopic alloc]initWithFrame:CGRectMake(0, 0, 320, 133)];
    [self.postShoutContainer addSubview:postTopicBox];
    postTopicBox.delegate = self; 
}

-(void) CCUpdate:(NSNotification*)notification{
    [myCollapseClick removePullToRefresh];
    NSLog(@"CC UPDATED!");
    [myCollapseClick addPullToRefreshWithActionHandler:^(void){
        NSLog(@"reloading");
        [self loadTableData];
    }];
}

-(void)showPostShout{
    CGRect newCCFrame = myCollapseClick.frame;
    float off = [myCollapseClick contentOffset].y;
    
    if (!isPostShoutOpen) {
        newCCFrame.origin.y += 133;
        [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.postShoutContainer.alpha = 1;
            myCollapseClick.frame= newCCFrame;
            
        } completion: ^(BOOL finished){
            NSLog(@"finished!");
        }];
    } else{
        newCCFrame.origin.y -= 133;
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.postShoutContainer.alpha = 0;
            myCollapseClick.frame= newCCFrame;
        } completion: ^(BOOL finished){
            NSLog(@"finished2!");
        }];
    }
    NSLog(@"FROM MASTER  %f and offset: %f", newCCFrame.origin.y, off);

    isPostShoutOpen = !isPostShoutOpen;
}



-(void)openPostShout{
}


-(void)closePostShout{
}

-(void)postTopicButtonPressed:(NSString *)contents{
    NSDictionary *newTopic = @{@"topic":contents};
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager postObject:nil path:@"topics/new" parameters:newTopic
     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
            NSLog(@"HERE ARE THE RESULTS %@", mappingResult);
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        NSLog(@"HERE ARE Error THE RESULTS %@", error);
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    //NSLog(@"FROM SRMASTER:: Object: %@  KeyPath: %@   Change: %@", keyPath, object, [NSString stringWithFormat:@"%@", change]);
    
}

-(void)loadTableData{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    [objectManager getObjectsAtPath:@"http://srapp.herokuapp.com/" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
        NSArray* topicsArray = [mappingResult array];
        _objects = [topicsArray copy];
        if(self.isViewLoaded){
            [myCollapseClick.pullToRefreshView stopAnimating];
            [myCollapseClick reloadCollapseClick];
            
        }
    }failure:^(RKObjectRequestOperation *operation, NSError *error){
        [myCollapseClick.pullToRefreshView stopAnimating];
        NSLog(@"HERE ARE Error THE RESULTS %@", error);
    }];
    
}

#pragma mark -Collapse Click
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
    SRChoiceBox *newBox = [[SRChoiceBox alloc] initWithLabel:@"Boobies" andTopicID:loadedTopic.topicId andFrame: CGRectMake(5, 5, 310, 150)];
    newBox.delegate = self;
    return newBox;
}

-(void) buttonWasPressed:(NSString *)choice topicId:(NSNumber *)topicId{
       
    if([choice isEqualToString:@"observe"]){
        [self showPostShout];
        return;
    }

    SRRoom *room = [[SRRoom alloc] init];
    room.position  = choice;
    room.topicId = topicId; //[NSNumber numberWithInt:279];
    room.title = (@"hello %@", choice);
    [self performSegueWithIdentifier:@"showDetail" sender:room];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [self resignFirstResponder];
    //[yourSecondTextField resignFirstResponder];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (isPostShoutOpen) {
        [self showPostShout];
    }
    if ([[segue identifier] isEqualToString:@"showDetail"]) {       
        [[segue destinationViewController] setDetailItem:sender];
    }
}

@end
