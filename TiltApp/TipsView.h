//
//  TipsView.h
//  TiltApp
//
//  Created by Evan on 12/12/15.
//  Copyright © 2015 none. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TipsView : UITextView {
    
}

@property(nonatomic, retain) NSArray *dataSource;

-(void)generate;

@end
