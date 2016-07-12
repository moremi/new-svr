//
//  ITPeerRolesEstablisher.h
//  new-svr
//
//  Created by Vlad on 06.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITPeer.h"
#import "ITSession.h"
#import "ITTransport.h"

@class ITPeerRolesEstablisher;

typedef NS_ENUM(UInt8, ITPeerRolesEstablisherStatus){
    ITPeerRolesEstablisherStatusNone = 0,
    ITPeerRolesEstablisherStatusStarted,
    ITPeerRolesEstablisherStatusPrimeFounded,
    ITPeerRolesEstablisherStatusPeersConnected,
    ITPeerRolesEstablisherStatusTelemetryReceived,
    ITPeerRolesEstablisherStatusMasterSlaveSelected,
    ITPeerRolesEstablisherStatusMasterSlaveNotified,
    ITPeerRolesEstablisherStatusStopped
};

@protocol ITPeerRolesEstablisherDelegate <NSObject>
- (void)gotMasterRoleFromRolesEstablisher:(nonnull ITPeerRolesEstablisher *)rolesEstablisher withSlavePeer:(nonnull id<ITPeer>)slavePeer;
- (void)gotSlaveRoleFromRolesEstablisher:(nonnull ITPeerRolesEstablisher *)rolesEstablisher withMasterPeer:(nonnull id<ITPeer>)masterPeer;
- (void)notFoundEnoughPeersInRolesEstablisher:(nonnull ITPeerRolesEstablisher *)rolesEstablisher;
@optional
- (void)rolesEstablisher:(nonnull ITPeerRolesEstablisher *)rolesEstablisher statusChangedTo:(ITPeerRolesEstablisherStatus) status;
@end

@interface ITPeerRolesEstablisher : NSObject <ITTransportDelegate>
@property (nonatomic, weak, nullable) id<ITPeerRolesEstablisherDelegate> delegate;
@property (nonatomic, readonly, nullable) id<ITSession> rolesSession;

- (instancetype)initWithHostPeer:(nonnull id<ITPeer>)hostPeer rolesSession:(nonnull id<ITSession>)rolesSession transport:(nonnull ITTransport *)transport;
- (void)tryEstablishMasterAndSlavePeersInDiscoveredPeers:(nonnull NSArray <id<ITPeer>> *)discoveredPeers;

- (id<ITPeer>)findPrimePeerFromDiscoveredPeers:(NSArray *)discoveredPeers withHostPeer:(id<ITPeer>)hostPeer;
- (void)inviteDiscoveredPeers:(NSArray <id<ITPeer>> *)discoveredPeers intoSession:(id<ITSession>)session;

@end
