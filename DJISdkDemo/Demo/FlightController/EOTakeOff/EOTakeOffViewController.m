//
//  EOTakeOffViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  DJIFlightController provides different sets of methods to control the movement of the aircraft. This file demonstrates the basic methods
 *  to make the aircraft take-off, go home and land. For more advanced methods, please refer to FCVirtualStickViewController.m.
 */
#import "EOTakeOffViewController.h"
#import "EOSmileViewController.h"
#import "DemoComponentHelper.h"
#import "DemoAlertView.h"
#import <DJISDK/DJISDK.h>

@interface EOTakeOffViewController ()
- (IBAction)onTakeoffButtonClicked:(id)sender;

@end

@implementation EOTakeOffViewController

- (IBAction)onTakeoffButtonClicked:(id)sender {
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        [fc startTakeoffWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Takeoff Error:%@", error.localizedDescription);
            }
            else
            {
                // ShowResult(@"Takeoff Succeeded.");
                EOSmileViewController *eoSmileVC = [[EOSmileViewController alloc] init];
                [self.navigationController pushViewController:eoSmileVC animated:YES];
            }
        }];
    }
    else
    {
        ShowResult(@"Component Not Exist");
    }
}

@end
