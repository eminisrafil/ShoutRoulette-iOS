//
//  SRNoResultsViewController.m
//  ShoutRoulette
//
//  Created by emin on 8/30/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRNoResultsViewController.h"
#import "SVPullToRefresh.h"
@interface SRNoResultsViewController ()

@end

@implementation SRNoResultsViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureScrollViewContainer];
    [self addCenteredImageTo:self.containerScrollView];

}

-(void)configureScrollViewContainer{
    //Make scrollview larger than frame to allow pullToRefresh
    self.containerScrollView.contentSize = CGSizeMake(self.view.frame.size.width, (self.view.frame.size.height*1.20));
    
    //add pullToRefresh
    __weak SRNoResultsViewController *weakSelf = self;
    [self.containerScrollView addPullToRefreshWithActionHandler:^(void){
        [weakSelf performSelector:@selector(refresh) withObject:nil afterDelay:1.2];
        //add more actions
    }];
    
}

-(void)addCenteredImageTo:(UIView*)view{
    //load image
    UIImageView *noResultsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noInternet.png"]];
    
    //center it + add it
    noResultsImageView.frame = CGRectOffset(noResultsImageView.frame, (self.view.frame.size.width -  noResultsImageView.frame.size.width)/2, (self.view.frame.size.height -  noResultsImageView.frame.size.height)/2);
    
    [self.view addSubview:noResultsImageView];
}


-(void)refresh
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.parentViewController performSelector:@selector(loadTableData)];

    //[self.parentViewController performSelector:@selector(loadt)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
