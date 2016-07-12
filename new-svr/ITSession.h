//
//  ITSession.h
//  new-svr
//
//  Created by Vlad on 06.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITPeer.h"

@protocol ITSessionDelegate
- (void)didReceiveInvitation:(void(^)(BOOL accept))invintationHandler fromPeer:(id<ITPeer>)peer;
- (void)didReceiveData:(NSData *)data fromPeer:(id<ITPeer>)peer;
@end


@protocol ITSession <NSObject>
@property (nonatomic, strong) NSMutableArray <id<ITPeer>> *peers;
@property (nonatomic, strong) id<ITPeer> hostPeer;
@property (nonatomic, weak) id<ITSessionDelegate> delegate;

- (instancetype)initWithHostPeer:(id<ITPeer>)peer;
- (void)sendData:(NSData *)data toPeers:(NSArray <id<ITPeer>> *)peers;
- (void)invitePeer:(id<ITPeer>)peer;
@end
