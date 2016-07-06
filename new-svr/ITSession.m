//
//  ITSession.m
//  new-svr
//
//  Created by Vlad on 06.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import "ITSession.h"

@implementation ITSession

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.peers = [[NSMutableArray <ITPeer *> alloc] init];
    }
    return self;
}

@end
