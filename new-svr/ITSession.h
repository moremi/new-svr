//
//  ITSession.h
//  new-svr
//
//  Created by Vlad on 06.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITPeer.h"

@interface ITSession : NSObject
@property (nonatomic, strong) NSMutableArray <ITPeer *> *peers;

- (void)invitePeer:(ITPeer *)peer;
@end
