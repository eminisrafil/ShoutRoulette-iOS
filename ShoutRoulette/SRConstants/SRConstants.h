//
//  SRConstants.h
//  ShoutRoulette
//
//  Created by emin on 11/7/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#ifndef ShoutRoulette_SRConstants_h
#define ShoutRoulette_SRConstants_h

//Notifications
extern NSString *const kSROpenTokVideoHandlerNotifcations; 
extern NSString *const kSRFetchNewTopicsAndReloadTableData; 
extern NSString *const kSRFetchRoomFromUrl;

//Observers
extern NSString *const kSROpentTokVideoHandlerStateObserver;

//Times
extern const int kSRBackButtonDelayTime; 
extern const int kSRShoutMatchTime; 

//URLS
extern NSString *const kSRAPIHOST;
extern NSString *const kSRPaginationParamterString; 

//Segues
extern NSString *const kSRMasterVCPushToDetailVC; 
extern NSString *const kSRMasterVCPushToObserveVC;
extern NSString *const kSRMasterVCPushToNoResults;

//UITableViewCells
extern NSString *const kSRCollapsibleCellClosed;

//API Keys
extern NSString *const kSROpentTokAPIKey;
extern NSString *const kSRTestFlightAPIKey; 

//SRLengths
extern const int kSRMaxPostLength; 
extern const int kSRMinPostLength; 

#endif
