//
//  DJIVideoFeeder.h
//  DJISDK
//
//  Copyright © 2017, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 *  The physical source of a video feed.
 */
typedef NS_ENUM(NSInteger, DJIVideoFeedPhysicalSource) {

    /**
     *  The video feed is from the main camera. It is the physical source used by most
     *  of DJI products.
     */
    DJIVideoFeedPhysicalSourceMainCamera,
    

    /**
     *  The video feed is from the FPV camera on Inspire 2 or M200 series.
     */
    DJIVideoFeedPhysicalSourceFPVCamera,


    /**
     *  The video feed is from one of the LB ports (AV or HDMI) while EXT Port is
     *  enabled.  It is only used for Lightbridge 2 or aircrafts with Lightbridge 2
     *  (e.g. M600).
     */
    DJIVideoFeedPhysicalSourceLB,


    /**
     *  The video feed is from EXT port while EXT port is enabled. It is only used for
     *  Lightbridge 2 or aircrafts with Lightbridge 2 (e.g. M600).
     */
    DJIVideoFeedPhysicalSourceEXT,


    /**
     *  The video feed is from HDMI port while EXT port is disabled. It is only used for
     *  Lightbridge 2 or aircrafts with Lightbridge 2 (e.g. M600).
     */
    DJIVideoFeedPhysicalSourceHDMI,


    /**
     *  The video feed is from AV port while EXT port is disabled. It is only used for
     *  Lightbridge 2 or aircrafts with Lightbridge 2 (e.g. M600).
     */
    DJIVideoFeedPhysicalSourceAV,

    /**
     *  Unknown video physical source.
     */
    DJIVideoFeedPhysicalSourceUnknown = 0xFF,
};

@class DJIVideoFeed;


/**
 *  Listener that receives notifications when a new video physical source becomes
 *  available.
 */
@protocol DJIVideoFeedSourceListener <NSObject>


/**
 *  Called when a video feed is made available from a new physical source.
 *  
 *  @param videoFeed A `DJIVideoFeed` object.
 *  @param physicalSource An enum value of `DJIVideoFeedPhysicalSource`.
 */
- (void)videoFeed:(nonnull DJIVideoFeed *)videoFeed didChangePhysicalSource:(DJIVideoFeedPhysicalSource)physicalSource;

@end


/**
 *  Represents a single video feed from a single channel or port.
 */
@protocol DJIVideoFeedListener <NSObject>


/**
 *  Called when the video feed receives new video data.
 *  
 *  @param videoFeed A `DJIVideoFeed` object.
 *  @param videoData New video data.
 */
- (void)videoFeed:(nonnull DJIVideoFeed *)videoFeed didUpdateVideoData:(nonnull NSData *)videoData;

@end


/**
 *  Video feed. Use it to receive video data from a physical source.
 */
@interface DJIVideoFeed : NSObject


/**
 *  The physical source of the video feed.
 */
@property (nonatomic, assign, readonly) DJIVideoFeedPhysicalSource physicalSource;


/**
 *  Add listener to receive new video data.
 *  
 *  @param videoFeedListener Listener to receive video data.
 *  @param queue The queue that `videoFeed:didUpdateVideoData` is called in.
 */
- (void)addListener:(id <DJIVideoFeedListener>)videoFeedListener withQueue:(nullable dispatch_queue_t)queue;


/**
 *  Remove listener to stop receiving new video data.
 *  
 *  @param videoFeedListener Listener to remove.
 */
- (void)removeListener:(id <DJIVideoFeedListener>)videoFeedListener;


/**
 *  Remove all Listeners for video feed.
 */
- (void)removeAllListeners;

@end


/**
 *  Class that manage live video feed from DJI products to the mobile device.
 */
@interface DJIVideoFeeder : NSObject


/**
 *  The primary video feed.
 *   The possilbe physical sources for the primary video feed include:
 *   - `DJIVideoFeedPhysicalSourceMainCamera`
 *   -  `DJIVideoFeedPhysicalSourceLB`
 *   -  `DJIVideoFeedPhysicalSourceHDMI`
 */
@property (nonatomic, strong, nonnull) DJIVideoFeed *primaryVideoFeed;


/**
 *  The secondary video feed.
 *   The possilbe physical sources for the secondary video feed include:
 *   - `DJIVideoFeedPhysicalSourceFPVCamera`
 *   -  `DJIVideoFeedPhysicalSourceEXT`
 *   -  `DJIVideoFeedPhysicalSourceAV`
 */
@property (nonatomic, strong, nonnull) DJIVideoFeed *secondaryVideoFeed;


/**
 *  Add listener to receive the physical source changes.
 *  
 *  @param sourceListener Listener to add.
 */
- (void)addVideoFeedSourceListener:(id <DJIVideoFeedSourceListener>)sourceListener;


/**
 *  Remove listener to stop receiving the physical source changes.
 *  
 *  @param sourceListener Listener to remove.
 */
- (void)removeVideoFeedSourceListener:(id <DJIVideoFeedSourceListener>)sourceListener;


/**
 *  Remove all listeners.
 */
- (void)removeAllListeners;

@end

NS_ASSUME_NONNULL_END
