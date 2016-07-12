//
//  ITConnectingAssembly.m
//  new-svr
//
//  Created by Vlad on 06.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import "ITConnectingAssembly.h"
#import "ITBonjourSession.h"

@implementation ITConnectingAssembly

+ (id<ITSession>)initSessionWithHostPeer:(id<ITPeer>)hostPeer
{
    ITBonjourSession *session = [[ITBonjourSession alloc] init];
    return session;
}

@end
