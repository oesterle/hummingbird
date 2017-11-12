//
//  EOSmileViewController
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import "EOSmileViewController.h"
#import "EOCaptureViewController.h"
#import "EOVirtualStickViewController.h"
#import "DemoComponentHelper.h"
#import "DemoAlertView.h"
#import <DJISDK/DJISDK.h>

@interface EOSmileViewController ()
- (IBAction)onSmileButtonClicked:(id)sender;

@end

@implementation EOSmileViewController

- (IBAction)onSmileButtonClicked:(id)sender {
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        EOCaptureViewController *eoCaptureVC = [[EOCaptureViewController alloc] init];
        [self.navigationController pushViewController:eoCaptureVC animated:YES];
        
        
//        EOVirtualStickViewController *eoVSVC = [[EOVirtualStickViewController alloc] init];
//        [self.navigationController pushViewController:eoVSVC animated:YES];
    }
    else
    {
        ShowResult(@"Component doesn't exist");
    }
}

@end
