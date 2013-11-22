//
//  SRMasterViewController.h
//
//
//  Created by emin on 8/29/13.
//
//

#import <UIKit/UIKit.h>

#import "SRPostTopic.h"
#import "SRChoiceBox.h"
#import "SROpenTokVideoHandler.h"
#import "SRObserveViewController.h"

@interface SRMasterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SRChoiceBoxDelegate, SRPostTopicDelegate>

@property (weak, nonatomic) IBOutlet UITableView *topicsTableView;
@property (weak, nonatomic) IBOutlet UIView *postTopicContainer;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (strong, nonatomic) NSIndexPath *openCellIndex;
@property (strong, nonatomic) RKPaginator *paginator;
@property (strong, nonatomic) SROpenTokVideoHandler *openTokHandler;

@end
