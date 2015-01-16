//
//  tslDetailViewController.h
//  tessle
//
//  Created by Patrick Rogers on 5/25/14.
//  Copyright (c) 2014 Tessle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tslDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
