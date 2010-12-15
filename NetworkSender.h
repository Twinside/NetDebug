//
//  NetworkSender.h
//  NetDebug
//
//  Created by Vincent Berthoux on 27/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol TextReceiver<NSObject>
- (void)receivedData:(NSString*)data;
- (void)endOfConnection:(NSString*)text;
- (void)connectionError:(NSString*)errorText;
@end

@interface NetworkSender : NSObject <NSStreamDelegate> {
    int             port;

    NSInputStream   *input;
    NSOutputStream  *output;

    bool            inputReady, outputReady;
    NSMutableArray  *sendQueue;

    id<TextReceiver> textHandler;
}

- (id)initWithURL:(NSString*)url
          andPort:(NSString*)port;
- (void)dealloc;
- (void)setTextReceiver:(id<TextReceiver>)receiver;

- (void)sendData:(NSString*)str;
- (bool)valid;
@end
