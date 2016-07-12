//
//  new_svrTests.m
//  new-svrTests
//
//  Created by Vlad on 05.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ITPeerRolesEstablisher.h"
#import "ITBonjourPeer.h"
#import "ITBonjourSession.h"
#import "ITTransport.h"

#import "OCMock.h"

@interface PeerRolesEstablisherTests : XCTestCase

@property (nonatomic, strong) id peer;
@property (nonatomic, strong) id session;
@property (nonatomic, strong) id transport;

@end

@implementation PeerRolesEstablisherTests

- (void)setUp {
    [super setUp];
    
    self.peer = OCMClassMock(ITBonjourPeer.class);
    OCMStub([self.peer peerID]).andReturn(@"   !!");
    self.session = OCMClassMock(ITBonjourSession.class);
    self.transport = OCMClassMock([ITTransport class]);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testFindPrimePeerFromDiscoveredPeers
{
    ITPeerRolesEstablisher *role = [[ITPeerRolesEstablisher alloc] initWithHostPeer:self.peer
                                                                       rolesSession:self.session
                                                                          transport:self.transport];
//    id delegate = OCMProtocolMock(@protocol(ITPeerRolesEstablisherDelegate));
    
    NSMutableArray<id<ITPeer>> *arr = [[NSMutableArray<id<ITPeer>> alloc] init];
    for (int i=0; i<10; i++) {
        id peer = OCMClassMock(ITBonjourPeer.class);
        NSString *identifier = [NSUUID UUID].UUIDString;
        OCMStub([peer peerID]).andReturn(identifier);
        NSLog(@"id: %@", identifier);
        [arr addObject:peer];
    }
    
    XCTAssertNotNil([role findPrimePeerFromDiscoveredPeers:arr withHostPeer:self.peer]);
    XCTAssertNil([role findPrimePeerFromDiscoveredPeers:@[] withHostPeer:self.peer]);
    ITBonjourSession *session = [[ITBonjourSession alloc] initWithHostPeer:self.peer];
    [role inviteDiscoveredPeers:arr intoSession:session];
    XCTAssertEqual(session.peers.count, arr.count);
    
    
//    OCMExpect([delegate notFoundEnoughPeersInRolesEstablisher:role]);
//    /*
//    OCMStub([self.transport sendTelemetryRequestToPeers]).andDo(^(NSInvocation *invocation)
//                                                            {[role gotTelemetryResponse:[[NSData alloc] init] fromPeer:self.peer]; });*/
//
//    [role tryEstablishMasterAndSlavePeersInDiscoveredPeers:@[]];
//    
//    OCMVerifyAllWithDelay(delegate, 10.0);
}

- (void)testTryEstablish
{
    OCMExpect([self.transport sendBeSlaveToPeer:[OCMArg any] withMaster:[OCMArg any]]);
    ITBonjourSession *session = [[ITBonjourSession alloc] initWithHostPeer:self.peer];
    ITPeerRolesEstablisher *role = [[ITPeerRolesEstablisher alloc] initWithHostPeer:self.peer
                                                                       rolesSession:session
                                                                          transport:self.transport];
    NSMutableArray<id<ITPeer>> *discoveredPeers = [[NSMutableArray<id<ITPeer>> alloc] init];
    for (int i=0; i<10; i++) {
        id peer = OCMClassMock(ITBonjourPeer.class);
        NSString *identifier = [NSUUID UUID].UUIDString;
        OCMStub([peer peerID]).andReturn(identifier);
        NSLog(@"id: %@", identifier);
        [discoveredPeers addObject:peer];
    }
    OCMStub([self.transport sendTelemetryRequestToPeers]).andDo(^(NSInvocation *invocation) {
        for (id peer in discoveredPeers) {
            [role gotTelemetryResponse:[[NSData alloc] init] fromPeer:peer];
        }        
    });
    [role tryEstablishMasterAndSlavePeersInDiscoveredPeers:discoveredPeers];
    
    OCMVerifyAllWithDelay(self.transport, 10.0);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
