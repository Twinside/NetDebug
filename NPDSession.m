//
//  MyDocument.m
//  NetDebug
//
//  Created by Vincent Berthoux on 27/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NPDSession.h"
#import "NetworkSnippet.h"
#import "JSON.h"

typedef enum ColorIndice_t
{
    ErrorColor,
    SentColor,
    ReceivedColor,
    InfoColor,
    ClockColor,
    ProtocolBackgroundColor,

    LastColor
} ColorIndice;

NSColor* textColors[LastColor] = { 0 };

@interface NSMutableAttributedString (AppendString)
- (void)appendString:(NSString*)str;
- (void)appendString:(NSString*)str attributes:(NSDictionary*)dico;
@end

@implementation NSMutableAttributedString (AppendString)

- (void)appendString:(NSString*)str
{
    NSMutableAttributedString    *astr =
        [[NSMutableAttributedString alloc] initWithString:str];

    [self appendAttributedString:astr];
    [astr release];
}

- (void)appendString:(NSString*)str attributes:(NSDictionary*)dico
{
    NSMutableAttributedString    *astr =
        [[NSMutableAttributedString alloc] initWithString:str
                                               attributes:dico];

    [self appendAttributedString:astr];
    [astr release];
}
@end

static inline void setTextColor( ColorIndice idx, int r, int g, int b )
{
    textColors[ idx ] = [NSColor colorWithDeviceRed:r / 255.0f
                                              green:g / 255.0f
                                               blue:b / 255.0f
                                              alpha:1.0f];
    [textColors[ idx ] retain];
}

static void createColors()
{
    static Boolean initialized = NO;

    if (initialized) return;

    setTextColor( ErrorColor    , 0xBA , 0x72 , 0x22 );
    setTextColor( SentColor     , 0x7D , 0x95 , 0xAD );
    setTextColor( ReceivedColor , 0x60 , 0x60 , 0x60 );
    setTextColor( InfoColor     , 0x00 , 0x00 , 0x00 );
    setTextColor( ClockColor    , 0x7D , 0x64 , 0xAF );
    setTextColor( ProtocolBackgroundColor, 0xF3 , 0xF2 , 0xED );

    initialized = YES;
}

@interface NPDSession (Private)
- (void)appendUpdateLog:(NSString*)data
              withSense:(NSString*)way
               andColor:(NSColor*)color;
@end

@implementation NPDSession (Private)
- (void)appendUpdateLog:(NSString*)data
              withSense:(NSString*)way
               andColor:(NSColor*)color
{
    NSMutableAttributedString *acc =
        [[NSMutableAttributedString alloc] initWithString:@"["];

    /////////
    // clock
    /////////
    NSDictionary *clockAttributes =
        [NSDictionary
            dictionaryWithObjectsAndKeys: textColors[ClockColor]
                                , NSForegroundColorAttributeName
                                , nil];

    NSDate *currentDate = [NSDate date];
    NSString *clockString =
        [currentDate descriptionWithCalendarFormat:@"%H:%M:%S" 
                                        timeZone:nil
                                            locale:nil];

    [acc appendString:clockString attributes:clockAttributes];
    [acc appendString:@"] "];
    [acc appendString:way];

    ////////
    // message formatting
    ////////
    NSDictionary *attr =
        [NSDictionary
            dictionaryWithObjectsAndKeys: color
                                , NSForegroundColorAttributeName
                                , nil];

    if ( data == nil || [data length] < 2 )
        [acc appendString:@"\n" attributes:attr];
    else
        [acc appendString:data attributes:attr];

    [logString appendAttributedString:acc];
    [txtDialogView setAttributedStringValue:logString];
}
@end

@implementation NPDSession
@synthesize isConnected;
@synthesize connectionToggleString;

- (id)init
{
    self = [super init];
    if (self) {
        logString =
            [[NSMutableAttributedString alloc] initWithString:@""];
        isConnected = [[NSNumber alloc] initWithBool:NO];
        connectionToggleString =
            NSLocalizedStringFromTable(@"connect_toggle"
                                      ,@"messages"
                                      ,@"A comment");
        [connectionToggleString retain];
        createColors();
    }
    return self;
}

- (void)dealloc
{
    [connection release];
    [logString release];
    [super dealloc];
}

- (NSString *)windowNibName
{
    return @"MyDocument";
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [txtDialogView
        setBackgroundColor:textColors[ProtocolBackgroundColor]];
    [self loadSnippets:self];
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}

- (NSString*)snippetFileName
{
    NSString *home = NSHomeDirectory();
    return [home
        stringByAppendingPathComponent:
            @"Library/Application Support/NetDebug/snips.json"];
}

- (IBAction)openSnippetFile:(id)sender
{
    [[NSWorkspace sharedWorkspace]
        openFile:[self snippetFileName]];
}

- (IBAction)loadSnippets:(id)sender
{

    NSString *jsonFile = [self snippetFileName];
    NSString *fileString =
        [NSString stringWithContentsOfFile:jsonFile
                                  encoding:NSUTF8StringEncoding
                                     error:nil];
    
    SBJsonParser    *parser = [[SBJsonParser alloc] init];

    id  ret = [parser objectWithString:fileString];

    // we want a basic key/value association
    if (ret == nil || ![ret isKindOfClass:[NSDictionary class]])
    {
        [parser release];
        return;
    }

    // Remove all the elements in the array, not the cleanest
    // way possible, but hey, should work
    [snippetArray removeObjects:[snippetArray content]];

    NSDictionary *dic = ret;
    int snippetCount = 1;
    for (id key in dic)
    {
        if ( ![key isKindOfClass:[NSString class]] )
            continue;

        id obj = [dic objectForKey:key];
        if ( ![obj isKindOfClass:[NSString class]] )
            continue;

        [snippetArray addObject:
            [NPDNetworkSnippet snippetOfText:(NSString*)obj
                                     andName:(NSString*)key
                                   withIndex:snippetCount]];
        snippetCount++;
    }

    [parser release];
}

- (IBAction)sendSnippet:(id)sender
{
    NSInteger menuTag = [(NSMenuItem*)sender tag] - 1;
    
    NPDNetworkSnippet *snip =
        [(NSArray*)[snippetArray content] objectAtIndex:menuTag];

    if ( snip == nil)
        return;

    NSString *val = [snip snippetText];
    [connection sendData:val];
    [self appendUpdateLog:val
                withSense:@"> "
                 andColor:textColors[ SentColor ]];
}

- (IBAction)connectTo:(id)sender
{
    // if we start connection
    if ( ![isConnected boolValue] )
    {
        [connection release];
        connection =
            [[NetworkSender alloc]
                initWithURL:[txtAdress stringValue]
                    andPort:[txtPort stringValue]
                inBundle:[NSBundle bundleForClass:[self class]]];

        [connection setTextReceiver:self];
        [self setIsConnected:[NSNumber numberWithBool:YES]];
        [self setConnectionToggleString:
            NSLocalizedStringFromTable(@"disconnect_toggle"
                                      ,@"messages"
                                      ,@"A comment")];

        [documentWindow setTitle:[txtAdress stringValue]];
    }
    else
    {
        [self connectionInformation:
            NSLocalizedStringFromTable(@"MsgDisconnected"
                                      ,@"messages"
                                      ,@"A comment")];
        [connection release];
        connection = nil;
        [self setIsConnected:[NSNumber numberWithBool:NO]];
        [self setConnectionToggleString:
            NSLocalizedStringFromTable(@"connect_toggle"
                                      ,@"messages"
                                      ,@"A comment")];
    }
}

- (IBAction)sendCommand:(id)sender
{
    NSString *val = [NSString stringWithFormat:@"%@\n",
                                    [sender stringValue] ];
    [connection sendData:val];
    [self appendUpdateLog:val
                withSense:@"> "
                 andColor:textColors[ SentColor ]];
    [sender setStringValue:@""];
}

- (void)connectionInformation:(NSString*)info
{
    [self appendUpdateLog:info
                withSense:@"- "
                 andColor:textColors[ InfoColor ]];
}

- (void)receivedData:(NSString*)data
{
    [self appendUpdateLog:data 
                withSense:@"< "
                 andColor:textColors[ ReceivedColor ]];
}

- (void)disconnect
{
    [self setIsConnected:[NSNumber numberWithBool:NO]];
    [self setConnectionToggleString:
            NSLocalizedStringFromTable(@"connect_toggle"
                                      ,@"messages"
                                       ,@"A comment")];
}

- (void)endOfConnection:(NSString*)text
{
    [self appendUpdateLog:text
                withSense:@"- "
                 andColor:textColors[InfoColor]];

    [self disconnect];
    [connection release];
    connection = nil;
}

- (void)connectionError:(NSString*)errorText
{
    [self appendUpdateLog:errorText
                withSense:@"! "
                 andColor:textColors[ErrorColor]];

    [connection release];
    connection = nil;
}
@end

