//
//  ITSessionsController.m
//  new-svr
//
//  Created by Vlad on 06.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import "ITSessionsController.h"
#import "ITSession.h"

typedef NS_ENUM(NSUInteger, ITSessionsControllerPhase) {
    ITSessionsControllerPhasePeersNone,
    ITSessionsControllerPhasePeersDiscovering,
    ITSessionsControllerPhaseMasterSlaveDetection,
    ITSessionsControllerPhaseMasterSlaveSessionEstablished
};

static const NSTimeInterval kDiscoveryTime = 2; //sec

@interface ITSessionsController () <ITPeersDetectorDelegate, ITPeerRolesEstablisherDelegate>
@property (nonatomic) ITPeersDetector *peersDetector;
@property (nonatomic) ITPeerRolesEstablisher *rolesEstablisher;
@property (nonatomic) NSMutableArray<ITPeer *> *discoveredPeers;
@property (nonatomic) ITSession *masterSlaveSession;
@property (nonatomic) ITSessionsControllerPhase phase;
@end

@implementation ITSessionsController

- (instancetype)initWithPeersDetector:(ITPeersDetector *)peersDetector peerRolesEstablisher:(ITPeerRolesEstablisher *)peerRolesEstablisher
{
    self = [super init];
    if (self) {
        self.peersDetector = peersDetector;
        self.peersDetector.delegate = self;
        self.rolesEstablisher = peerRolesEstablisher;
        self.rolesEstablisher.delegate = self;
        self.discoveredPeers = [[NSMutableArray<ITPeer *> alloc] init];
        [self.peersDetector startDiscovering];
    }
    return self;
}


- (void)setPhase:(ITSessionsControllerPhase)phase {
    _phase = phase;
    switch (phase) {
        case ITSessionsControllerPhasePeersNone: {
            [self.peersDetector stopDiscovering];
        }
            break;
            
        case ITSessionsControllerPhasePeersDiscovering: {
            [self checkDiscoveredPeersAfterDelay:kDiscoveryTime];
        }
            break;
            
        case ITSessionsControllerPhaseMasterSlaveDetection: {
            [self findMasterAndSlavePeers];
        }
            break;
            
        case ITSessionsControllerPhaseMasterSlaveSessionEstablished: {
            
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Private Methods

- (void)checkDiscoveredPeersAfterDelay:(NSTimeInterval)delayInSec {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delayInSec * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.phase == ITSessionsControllerPhasePeersDiscovering) {
            [self checkNumberOfDiscoveredPeers];
        }
    });
}

- (void)checkNumberOfDiscoveredPeers {
    if (self.phase == ITSessionsControllerPhasePeersDiscovering) {
        if (self.discoveredPeers.count > 0) {
            self.phase = ITSessionsControllerPhaseMasterSlaveDetection;
        } else {
            self.phase = ITSessionsControllerPhasePeersDiscovering;
        }
    }
}

- (void)findMasterAndSlavePeers {
    [self.rolesEstablisher tryEstablishMasterAndSlavePeersInDiscoveredPeers:self.discoveredPeers];
}

#pragma mark - Public methods

- (void)establishMasterSlaveSession
{
    self.phase = ITSessionsControllerPhasePeersDiscovering;
}

- (void)stopMasterSlaveSession
{
    self.phase = ITSessionsControllerPhasePeersNone;
}

#pragma mark - <ITPeersDetectorDelegate>

- (void)peersDetector:(ITPeersDetector *)peersDetector foundPeer:(ITPeer *)peer
{
    if (![self.discoveredPeers containsObject:peer])
    {
        [self.discoveredPeers addObject:peer];
    }
}

- (void)peersDetector:(ITPeersDetector *)peersDetector lostPeer:(ITPeer *)peer
{
    if ([self.discoveredPeers containsObject:peer])
    {
        [self.discoveredPeers removeObject:peer];
    }
}

#pragma mark - <ITPeerRolesEstablisherDelegate>

- (void)gotMasterRoleFromRolesEstablisher:(nonnull ITPeerRolesEstablisher *)rolesEstablisher withSlavePeer:(nonnull ITPeer *)slavePeer
{
    ITMasterSessionManager *masterSessionManager = [[ITMasterSessionManager alloc] initWithSession:self.masterSlaveSession andSlavePeer:slavePeer];
    [self.delegate sessionController:self didEstablishMasterSession:masterSessionManager];
    [self.masterSlaveSession invitePeer:slavePeer];
}

- (void)gotSlaveRoleFromRolesEstablisher:(nonnull ITPeerRolesEstablisher *)rolesEstablisher withMasterPeer:(nonnull ITPeer *)masterPeer
{
    ITSlaveSessionManager *slaveSessionManager = [[ITSlaveSessionManager alloc] initWithSession:self.masterSlaveSession andMasterPeer:masterPeer];
    [self.delegate sessionController:self didEstablishSlaveSession:slaveSessionManager];
}

- (void)notFoundEnoughPeersInRolesEstablisher:(nonnull ITPeerRolesEstablisher *)rolesEstablisher
{
    self.phase = ITSessionsControllerPhasePeersDiscovering;
}


@end