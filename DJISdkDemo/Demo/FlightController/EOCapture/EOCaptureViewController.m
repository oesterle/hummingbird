//
//  EOCaptureViewController.m


#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import <VideoPreviewer/VideoPreviewer.h>
#import "EOCaptureViewController.h"
#import "VideoPreviewerSDKAdapter.h"
#import "EOLandViewController.h"
#import "EOVirtualStickViewController.h"

@interface EOCaptureViewController () <DJICameraDelegate>

@property (nonatomic) BOOL isInRecordVideoMode;
@property (nonatomic) BOOL isRecordingVideo;
@property (nonatomic) NSUInteger recordingTime;

@property (weak, nonatomic) IBOutlet UIView *videoFeedView;

@property (weak, nonatomic) IBOutlet UILabel *recordingTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *startRecordButton;
@property (weak, nonatomic) IBOutlet UIButton *stopRecordButton;

@property (assign, nonatomic) BOOL isSimulatorOn;
@property (nonatomic, weak) NSTimer *timer;

-(IBAction) onEnterVirtualStickControlButtonClicked:(id)sender;
-(IBAction) landBtn:(id)sender;

@property (nonatomic) VideoPreviewerSDKAdapter *previewerAdapter;

@end

@implementation EOCaptureViewController
{
    float mXVelocity;
    float mYVelocity;
    float mYaw;
    float mThrottle;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setVideoPreview];
    
    // set delegate to render camera's video feed into the view
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        [camera setDelegate:self];
    }
    
    self.isInRecordVideoMode = NO;
    self.isRecordingVideo = NO;
    // disable the shoot photo button by default
    [self.startRecordButton setEnabled:NO];
    //[self.stopRecordButton setEnabled:NO];
    
    // start to check the pre-condition
    [self getCameraMode];
    
//    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
//    if (fc && fc.simulator) {
//        self.isSimulatorOn = fc.simulator.isSimulatorActive;
//        fc.rollPitchControlMode = DJIVirtualStickFlightCoordinateSystemBody; // eo
//
//        // [self updateSimulatorUI];
//
////        [fc.simulator addObserver:self forKeyPath:@"isSimulatorStarted" options:NSKeyValueObservingOptionNew context:nil];
////        [fc.simulator setDelegate:self];
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
//    [notificationCenter addObserver: self
//                           selector: @selector (onStickChanged:)
//                               name: @"StickChanged"
//                             object: nil];
    
    
//    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
//    if (fc) {
//        fc.rollPitchControlMode = DJIVirtualStickFlightCoordinateSystemBody; // eo
//
//        // [self onEnterVirtualStickControlButtonClicked:nil];
//    }
    
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc && fc.simulator) {
        self.isSimulatorOn = fc.simulator.isSimulatorActive;
        fc.rollPitchControlMode = DJIVirtualStickFlightCoordinateSystemBody; // eo
        [self onEnterVirtualStickControlButtonClicked:nil];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // clean the delegate
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera && camera.delegate == self) {
        [camera setDelegate:nil];
    }
    
    [self cleanVideoPreview];
    
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc && fc.simulator) {
        [fc.simulator removeObserver:self forKeyPath:@"isSimulatorStarted"];
        [fc.simulator setDelegate:nil];
    }
}

#pragma mark - Precondition
/**
 *  Check if the camera's mode is DJICameraModeRecordVideo.
 *  If the mode is not DJICameraModeRecordVideo, we need to set it to be DJICameraModeRecordVideo.
 *  If the mode is already DJICameraModeRecordVideo, we check the exposure mode.
 */
-(void) getCameraMode {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        WeakRef(target);
        [camera getModeWithCompletion:^(DJICameraMode mode, NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"ERROR: getModeWithCompletion:. %@", error.description);
            }
            else if (mode == DJICameraModeRecordVideo) {
                target.isInRecordVideoMode = YES;
            }
            else {
                [target setCameraMode];
            }
        }];
    }
}

/**
 *  Set the camera's mode to DJICameraModeRecordVideo.
 *  If it succeeds, we can enable the take photo button.
 */
-(void) setCameraMode {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        WeakRef(target);
        [camera setMode:DJICameraModeRecordVideo withCompletion:^(NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"ERROR: setMode:withCompletion:. %@", error.description);
            }
            else {
                // Normally, once an operation is finished, the camera still needs some time to finish up
                // all the work. It is safe to delay the next operation after an operation is finished.
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    WeakReturn(target);
                    target.isInRecordVideoMode = YES;
                });
            }
        }];
    }
}

#pragma mark - Actions
/**
 *  When the pre-condition meets, the start record button should be enabled. Then the user can can record
 *  a video now.
 */
- (IBAction)onStartRecordButtonClicked:(id)sender {
//    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
//    if (fc) {
//        fc.rollPitchControlMode = DJIVirtualStickFlightCoordinateSystemBody; // eo
//        if (fc.rollPitchControlMode == DJIVirtualStickFlightCoordinateSystemBody){
//            NSLog(@"••• mode BODY");
//        } else {
//            NSLog(@"••• mode GROUND");
//        }
//    }
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startRecording) userInfo:nil repeats:NO];
}

- (void) startRecording {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        [self.startRecordButton setEnabled:NO];
        [camera startRecordVideoWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"ERROR: startRecordVideoWithCompletion:. %@", error.description);
            } else {
                [self moveBack:nil];
                [NSTimer scheduledTimerWithTimeInterval:8.0
                                                 target:self
                                               selector:@selector(stopRecordingAndMoveForward)
                                               userInfo:nil
                                                repeats:NO];
            }
        }];
    }
}

- (void) stopRecordingAndMoveForward {
    [self onStopRecordButtonClicked:nil];
    [self moveForward:nil];
}

- (IBAction) landBtn:(id)sender {
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        [fc startLandingWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Land Error:%@", error.localizedDescription);
            }
            else
            {
                // ShowResult(@"Land Succeeded.");
            }
        }];
    }
    else
    {
        ShowResult(@"Component Not Exist");
    }
}

- (IBAction)onNextBtnClicked:(id)sender {
//    EOLandViewController *eoLandVC = [[EOLandViewController alloc] init];
//    [self.navigationController pushViewController:eoLandVC animated:YES];
    EOVirtualStickViewController *eoVSVC = [[EOVirtualStickViewController alloc] init];
    [self.navigationController pushViewController:eoVSVC animated:YES];
}

/**
 *  When the camera is recording, the stop record button should be enabled. Then the user can stop recording
 *  the video.
 */
- (IBAction)onStopRecordButtonClicked:(id)sender {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
//        [self.stopRecordButton setEnabled:NO];
        [camera stopRecordVideoWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"ERROR: stopRecordVideoWithCompletion:. %@", error.description);
            }
            
        }];
    }
}



#pragma mark - UI related
- (void)setVideoPreview {
    [[VideoPreviewer instance] start];
    [[VideoPreviewer instance] setView:self.videoFeedView];
    self.previewerAdapter = [VideoPreviewerSDKAdapter adapterWithDefaultSettings];
    [self.previewerAdapter start];
}

- (void)cleanVideoPreview {
    [[VideoPreviewer instance] unSetView];
    if (self.previewerAdapter) {
    	[self.previewerAdapter stop];
    	self.previewerAdapter = nil;
    }
}

-(void) setIsInRecordVideoMode:(BOOL)isInRecordVideoMode {
    _isInRecordVideoMode = isInRecordVideoMode;
    [self toggleRecordUI];
}

-(void) setIsRecordingVideo:(BOOL)isRecordingVideo {
    _isRecordingVideo = isRecordingVideo;
    [self toggleRecordUI];
}

-(void) toggleRecordUI {
    [self.startRecordButton setEnabled:(self.isInRecordVideoMode && !self.isRecordingVideo)];
//    [self.stopRecordButton setEnabled:(self.isInRecordVideoMode && self.isRecordingVideo)];
    if (!self.isRecordingVideo) {
        self.recordingTimeLabel.text = @"00:00";
    }
    else {
        int hour = (int)self.recordingTime / 3600;
        int minute = (self.recordingTime % 3600) / 60;
        int second = (self.recordingTime % 3600) % 60;
        self.recordingTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hour, minute, second];
    }
}

#pragma mark - virtual sticks

-(IBAction) moveBack:(id)sender {
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                              target:self
                                            selector:@selector(pullJoystick)
                                            userInfo:nil
                                             repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:8.0
                                     target:self
                                   selector:@selector(testMoveStop)
                                   userInfo:nil
                                    repeats:NO];
    
    //    [self performSelector:@selector(testMoveStop) withObject:nil afterDelay:10.0];
}

-(IBAction) moveForward:(id)sender {
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                              target:self
                                            selector:@selector(pushJoystick)
                                            userInfo:nil
                                             repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:6.0
                                     target:self
                                   selector:@selector(testMoveStop)
                                   userInfo:nil
                                    repeats:NO];
    
    //    [self performSelector:@selector(testMoveStop) withObject:nil afterDelay:10.0];
}

-(void) pullJoystick {
    // move backwards (in body-based coordinate system)
    [self setXVelocity:0.1 andYVelocity:0.09];
}

-(void) pushJoystick {
    // move forwards (in body-based coordinate system)
    [self setXVelocity:-0.1 andYVelocity:-0.09];
}

-(void) testMoveStop {
    [_timer invalidate];
    _timer = nil;
    [self setXVelocity:0.0 andYVelocity:0.0];
}

-(void) setXVelocity:(float)x andYVelocity:(float)y {
    mXVelocity = x * 5.0;
    mYVelocity = y * 5.0;
    [self updateJoystick];
}

-(void) updateJoystick
{
    // In rollPitchVelocity mode, the pitch property in DJIVirtualStickFlightControlData represents the Y direction velocity.
    // The roll property represents the X direction velocity.
    DJIVirtualStickFlightControlData ctrlData = {0};
    ctrlData.pitch = mYVelocity;
    ctrlData.roll = mXVelocity;
    ctrlData.yaw = mYaw;
    ctrlData.verticalThrottle = mThrottle;
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc && fc.isVirtualStickControlModeAvailable) {
        [fc sendVirtualStickFlightControlData:ctrlData withCompletion:nil];
    }
}

-(IBAction) onEnterVirtualStickControlButtonClicked:(id)sender
{
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        fc.yawControlMode = DJIVirtualStickYawControlModeAngularVelocity;
        fc.rollPitchControlMode = DJIVirtualStickRollPitchControlModeVelocity;
        
        [fc setVirtualStickModeEnabled:YES withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Enter Virtual Stick Mode:%@", error.description);
            }
            else
            {
                // ShowResult(@"Enter Virtual Stick Mode:Succeeded");
            }
        }];
    }
    else
    {
        ShowResult(@"Component not exist.");
    }
}


#pragma mark - DJICameraDelegate
-(void)camera:(DJICamera *)camera didReceiveVideoData:(uint8_t *)videoBuffer length:(size_t)length
{
    [[VideoPreviewer instance] push:videoBuffer length:(int)length];
}

-(void)camera:(DJICamera *)camera didUpdateSystemState:(DJICameraSystemState *)systemState {
    self.isRecordingVideo = systemState.isRecording;
    
    self.recordingTime = systemState.currentVideoRecordingTimeInSeconds;
}

@end
