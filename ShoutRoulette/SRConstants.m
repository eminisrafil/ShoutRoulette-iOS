//
//  SRConstants.m
//  ShoutRoulette
//
//  Created by emin on 11/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRConstants.h"

//Notifications
NSString *const kSROpenTokVideoHandlerNotifcations = @"kSROpenTokVideoHandlerNotifcations";
NSString *const kSRFetchNewTopicsAndReloadTableData = @"kFetchNewTopicsAndReloadTableData";
NSString *const kSRFetchRoomFromUrl = @"kFetchRoomFromUrl";

//Observers
NSString *const kSROpentTokVideoHandlerStateObserver = @"SROpentTokVideoHandlerState";

//Times
const int kSRBackButtonDelayTime = 3;
const int kSRShoutMatchTime = 60;

//URLS
#ifdef DEBUG
    NSString *const kSRAPIHOST = @"http://srapp.herokuapp.com/";
#else
    NSString *const kSRAPIHOST = @"http://ShoutRoulette.com/";
#endif
NSString *const kSRPaginationParamterString = @"?page=:currentPage&per_page=:perPage";

//Segues
NSString *const kSRMasterVCPushToDetailVC = @"showDetail";
NSString *const kSRMasterVCPushToObserveVC = @"showObserve";
NSString *const  kSRMasterVCPushToNoResults =@"noResults";

//UITableViewCells
NSString *const kSRCollapsibleCellClosed = @"SRCollapsibleCellClosed";

//API Keys
NSString *const kSROpentTokAPIKey = @"20193772";
NSString *const kSRTestFlightAPIKey = @"ac04c1e5-5155-4ca9-9ccd-40788feefe35";

//SRLengths
const int kSRMaxPostLength = 60;
const int kSRMinPostLength = 4;

