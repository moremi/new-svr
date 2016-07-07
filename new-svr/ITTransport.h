//
//  ITTransport.h
//  new-svr
//
//  Created by Vlad on 07.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITSession.h"

@protocol ITTransportDelegate <NSObject>
- (void)gotTelemetryRequestFromPeer:(id<ITPeer>)peer;
- (void)gotTelemetryResponse:(NSData *)response fromPeer:(id<ITPeer>)peer;
- (void)gotBeSlaveWithMaster:(id<ITPeer>)masterPeer;
- (void)gotBeMasterWithSlave:(id<ITPeer>)slavePeer;
@end


@interface ITTransport : NSObject <ITSessionDelegate>
@property (nonatomic, weak) id<ITTransportDelegate> delegate;
- (instancetype)initWithSession:(id<ITSession>)session;
- (void)sendTelemetryRequestToPeers;
- (void)sendTelemetry:(NSData *)telemetry toPeer:(id<ITPeer>)peer;
- (void)sendBeMasterToPeer:(id<ITPeer>)masterPeer withSlave:(id<ITPeer>)slavePeer;
- (void)sendBeSlaveToPeer:(id<ITPeer>)slavePeer withMaster:(id<ITPeer>)masterPeer;
@end
