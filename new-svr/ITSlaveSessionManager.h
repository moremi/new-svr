//
//  ITSlaveSessionManager.h
//  new-svr
//
//  Created by Vlad on 06.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITSession.h"

@interface ITSlaveSessionManager : NSObject

- (instancetype)initWithSession:(id<ITSession>)session andMasterPeer:(id<ITPeer>)slavePeer;

@end
