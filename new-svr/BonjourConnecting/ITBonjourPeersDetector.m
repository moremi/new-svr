//
//  ITBonjourPeersDetector.m
//  new-svr
//
//  Created by Vlad on 12.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import "ITBonjourPeersDetector.h"

@interface ITBonjourPeersDetector () <NSNetServiceBrowserDelegate>

@property (nonatomic) NSNetServiceBrowser *browser;
@property (nonatomic) NSInputStream *input;
@property (nonatomic) NSOutputStream *output;
@end

@implementation ITBonjourPeersDetector
@synthesize delegate;

- (instancetype)initWithServiceType:(NSString *)serviceType
{
    self = [super init];
    if (self) {
        self.browser = [[NSNetServiceBrowser alloc] init];
        self.browser.delegate = self;
        [self.browser searchForServicesOfType:@"_myservice._tcp." inDomain:@""];
    }
    return self;
}

- (void)startDiscovering
{
    
}

- (void)stopDiscovering
{
    
}


- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
    
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *, NSNumber *> *)errorDict
{
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    NSString *str = [[NSString alloc] initWithData:[service TXTRecordData] encoding:NSUTF8StringEncoding];
    NSLog(@"find %@",[service name]);

    BOOL con = [service getInputStream:&_input outputStream:&_output];
    [_output open];
    [_output write:10 maxLength:20];
    [_input open];
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    
}

@end
