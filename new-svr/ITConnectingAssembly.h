//
//  ITConnectingAssembly.h
//  new-svr
//
//  Created by Vlad on 06.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITSession.h"
#import "ITTransport.h"

@interface ITConnectingAssembly : NSObject

+ (id<ITSession>)initSessionWithHostPeer:(id<ITPeer>)hostPeer;

@end
