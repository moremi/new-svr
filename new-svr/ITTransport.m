//
//  ITTransport.m
//  new-svr
//
//  Created by Vlad on 07.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import "ITTransport.h"
#import "ITPeerRoleMessage.h"

@interface ITTransport ()
@property (nonatomic, weak) id<ITSession> session;
@end

@implementation ITTransport

- (instancetype)initWithSession:(id<ITSession>)session
{
    self = [super init];
    if (self) {
        self.session = session;
    }
    return self;
}

#pragma mark - Public methods

- (void)sendTelemetryRequestToPeers
{
    //NSData *deviceType = [[ITDeviceType deviceType] dataUsingEncoding:NSUTF8StringEncoding];
    ITPeerRoleMessage *telemetryRequest = [[ITPeerRoleMessage alloc] initWithType:ITPeerRoleMessageTypeTelemetryRequest andContentData:nil];
    [self.session sendData:[telemetryRequest messageData] toPeers:self.session.peers];
}

- (void)sendTelemetry:(NSData *)telemetry toPeer:(id<ITPeer>)peer
{
    ITPeerRoleMessage *telemetryMessage = [[ITPeerRoleMessage alloc] initWithType:ITPeerRoleMessageTypeTelemetryResponse
                                                                   andContentData:telemetry];
    [self.session sendData:[telemetryMessage messageData] toPeers:@[peer]];
}

- (void)sendBeMasterToPeer:(id<ITPeer>)masterPeer withSlave:(id<ITPeer>)slavePeer
{
    NSData *slavePeerData = [slavePeer.peerID dataUsingEncoding:NSUTF8StringEncoding];
    ITPeerRoleMessage *masterMessage = [[ITPeerRoleMessage alloc] initWithType:ITPeerRoleMessageTypeBeMaster andContentData:slavePeerData];
    [self.session sendData:[masterMessage messageData] toPeers:@[masterPeer]];
}

- (void)sendBeSlaveToPeer:(id<ITPeer>)slavePeer withMaster:(id<ITPeer>)masterPeer
{
    NSData *masterPeerData = [masterPeer.peerID dataUsingEncoding:NSUTF8StringEncoding];
    ITPeerRoleMessage *slaveMessage = [[ITPeerRoleMessage alloc] initWithType:ITPeerRoleMessageTypeBeSlave andContentData:masterPeerData];
    [self.session sendData:[slaveMessage messageData] toPeers:@[masterPeer]];
}

#pragma mark - <ITSessionDelegate>

- (void)didReceiveData:(NSData *)data fromPeer:(id<ITPeer>)peer
{
    ITPeerRoleMessage *message = [[ITPeerRoleMessage alloc] initWithMessageData:data];
    switch (message.type) {
        case ITPeerRoleMessageTypeTelemetryResponse:{
            [self.delegate gotTelemetryResponse:message.content fromPeer:peer];
        }
            break;
        case ITPeerRoleMessageTypeTelemetryRequest:{
            [self.delegate gotTelemetryRequestFromPeer:peer];
        }
            break;
        case ITPeerRoleMessageTypeBeSlave:{
            NSString *masterID = [[NSString alloc] initWithData:message.content encoding:NSUTF8StringEncoding];
            id<ITPeer> masterPeer;
            for (id<ITPeer> peer in self.session.peers) {
                if ([peer.peerID isEqualToString:masterID]) {
                    masterPeer = peer;
                    break;
                }
            }
            [self.delegate gotBeSlaveWithMaster:masterPeer];
        }
            break;
        case ITPeerRoleMessageTypeBeMaster:{
            NSString *slaveID = [[NSString alloc] initWithData:message.content encoding:NSUTF8StringEncoding];
            id<ITPeer> slavePeer;
            for (id<ITPeer> peer in self.session.peers) {
                if ([peer.peerID isEqualToString:slaveID]) {
                    slavePeer = peer;
                    break;
                }
            }
            [self.delegate gotBeMasterWithSlave:slavePeer];
        }
            break;
        case ITPeerRoleMessageTypeMasterApproved:{
           
        }
            break;
        case ITPeerRoleMessageTypeSlaveApproved:{
        
        }
            break;
        case ITPeerRoleMessageTypeInvalidMessage:{
            NSLog(@"Got wrong ITPeerRoleMessageType");
        }
            break;
        case ITPeerRoleMessageTypeStopShaking:{
            
        }
            break;
    }
}

@end
