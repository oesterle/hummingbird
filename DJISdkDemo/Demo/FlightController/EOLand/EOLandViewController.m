//
//  EOLandViewController
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import "EOLandViewController.h"
#import "DemoComponentHelper.h"
#import "DemoAlertView.h"
#import <DJISDK/DJISDK.h>

@interface EOLandViewController ()
- (IBAction)onLandButtonClicked:(id)sender;

@end

@implementation EOLandViewController

- (IBAction)onLandButtonClicked:(id)sender {
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        [fc startLandingWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Landing Error:%@", error.localizedDescription);
            }
            else
            {
                ShowResult(@"Landing Succeeded.");
            }
        }];
    }
    else
    {
        ShowResult(@"Component doesn't exist");
    }
}

@end
