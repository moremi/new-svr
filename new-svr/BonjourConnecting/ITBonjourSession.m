//
//  ITBonjourSession.m
//  new-svr
//
//  Created by Vlad on 08.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import "ITBonjourSession.h"

@interface ITBonjourSession () <NSNetServiceDelegate>
@property (nonatomic) NSNetService *netService;
@end

@implementation ITBonjourSession
@synthesize delegate;
@synthesize hostPeer;
@synthesize peers;

- (instancetype)initWithHostPeer:(id<ITPeer>)peer
{
    self = [super init];
    if (self) {
        self.hostPeer = peer;
        self.peers = [[NSMutableArray <id<ITPeer>> alloc] init];
        /*NSString *name = [[NSUUID UUID] UUIDString] ;
        self.netService = [[NSNetService alloc] initWithDomain:@"" type:@"_myservice._tcp." name:name port:0];

        self.netService.delegate = self;
        [self.netService publishWithOptions:NSNetServiceListenForConnections];
        [self.netService startMonitoring];*/
    }
    return self;
}

- (void)sendData:(NSData *)data toPeers:(NSArray<id<ITPeer>> *)peers
{
    
}

- (void)invitePeer:(id<ITPeer>)peer
{
    [self.peers addObject:peer];
}

- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(nonnull NSInputStream *)inputStream outputStream:(nonnull NSOutputStream *)outputStream
{
    [outputStream open];
}

 - (void)netServiceWillPublish:(NSNetService *)sender
{
    NSLog(@"WillPublish: %@.%@%@\n", [sender name], [sender type], [sender domain]);
}

- (void)netServiceDidPublish:(NSNetService *)sender
{
    NSLog(@"DidPublish: %@.%@%@\n", [sender name], [sender type], [sender domain]);
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary<NSString *,NSNumber *> *)errorDict
{
    NSLog(@"didNotPublish: %@.%@%@\n", [sender name], [sender type], [sender domain]);
}

@end
