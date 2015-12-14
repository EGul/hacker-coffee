//
//  SelectView.m
//  TiltApp
//
//  Created by Evan on 12/11/15.
//  Copyright © 2015 none. All rights reserved.
//

#import "SelectView.h"

@interface SelectView () {
    
    UIView *mainView;
    
}

@end

@implementation SelectView

-(id)init {
    
    if (self = [super init]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
    }
    
    return self;
}

-(void)generate {
    
    UIView *shadowView = [[UIView alloc]init];
    shadowView.frame = CGRectMake((self.frame.size.width / 2) - ((self.frame.size.width * 2) / 2),
                                  -2,
                                  self.frame.size.width * 2,
                                  self.frame.size.width * 2);
    
    mainView = [[UIView alloc]init];
    mainView.frame = CGRectMake(0, 0,
                                self.frame.size.width,
                                self.frame.size.height);
    
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.frame = CGRectMake(0,
                                 0,
                                 self.frame.size.width,
                                 self.frame.size.height);
    
    UILabel *wifiTipsLabel = [[UILabel alloc]init];
    wifiTipsLabel.frame = CGRectMake(0, 0,
                                     self.frame.size.width,
                                     25);
    
    mainView.backgroundColor = [UIColor whiteColor];
    
    nameLabel.textAlignment = NSTextAlignmentCenter;
    wifiTipsLabel.textAlignment = NSTextAlignmentCenter;
    wifiTipsLabel.textColor = [UIColor grayColor];
    
    nameLabel.text = [self.dataSource valueForKey:@"name"];
    wifiTipsLabel.text = [NSString stringWithFormat:@"Wifi Tips: %d", (int)[[self.dataSource valueForKey:@"tips"]count]];

    [mainView addSubview:nameLabel];
    [mainView addSubview:wifiTipsLabel];
    [self addSubview:mainView];
    
}

-(void)setSelected:(BOOL)selected {
    
    if (selected) {
        mainView.backgroundColor = [UIColor colorWithRed:235/255.0f green:235/255.0f blue:235/255.0f alpha:1];
    }
    else {
        mainView.backgroundColor = [UIColor whiteColor];
    }
    
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self setSelected:false];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self setSelected:true];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self setSelected:false];
    
    if ([[touches anyObject]locationInView:self].y > 0) {
        [self.delegate selectViewDidSelect];
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
