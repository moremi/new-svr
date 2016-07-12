//
//  ITMasterSessionManager.h
//  new-svr
//
//  Created by Vlad on 06.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITSession.h"

@class ITMasterSessionManager;
@protocol ITMultipeerSessionInviter;

@protocol ITMasterSessionManagerDelegate <NSObject>
- (void)masterSessionManager:(ITMasterSessionManager *)masterSessionManager didFinishTimeSyncWithDelayOnSlave:(NSTimeInterval)slaveDelay;
- (void)masterShouldStop;
- (void)masterSessionManagerConnectedToSlave;
@end


@interface ITMasterSessionManager : NSObject
@property (nonatomic, weak) id<ITMasterSessionManagerDelegate> delegate;
@property (strong, nonatomic) id<ITPeer> masterPeer;
@property (strong, nonatomic) id<ITPeer> slavePeer;

- (instancetype)initWithSession:(id<ITSession>)session andSlavePeer:(id<ITPeer>)slavePeer;
- (void)syncTimeWithSlave;
- (void)sendStartRecordingPacketAtTime:(NSTimeInterval)startRecordTime withVideoID:(NSString *)videoID;
- (void)sendStopRecordingPacketAtTime:(NSTimeInterval)stopRecordTime;
- (void)downloadSlaveVideo:(NSString *)videoID fromOffset:(uint64_t)offset;
- (void)disconnect;
@end
