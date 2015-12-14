//
//  MainAPI.h
//  TiltApp
//
//  Created by Evan on 12/9/15.
//  Copyright © 2015 none. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MainAPIProtocol <NSObject>

-(void)mainAPIDidThrowError:(NSError *)error;
-(void)mainAPIWillGetCoffeeShopsWithCount:(int)count;
-(void)mainAPIDidGetCoffeeShop:(NSDictionary *)coffeeShop;

@end

@interface MainAPI : NSObject {
    
}

@property(nonatomic, retain) id delegate;

-(void)getCoffeeShops:(float)lat lng:(float)lng radius:(float)radius;
-(void)getImageFromId:(NSString *)idStr block:(void (^)(UIImage *, NSError *))block;

@end
