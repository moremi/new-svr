//
//  ITPeersDetector.h
//  new-svr
//
//  Created by Vlad on 05.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITPeer.h"

@protocol ITPeersDetector;

@protocol ITPeersDetectorDelegate
- (void)peersDetector:(id<ITPeersDetector>)peersDetector foundPeer:(id<ITPeer>)peer;
- (void)peersDetector:(id<ITPeersDetector>)peersDetector lostPeer:(id<ITPeer>)peer;
@end

@protocol ITPeersDetector
@property (nonatomic, weak) id<ITPeersDetectorDelegate> delegate;
- (instancetype)initWithServiceType:(NSString *)serviceType;
- (void)startDiscovering;
- (void)stopDiscovering;
@end
