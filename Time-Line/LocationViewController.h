//
//  LocationViewController.h
//  Time-Line
//
//  Created by connor on 14-4-9.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol getlocationDelegate <NSObject>
-(void)getlocation:(NSString*) name coordinate:(NSDictionary *) coordinatesDic;
@end

@interface LocationViewController : UIViewController 
@property (weak, nonatomic) IBOutlet UITextField *locationFiled;
@property (nonatomic, weak) id<getlocationDelegate> detelegate;
@end
