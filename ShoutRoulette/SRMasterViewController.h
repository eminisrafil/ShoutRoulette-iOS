//
//  SRMasterViewController.h
//  ShoutRoulette
//
//  Created by emin on 5/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRAPI.h"
#import "CollapseClick.h"
#import "SRChoiceBox.h"
#import "SRPostTopic.h"

@interface SRMasterViewController : UIViewController<CollapseClickDelegate, SRChoiceBoxDelegate, SRPostTopicDelegate>{
    __weak IBOutlet CollapseClick *myCollapseClick;
    
}
@property (weak, nonatomic) IBOutlet UIView *postShoutContainer;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIView *statusLabelContainer;


@end
