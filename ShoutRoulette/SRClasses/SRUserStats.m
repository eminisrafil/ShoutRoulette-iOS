//
//  SRUserStats.m
//  ShoutRoulette
//
//  Created by emin on 11/25/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRUserStats.h"

@interface SRUserStats ()
@property NSString *pListPath;
@property NSMutableDictionary *pListDictionary;
@end

@implementation SRUserStats

-(id)init{
    self = [super init];
    
    if(self){
        NSString *rootPath= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        _pListPath = [rootPath stringByAppendingPathComponent:@"SRUserStats.plist"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:_pListPath]){
            NSDictionary *newUser = @{@"logins" : @0,
                                      @"shouts" : @0,
                                      @"observes" : @0,
                                      };
            [newUser writeToFile:_pListPath atomically:YES];
        }
        _pListDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:_pListPath];
    }
    return self;
}


-(NSNumber *)getUsageStat:(NSString *)stat{
    return (NSNumber *)self.pListDictionary[stat];
}

-(void)incrementStat:(NSString*)stat{
    int numberOfLogins = [self.pListDictionary[stat] intValue];
    numberOfLogins++;
    self.pListDictionary[stat] = [NSNumber numberWithInt:numberOfLogins];
    
    NSError *error;
    NSData *updatedPList = [NSPropertyListSerialization dataWithPropertyList:self.pListDictionary
                                                              format:NSPropertyListXMLFormat_v1_0
                                                             options:0
                                                               error:&error];
    [updatedPList writeToFile:self.pListPath atomically:YES];
}

-(void)displayUserInstallationMessage{

    if([[self getUsageStat:@"logins"] intValue]<1){
        UIAlertView *welcomeAlert = [[UIAlertView alloc]initWithTitle:@"Welcome to ShoutRoulette!" message:@"Just choose a topic, pick a side and start shouting!" delegate:nil cancelButtonTitle:@"I'm ready" otherButtonTitles:nil, nil];
        [welcomeAlert show];
    }

}

-(void)displayFirstMatchMessage{
    if([[self getUsageStat:@"shouts"] intValue]<1){
        UIAlertView *welcomeAlert = [[UIAlertView alloc]initWithTitle:@"Welcome to ShoutRoulette!" message:@"Your 60 second match will start soon. \n\n Currently, we only support audio so feel free to shout anywhere without getting self-conscious." delegate:nil cancelButtonTitle:@"I'm ready" otherButtonTitles:nil, nil];
        [welcomeAlert show];
    }
}

-(void)displayFirstObserveMessage{
    if([[self getUsageStat:@"observes"] intValue]<1){
        UIAlertView *welcomeAlert = [[UIAlertView alloc]initWithTitle:@"Welcome to ShoutRoulette!" message:@"In this room, you can sit back and listen to other people fight it out." delegate:nil cancelButtonTitle:@"I'm ready" otherButtonTitles:nil, nil];
        [welcomeAlert show];
    }
}

@end
