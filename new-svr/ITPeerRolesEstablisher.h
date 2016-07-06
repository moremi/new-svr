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

@protocol ITPeerRolesEstablisherDelegate
- (void)gotMasterRoleFromRolesEstablisher:(nonnull ITPeerRolesEstablisher *)rolesEstablisher withSlavePeer:(nonnull ITPeer *)slavePeer;
- (void)gotSlaveRoleFromRolesEstablisher:(nonnull ITPeerRolesEstablisher *)rolesEstablisher withMasterPeer:(nonnull ITPeer *)masterPeer;
- (void)notFoundEnoughPeersInRolesEstablisher:(nonnull ITPeerRolesEstablisher *)rolesEstablisher;
@optional
- (void)rolesEstablisher:(nonnull ITPeerRolesEstablisher *) rolesEstablisher statusChangedTo:(ITPeerRolesEstablisherStatus) status;
@end

@interface ITPeerRolesEstablisher : NSObject
@property (nonatomic, weak, nullable) id<ITPeerRolesEstablisherDelegate> delegate;
@property (nonatomic, readonly, nullable) ITSession *rolesSession;

- (void)tryEstablishMasterAndSlavePeersInDiscoveredPeers:(nonnull NSArray <ITPeer *> *)discoveredPeers;

@end
