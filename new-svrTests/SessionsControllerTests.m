//
//  SessionsControllerTests.m
//  new-svr
//
//  Created by Vlad on 11.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ITPeerRolesEstablisher.h"
#import "ITBonjourPeer.h"
#import "ITBonjourSession.h"
#import "ITTransport.h"
#import "ITSessionsController.h"
#import "OCMock.h"

@interface SessionsControllerTests : XCTestCase
@property (nonatomic, strong) id<ITPeer> hostPeer;
@property (nonatomic, strong) id session;
@property (nonatomic, strong) id transport;
@property (nonatomic, strong) NSMutableArray *sessionPeers;
@end

@implementation SessionsControllerTests

- (void)setUp {
    [super setUp];
    self.sessionPeers = [[NSMutableArray alloc] init];
    self.hostPeer = OCMClassMock(ITBonjourPeer.class);
    OCMStub([self.hostPeer peerID]).andReturn(@"   !!");
    self.session = OCMClassMock(ITBonjourSession.class);
    void (^invitePeer)(NSInvocation *) = ^(NSInvocation *invocation) {
        id __unsafe_unretained pee = nil;
        //
        //        [invocation setTarget:self];
        //        [invocation invoke];
        [invocation getArgument:&pee atIndex:2];
        [self.sessionPeers addObject:pee];
        //NSLog(@"%@",pee);
        
    };
    
    OCMStub([self.session invitePeer:OCMOCK_ANY]).andDo(invitePeer);
    self.transport = OCMClassMock([ITTransport class]);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEstablishMasterSlaveSession {
    id peersDetector = OCMProtocolMock(@protocol(ITPeersDetector));
    ITBonjourSession *session = [[ITBonjourSession alloc] initWithHostPeer:self.hostPeer];
    
    ITPeerRolesEstablisher *rolesEstablisher = [[ITPeerRolesEstablisher alloc] initWithHostPeer:self.hostPeer
                                                                       rolesSession:session
                                                                          transport:self.transport];
    
    ITSessionsController *sessionsControler = [[ITSessionsController alloc] initWithPeersDetector:peersDetector
                                                                             peerRolesEstablisher:rolesEstablisher
                                                                                         hostPeer:self.hostPeer];
    id sessionsControlerDelegate = OCMProtocolMock(@protocol(ITSessionsControllerDelegate));
    sessionsControler.delegate = sessionsControlerDelegate;
    NSMutableArray<id<ITPeer>> *discoveredPeers = [[NSMutableArray<id<ITPeer>> alloc] init];
    for (int i=0; i<1; i++) {
        id peer = OCMClassMock(ITBonjourPeer.class);
        NSString *identifier = [NSUUID UUID].UUIDString;
        OCMStub([peer peerID]).andReturn(identifier);
        NSLog(@"id: %@", identifier);
        [sessionsControler peersDetector:peersDetector foundPeer:peer];
        [discoveredPeers addObject:peer];
    }
    [discoveredPeers addObject:self.hostPeer];
    [sessionsControler peersDetector:peersDetector foundPeer:self.hostPeer];
    OCMExpect([sessionsControlerDelegate sessionController:[OCMArg any] didEstablishMasterSession:[OCMArg any]]);
    OCMStub([self.transport sendTelemetryRequestToPeers]).andDo(^(NSInvocation *invocation) {
        for (id peer in discoveredPeers) {
            [rolesEstablisher gotTelemetryResponse:[[NSData alloc] init] fromPeer:peer];
        }
    });

    [sessionsControler establishMasterSlaveSession];
    OCMVerifyAllWithDelay(sessionsControlerDelegate, 10.0);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
