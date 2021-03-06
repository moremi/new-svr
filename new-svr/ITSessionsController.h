//
//  ITSessionsController.h
//  new-svr
//
//  Created by Vlad on 06.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITMasterSessionManager.h"
#import "ITSlaveSessionManager.h"
#import "ITPeersDetector.h"
#import "ITPeerRolesEstablisher.h"

@class ITSessionsController;

@protocol ITSessionsControllerDelegate <NSObject>
- (void)sessionController:(ITSessionsController *)sessionController didEstablishMasterSession:(ITMasterSessionManager *)masterSessionManager;
- (void)sessionController:(ITSessionsController *)sessionController didEstablishSlaveSession:(ITSlaveSessionManager *)slaveSessionManager;
@end

@interface ITSessionsController : NSObject <ITPeersDetectorDelegate, ITPeerRolesEstablisherDelegate>
@property(nonatomic, weak) id <ITSessionsControllerDelegate> delegate;
- (instancetype)initWithPeersDetector:(id<ITPeersDetector>)peersDetector
                 peerRolesEstablisher:(ITPeerRolesEstablisher *)peerRolesEstablisher
                             hostPeer:(id<ITPeer>)hostPeer;

- (void)establishMasterSlaveSession;
- (void)stopMasterSlaveSession;

@end
