//
//  ITPeersDetector.h
//  new-svr
//
//  Created by Vlad on 05.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITPeer.h"

@class ITPeersDetector;

@protocol ITPeersDetectorDelegate
- (void)peersDetector:(ITPeersDetector *)peersDetector foundPeer:(ITPeer *)peer;
- (void)peersDetector:(ITPeersDetector *)peersDetector lostPeer:(ITPeer *)peer;
@end


@interface ITPeersDetector : NSObject
@property (nonatomic, weak) id<ITPeersDetectorDelegate> delegate;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithServiceType:(NSString *)serviceType NS_DESIGNATED_INITIALIZER;

- (void)startDiscovering;
- (void)stopDiscovering;
@end
