//
//  ITBonjourPeer.m
//  new-svr
//
//  Created by Vlad on 08.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import "ITBonjourPeer.h"

@interface ITBonjourPeer ()
@property (nonatomic) NSNetService *netService;
@end

@implementation ITBonjourPeer
@synthesize peerID;

- (instancetype)initWithNetService:(NSNetService *)netService
{
    self = [super init];
    if (self) {
        self.netService = netService;
        self.peerID = [self.netService name];        
    }
    return self;
}

@end
