//
//  tslMasterViewController.h
//  tessle
//
//  Created by Patrick Rogers on 5/25/14.
//  Copyright (c) 2014 Tessle. All rights reserved.
//

#import <UIKit/UIKit.h>

@class tslDetailViewController;

@interface tslMasterViewController : UITableViewController

@property (strong, nonatomic) tslDetailViewController *detailViewController;

@end
