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

    IBOutlet NSTextField       *txtDialogView;
    IBOutlet NSTextField       *txtMessage;

    IBOutlet NSTextField       *txtAdress;
    IBOutlet NSComboBox        *txtPort;

    NetworkSender              *connection;

    NSMutableAttributedString  *logString;
}

- (void)addSnippets;

- (IBAction)connectTo:(id)sender;
- (IBAction)sendCommand:(id)sender;
@end
