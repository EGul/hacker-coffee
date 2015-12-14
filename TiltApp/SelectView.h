//
//  SelectView.h
//  TiltApp
//
//  Created by Evan on 12/11/15.
//  Copyright © 2015 none. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectViewProtocol <NSObject>

-(void)selectViewDidSelect;

@end

@interface SelectView : UIView {
    
}

-(void)generate;
-(void)setSelected:(BOOL)selected;

@property(nonatomic, retain) id delegate;
@property(nonatomic, retain) NSDictionary *dataSource;

@end
