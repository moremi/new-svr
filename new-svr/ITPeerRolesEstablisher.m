//
//  ITPeerRolesEstablisher.m
//  new-svr
//
//  Created by Vlad on 06.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import "ITPeerRolesEstablisher.h"
#import "ITPeerRoleMessage.h"
#import "ITConnectingAssembly.h"

const NSTimeInterval kTimeToCheckSession = 2; //sec
const NSTimeInterval kTimeToWaitTelemetryResponses = 3; //sec
const NSTimeInterval kTimeToWaitForTelemetry = 2; //sec

@interface ITPeerRolesEstablisher ()
@property (nonatomic) NSArray<id<ITPeer>> *discoveredPeers;
@property (nonatomic) id<ITPeer> hostPeer;
@property (nonatomic) id<ITPeer> primePeer;
@property (nonatomic) id<ITPeer> masterPeer;
@property (nonatomic) id<ITPeer> slavePeer;
@property (nonatomic, readwrite, nullable) id<ITSession> rolesSession;
@property (nonatomic) ITTransport *transport;
@property (nonatomic) ITPeerRolesEstablisherStatus status;
@property (nonatomic) NSMutableDictionary <NSString *, NSObject*> *peersTelemetry;
@end

@implementation ITPeerRolesEstablisher

- (instancetype)initWithHostPeer:(id<ITPeer>)hostPeer rolesSession:(id<ITSession>)rolesSession transport:(ITTransport *)transport
{
    self = [super init];
    if (self) {
        self.hostPeer = hostPeer;
        self.rolesSession = rolesSession;
        self.transport = transport;
        self.rolesSession.delegate = self.transport;
        self.transport.delegate = self;
        self.peersTelemetry = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Setters
- (void)setStatus:(ITPeerRolesEstablisherStatus)status
{
    _status = status;
    switch (status) {
        case ITPeerRolesEstablisherStatusStarted:{
            self.primePeer = nil;
            self.primePeer = [self findPrimePeerFromDiscoveredPeers:self.discoveredPeers withHostPeer:self.hostPeer];
            if (self.primePeer != nil) self.status = ITPeerRolesEstablisherStatusPrimeFounded;
        }
            break;
        case ITPeerRolesEstablisherStatusPrimeFounded:{
            if ([self.primePeer.peerID isEqualToString:self.hostPeer.peerID]) {
                [self inviteDiscoveredPeers:self.discoveredPeers intoSession:self.rolesSession];
                [self checkConnectedToSessionPeersAfterDelay:kTimeToCheckSession];
            }
        }
            break;
        case ITPeerRolesEstablisherStatusPeersConnected:{
            [self sendTelemetryRequestToPeers];
        }
            break;
        case ITPeerRolesEstablisherStatusTelemetryReceived:{
            [self chooseMasterAndSlaveByTelemetryData:self.peersTelemetry];
        }
            break;
        case ITPeerRolesEstablisherStatusMasterSlaveSelected:{
            [self invitePeersToBeMaster:self.masterPeer andSlave:self.slavePeer];
        }
            break;
        case ITPeerRolesEstablisherStatusMasterSlaveNotified:{
            
        }
            break;
        default:
            break;
    }
}

#pragma mark - Private methods
#pragma mark - Status Started

- (id<ITPeer>)findPrimePeerFromDiscoveredPeers:(NSArray *)discoveredPeers withHostPeer:(id<ITPeer>)hostPeer
{
    if (discoveredPeers.count > 0) {
        NSMutableArray *allPeers = [[NSMutableArray alloc] init];
        [allPeers addObject:hostPeer];
        [allPeers addObjectsFromArray:discoveredPeers];
        NSArray *sortedPeers = [allPeers sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            id<ITPeer> firstPeer = (id<ITPeer>)obj1;
            id<ITPeer> secondPeer = (id<ITPeer>)obj2;
            return [firstPeer.peerID compare:secondPeer.peerID options:NSLiteralSearch];
        }];
        for (id<ITPeer> peer in sortedPeers) {
            NSLog(@"__%@",peer.peerID);
        }
        id<ITPeer> peer = (id<ITPeer>)sortedPeers.firstObject;
        NSLog(@"__%@",peer.peerID);
        return sortedPeers.firstObject;
        
    } else {
        return nil;
    }
}

#pragma mark - Status PrimeFounded

- (void)inviteDiscoveredPeers:(NSArray <id<ITPeer>> *)discoveredPeers
                  intoSession:(id<ITSession>)session
{
    for (id<ITPeer> peer in discoveredPeers) {
        [session invitePeer:peer];
    }
}

- (void)checkConnectedToSessionPeersAfterDelay:(NSTimeInterval)delay
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"Check connected to session peers");
        if (self.rolesSession.peers.count < 1) {
            NSLog(@"Not enough peers connected to the session");
            if ([self.delegate respondsToSelector:@selector(notFoundEnoughPeersInRolesEstablisher:)]) {
                [self.delegate notFoundEnoughPeersInRolesEstablisher:self];
            }
        } else {
            self.status = ITPeerRolesEstablisherStatusPeersConnected;
        }
    });
}

#pragma mark - Status PeersConnected

- (void)sendTelemetryRequestToPeers
{
    [self.peersTelemetry removeAllObjects];
    [self.transport sendTelemetryRequestToPeers];
    NSData *telemetryData = [self prepareTelemetryData];
    [self.peersTelemetry setObject:telemetryData forKey:self.hostPeer.peerID];
    [self checkReceivedTelemetryAfterDelay:kTimeToWaitTelemetryResponses];
}

- (NSData *)prepareTelemetryData
{
    //ITAccelerationManager *manager = [ITAccelerationManager new];
    return [[NSData alloc] init];//[manager fetchTelemetryWithTimeout:kTimeToWaitForTelemetry];
}

- (void)checkReceivedTelemetryAfterDelay:(NSTimeInterval)delay
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"Check received telemetry");
        if (self.peersTelemetry.allKeys.count < 2) {
            NSLog(@"Not enough telemetry data received");
            if ([self.delegate respondsToSelector:@selector(notFoundEnoughPeersInRolesEstablisher:)]) {
                [self.delegate notFoundEnoughPeersInRolesEstablisher:self];
            }
        } else {
            self.status = ITPeerRolesEstablisherStatusTelemetryReceived;
        }
    });
}

#pragma mark - Status TelemetryReceived

- (id<ITPeer>)peerFromPeerID:(NSString *)peerID
{
    for (id<ITPeer> peer in self.discoveredPeers) {
        if ([peer.peerID isEqualToString:peerID])
        {
            return peer;
        }
    }
    return nil;
}

- (void)chooseMasterAndSlaveByTelemetryData:(NSDictionary<NSString *, NSObject *> *)telemetryData
{
    for (NSString *firstPeer in self.peersTelemetry.allKeys) {
        for (NSString *secondPeer in self.peersTelemetry.allKeys) {
            if (![firstPeer isEqualToString:secondPeer]) {
                /*if ([ITCorrelationRecognizer isFirstDeviceData:(NSData *)[self.peersTelemetry objectForKey:firstPeer]
                                 correlatingToSecondDeviceData:(NSData *)[self.peersTelemetry objectForKey:secondPeer]]) {*/
                if (0==0) {
                    
#warning choose who is master & slave properly
                    
                    self.masterPeer = [self peerFromPeerID:firstPeer];
                    self.slavePeer = [self peerFromPeerID:secondPeer];
                    
                    NSLog(@"slave will be  %@, \nmaster will be %@", firstPeer, secondPeer);
                    
                    self.status = ITPeerRolesEstablisherStatusMasterSlaveSelected;
                    
                    if (![self.hostPeer.peerID isEqualToString:self.masterPeer.peerID] && ![self.hostPeer.peerID isEqualToString:self.slavePeer.peerID]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"noshake" object:nil];
                    }
                    return;
                }
            }
        }
    }
    NSLog(@"NO CORRELATING DEVICES. Repeat");
    self.status = ITPeerRolesEstablisherStatusPrimeFounded;
}

#pragma mark - Status MasterSlaveSelected

- (void)invitePeersToBeMaster:(id<ITPeer>)masterPeer andSlave:(id<ITPeer>)slavePeer
{    
    if ([masterPeer.peerID isEqualToString:self.hostPeer.peerID]){
        [self gotBeMasterWithSlave:slavePeer];
    } else {
        [self.transport sendBeMasterToPeer:masterPeer withSlave:slavePeer];
    }
    
    if ([slavePeer.peerID isEqualToString:self.hostPeer.peerID]){        
        [self gotBeSlaveWithMaster:masterPeer];
    } else {
        [self.transport sendBeSlaveToPeer:slavePeer withMaster:masterPeer];
    }
}

#pragma mark - Public methods

- (void)tryEstablishMasterAndSlavePeersInDiscoveredPeers:(NSArray<id<ITPeer>> *)discoveredPeers
{
    self.discoveredPeers = discoveredPeers;
    self.status = ITPeerRolesEstablisherStatusStarted;
}

#pragma mark - <ITTransportDelegate>

- (void)gotTelemetryRequestFromPeer:(id<ITPeer>)peer
{
    NSData *telemetryData = [self prepareTelemetryData];
    [self.transport sendTelemetry:telemetryData toPeer:peer];
}

- (void)gotTelemetryResponse:(NSData *)response fromPeer:(id<ITPeer>)peer
{
    [self.peersTelemetry setObject:response forKey:peer.peerID];
}

- (void)gotBeSlaveWithMaster:(id<ITPeer>)masterPeer
{
    if ([self.delegate respondsToSelector:@selector(gotSlaveRoleFromRolesEstablisher:withMasterPeer:)]){
        [self.delegate gotSlaveRoleFromRolesEstablisher:self withMasterPeer:masterPeer];
    }
}

- (void)gotBeMasterWithSlave:(id<ITPeer>)slavePeer
{
    if ([self.delegate respondsToSelector:@selector(gotMasterRoleFromRolesEstablisher:withSlavePeer:)]){
        [self.delegate gotMasterRoleFromRolesEstablisher:self withSlavePeer:slavePeer];
    }
}

@end
