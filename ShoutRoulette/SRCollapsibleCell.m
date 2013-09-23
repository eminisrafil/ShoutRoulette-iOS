//
//  SRCollapsibleCell.m
//  ShoutRoulette
//
//  Created by emin on 8/29/13.
//  Copyright (c) 2013 SR. All rights reserved.
//

#import "SRCollapsibleCell.h"


@implementation SRCollapsibleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
       self.subtitle.text = @"balls2";
       //self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBase.png"]];
        [self configureView];
    }
    return self;
}

//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andTopic:(SRTopic *)topic
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        self.subtitle.text = @"balls3";
//        self.title.text = topic.title;
//        self.topicId = topic.topicId;
//        self.agreeDebaters.text = [NSString stringWithFormat:@"%@",topic.agreeDebaters];
//        self.disagreeDebaters.text = [NSString stringWithFormat:@"%@", topic.disagreeDebaters];
//        self.observers.text = [NSString stringWithFormat:@"%@", topic.observers];
//        
//        //self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBase.png"]];
//        [self configureView];
//    }
//    return self;
//}

-(void)configureView
{
    self.subtitle.text = @"balls4";
    

}



-(void)formatTitle:(NSString *)title{
    
    
    if(title.length<30){
        self.title.text= title;
    } else {
        NSArray *splitString = [self splitString:title maxCharacters:30];
        self.title.text = splitString[0];
        self.subtitle.text = splitString[1];
    }

}

////http://www.musicalgeometry.com/?p=1197
- (NSArray *)splitString:(NSString*)str maxCharacters:(NSInteger)maxLength {
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:1];
    NSArray *wordArray = [str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSInteger numberOfWords = [wordArray count];
    NSInteger index = 0;
    NSInteger lengthOfNextWord = 0;
    
	while (index < numberOfWords && tempArray.count<2) {
		NSMutableString *line = [NSMutableString stringWithCapacity:1];
		while ((([line length] + lengthOfNextWord + 1) <= maxLength) && (index < numberOfWords)) {
	        lengthOfNextWord = [[wordArray objectAtIndex:index] length];
	        [line appendString:[wordArray objectAtIndex:index]];
	        index++;
            if (index < numberOfWords) {
                [line appendString:@" "];
            }
	    }
		[tempArray addObject:line];
        
        NSMutableString *subtitle = [NSMutableString stringWithCapacity:1];
        
        while(index<numberOfWords){
            [subtitle appendString:[wordArray objectAtIndex:index]];
            [subtitle appendString:@" "];
            index++;
        }
        
        
        [tempArray addObject:subtitle];
        break;
	}
    return tempArray;
}


//-(void)updateStats:(NSDictionary *)stats{
//    self.agreeDebaters.text = [NSString stringWithFormat:@"%@", stats.agreeDebaters];
//    self.disagreeDebaters.text = [NSString stringWithFormat:@"%@", stats.disagreeDebaters];
//    
//    self.observers.text = [NSString stringWithFormat:@"%@", stats.observers];
//}

-(void)updateWithTopic
{
//make this later

}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
