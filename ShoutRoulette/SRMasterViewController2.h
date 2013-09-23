//
//  SRMasterViewController2.h
//  
//
//  Created by emin on 8/29/13.
//
//

#import <UIKit/UIKit.h>
#import "SRAPI.h"
//#import "CollapseClick.h"
#import "SRChoiceBox.h"
#import "SRPostTopic.h"
#import "SRDetailViewController.h"
#import "SRCollapsibleCell.h"
#import <QuartzCore/QuartzCore.h>
#import "SROpenTokVideoHandler.h"



@interface SRMasterViewController2 : UIViewController<UITableViewDelegate, UITableViewDataSource, SRChoiceBoxDelegate, SRPostTopicDelegate>



@property IBOutlet UITableView *shoutsTableView;
//@property (weak, nonatomic) IBOutlet CollapseClick *CollapseClickCell;
@property (weak, nonatomic) IBOutlet UIView *postShoutContainer;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIView *statusLabelContainer;
@property (strong, nonatomic) NSIndexPath *openCellIndex;

@property (strong) RKPaginator* paginator;
@property (strong, nonatomic) SROpenTokVideoHandler *openTokHandler;

-(void)loadTableData;

@end