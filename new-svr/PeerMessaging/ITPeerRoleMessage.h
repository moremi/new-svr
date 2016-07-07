//
//  ITPeerRoleMessage.h
//  new-svr
//
//  Created by Vlad on 07.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(UInt8, ITPeerRoleMessageType){
    ITPeerRoleMessageTypeInvalidMessage = 0,
    ITPeerRoleMessageTypeTelemetryRequest,
    ITPeerRoleMessageTypeTelemetryResponse,
    ITPeerRoleMessageTypeBeMaster,
    ITPeerRoleMessageTypeMasterApproved,
    ITPeerRoleMessageTypeBeSlave,
    ITPeerRoleMessageTypeSlaveApproved,
    ITPeerRoleMessageTypeStopShaking
};

@interface ITPeerRoleMessage : NSObject

@property (nonatomic, readonly) ITPeerRoleMessageType type;
@property (nonatomic, readonly) NSData *content;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithType: (ITPeerRoleMessageType) type NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithType: (ITPeerRoleMessageType) type andContentData: (NSData *)data NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithMessageData: (NSData *)messageData NS_DESIGNATED_INITIALIZER;
- (NSData *) messageData;

@end
