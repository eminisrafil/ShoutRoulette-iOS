//
//  SRMasterViewController.h
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SRPostTopic.h"
#import "SRChoiceBox.h"
#import "SROpenTokVideoHandler.h"
#import "SRObserveViewController.h"
#import "SRAPI.h"

@interface SRMasterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SRChoiceBoxDelegate, SRPostTopicDelegate>

@property (weak, nonatomic) IBOutlet UITableView *topicsTableView;
@property (weak, nonatomic) IBOutlet UIView *postTopicContainer;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (strong, nonatomic) NSIndexPath *openCellIndex;
@property (strong, nonatomic) RKPaginator *paginator;
@property (strong, nonatomic) SROpenTokVideoHandler *openTokHandler;

@end
