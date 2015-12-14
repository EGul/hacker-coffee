//
//  TipsView.m
//  TiltApp
//
//  Created by Evan on 12/12/15.
//  Copyright © 2015 none. All rights reserved.
//

#import "TipsView.h"

#import "DateTools.h"

@interface TipsView ()

-(NSArray *)sortData:(NSArray *)arr;

@end

@implementation TipsView

-(id)init {
    
    if (self = [super init]) {
        
        self.editable = false;
        
    }
    
    return self;
}

-(NSArray *)sortData:(NSArray *)arr {
    
    NSArray *sortedArr = [[NSArray alloc]init];
    
    sortedArr = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSNumber *first = [obj1 valueForKey:@"created"];
        NSNumber *second = [obj2 valueForKey:@"created"];
        return [second compare:first];
    }];
    
    return sortedArr;
}

-(void)generate {
    
    if (self.dataSource.count == 0) {
        
        self.backgroundColor = [UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1];
        
        UILabel *noWifiLabel = [[UILabel alloc]init];
        noWifiLabel.frame = CGRectMake(0,
                                       0,
                                       self.frame.size.width,
                                       self.frame.size.height);
        noWifiLabel.textAlignment = NSTextAlignmentCenter;
        noWifiLabel.numberOfLines = 2;
        noWifiLabel.text = @"Sorry. No Wifi Data.";
        noWifiLabel.font = [UIFont systemFontOfSize:20];
        
        [self addSubview:noWifiLabel];
        
        return;
    }
    
    self.dataSource = [self sortData:self.dataSource];
    
    NSMutableArray *colorRangeArray = [[NSMutableArray alloc]init];
    NSMutableArray *sizeRangeArray = [[NSMutableArray alloc]init];
    
    NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc]init];
    NSString *string = @"";
    
    for (int i = 0; i < self.dataSource.count; i++) {
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[[self.dataSource objectAtIndex:i]valueForKey:@"created"]intValue]];
        NSString *text = [[self.dataSource objectAtIndex:i]valueForKey:@"text"];
        
        long begin = [string length];
        long end = [date.timeAgoSinceNow length] + 1;
        long secondBegin = begin + end;
        long secondEnd = text.length + 1;
        
        NSArray *tempArr = [[NSArray alloc]initWithObjects:[NSNumber numberWithLong:begin], [NSNumber numberWithLong:end], nil];
        [colorRangeArray addObject:tempArr];
        
        NSArray *secondTempArr = [[NSArray alloc]initWithObjects:[NSNumber numberWithLong:secondBegin], [NSNumber numberWithLong:secondEnd], nil];
        [sizeRangeArray addObject:secondTempArr];
        
        string = [NSString stringWithFormat:@"%@%@%@%@%@%@", string, @"\n", date.timeAgoSinceNow, @"\n", text, @"\n"];
        
    }
    
    attribString = [[NSMutableAttributedString alloc]initWithString:string];
    
    for (NSArray *item in colorRangeArray) {
        NSRange range = NSMakeRange([[item objectAtIndex:0]intValue], [[item objectAtIndex:1]intValue]);
        [attribString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:range];
    }
    
    for (NSArray *item in sizeRangeArray) {
        NSRange secondRange = NSMakeRange([[item objectAtIndex:0]intValue], [[item objectAtIndex:1]intValue]);
        [attribString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:secondRange];
    }
    
    self.attributedText = attribString;
 
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
