//
//  ITBonjourPeer.h
//  new-svr
//
//  Created by Vlad on 08.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITPeer.h"

@interface ITBonjourPeer : NSObject <ITPeer>

- (instancetype)initWithNetService:(NSNetService *)netService;

@end
