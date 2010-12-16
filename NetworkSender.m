//
//  NetworkSender.m
//  NetDebug
//
//  Created by Vincent Berthoux on 27/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NetworkSender.h"

static NSDictionary* portMapping()
{
    NSDictionary* mapping = nil;
    
    if (mapping == nil)
        mapping = 
            [[NSDictionary alloc]
                initWithObjectsAndKeys:
            [NSNumber numberWithInt:21 ],@"FTP",
            [NSNumber numberWithInt:143],@"IMAP",
            [NSNumber numberWithInt:80 ],@"HTTP", nil];
    return mapping;
}

@interface NetworkSender (Private)
- (void)sendString:(NSString*)str;
@end

@implementation NetworkSender

- (id)initWithURL:(NSString*)url
          andPort:(NSString*)portString
{
    self = [super init];
    NSNumber *num = [portMapping() objectForKey:portString];

    if (num == nil)
        port = [portString intValue];
    else
        port = [num intValue];

    NSHost *host =
        [NSHost hostWithAddress:url];

    [NSStream getStreamsToHost:host
                          port:port
                   inputStream:&input
                  outputStream:&output];

    textHandler = nil;
    [input retain];
    [output retain];

    inputReady = NO;
    outputReady = NO;

    [input setDelegate:self];
    [output setDelegate:self];

    sendQueue = [[NSMutableArray alloc] initWithCapacity:10];
    
    [input scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [output scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [input open];
    [output open];
    return self;
}

- (void)dealloc
{
    [input close];
    [output close];
    
    [input removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [output removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [input setDelegate:nil];
    [output setDelegate:nil];
    
    [input release];
    [output release];

    [sendQueue release];

    [super dealloc];
}

- (bool)valid
{
    return input != nil && output != nil;
}

- (void)setTextReceiver:(id<TextReceiver>)newReceiver
{
    [textHandler release];
    textHandler = newReceiver;
    [textHandler retain];
}

- (void)sendData:(NSString*)str
{
    if (outputReady)
    {   // send directly
        [self sendString:str];
        outputReady = NO;
    }
    else
    {   // enqueu the data.
        [sendQueue addObject:str];
    }
}

- (void)stream:(NSStream *)theStream
   handleEvent:(NSStreamEvent)streamEvent
{
    if (theStream == input)
    {
        NSUInteger readed;
        NSString *received;

        switch ( streamEvent )
        {
        case NSStreamEventHasBytesAvailable:
            inputReady = YES;

            readed = [input read:receiveBuffer
                       maxLength:sizeof(receiveBuffer)
                                  / sizeof(uint8_t) - 1];
            receiveBuffer[ readed ] = '\0';

            received =
                [[NSString alloc] initWithBytes:receiveBuffer
                                         length:readed
                                       encoding:NSUTF8StringEncoding];

            [textHandler receivedData:received];
            [received release];
            break;

        case NSStreamEventEndEncountered:
            [textHandler endOfConnection:@"Connection terminated"];
            NSLog(@"End of input stream");
            break;

        case NSStreamEventErrorOccurred:
            [textHandler connectionError:@"Error"];
            NSLog(@"Error on input stream");
            break;
        }
    }
    else // must be output
    {
        switch ( streamEvent )
        {
        case NSStreamEventOpenCompleted:
            [textHandler
                connectionInformation:@"Connection established\r\n"];
            /* NO BREAK (intentional) */
        case NSStreamEventHasSpaceAvailable:
            if ( [sendQueue count] > 0 )
            {
                [self sendString:
                    (NSString*)[sendQueue objectAtIndex:0]];
                [sendQueue removeObjectAtIndex:0];
            }
            else outputReady = YES;
            break;

        case NSStreamEventErrorOccurred:
            outputReady = YES;
            NSLog(@"Error on output stream");
            break;
        }
    }
}
@end

@implementation NetworkSender (Private)
- (void)sendString:(NSString*)str
{
    const char* data = [str UTF8String];
    size_t size = strlen( data );

    [output write:(uint8_t*)data maxLength:size];
}
@end

