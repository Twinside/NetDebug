//
//  MyDocument.h
//  NetDebug
//
//  Created by Vincent Berthoux on 27/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "NetworkSender.h"

@interface NPDSession : NSDocument <TextReceiver>
{
    IBOutlet NSArrayController *snippetArray;

    IBOutlet NSScrollView      *txtDialogScroll;
    IBOutlet NSTextView        *txtDialogView;

    IBOutlet NSTextField       *txtMessage;

    IBOutlet NSTextField       *txtAdress;
    IBOutlet NSComboBox        *txtPort;

    IBOutlet NSWindow          *documentWindow;

    NetworkSender              *connection;
    NSTextStorage              *logString;

    @private NSNumber* isConnected;
    @private NSString* connectionDescr;
    @private NSString* connectionToggleString;
}

- (IBAction)loadSnippets:(id)sender;
- (IBAction)connectTo:(id)sender;
- (IBAction)sendCommand:(id)sender;
- (IBAction)sendSnippet:(id)sender;
- (IBAction)openSnippetFile:(id)sender;
- (IBAction)clearLogView:(id)sender;

@property(readwrite,assign) NSString* connectionDescr;
@property(readwrite,assign) NSNumber* isConnected;
@property(readwrite,assign) NSString* connectionToggleString;
@end

