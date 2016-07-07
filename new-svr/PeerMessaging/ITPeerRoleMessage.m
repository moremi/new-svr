//
//  ITPeerRoleMessage.m
//  new-svr
//
//  Created by Vlad on 07.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import "ITPeerRoleMessage.h"

@implementation ITPeerRoleMessage

- (instancetype)initWithType: (ITPeerRoleMessageType) type andContentData: (NSData *)data
{
    self = [super init];
    if (self) {
        _type = type;
        _content = data;
    }
    return self;
}

- (instancetype)initWithType: (ITPeerRoleMessageType) type
{
    self = [super init];
    if (self) {
        _type = type;
        _content = [NSData new];
    }
    return self;
}

- (instancetype)initWithMessageData: (NSData *)messageData
{
    self = [super init];
    if (self) {
        _type = [self typeFromMessageData:messageData];
        _content = [self contentFromMessageData:messageData];
    }
    return self;
}

- (ITPeerRoleMessageType) typeFromMessageData: (NSData *) messageData{
    UInt8 value;
    [messageData getBytes:&value length:1];
    
    switch (value) {
        case ITPeerRoleMessageTypeTelemetryRequest:
            return ITPeerRoleMessageTypeTelemetryRequest;
        case ITPeerRoleMessageTypeTelemetryResponse:
            return ITPeerRoleMessageTypeTelemetryResponse;
        case ITPeerRoleMessageTypeBeMaster:
            return ITPeerRoleMessageTypeBeMaster;
        case ITPeerRoleMessageTypeBeSlave:
            return ITPeerRoleMessageTypeBeSlave;
        case ITPeerRoleMessageTypeSlaveApproved:
            return ITPeerRoleMessageTypeSlaveApproved;
        case ITPeerRoleMessageTypeMasterApproved:
            return ITPeerRoleMessageTypeMasterApproved;
        case ITPeerRoleMessageTypeStopShaking:
            return ITPeerRoleMessageTypeStopShaking;
        default:
            return ITPeerRoleMessageTypeInvalidMessage;
    }
}

- (NSData *) contentFromMessageData: (NSData *) messageData{
    NSUInteger offset = 1;  //type offset
    NSRange range = {.location = 1, .length = messageData.length - offset};
    NSData *content = [messageData subdataWithRange:range];
    return content;
}

- (NSData *) messageData{
    NSMutableData *data = [NSMutableData new];
    [data appendBytes:&_type length:sizeof(_type)];
    [data appendData:self.content];
    return data;
}

@end
