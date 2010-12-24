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

typedef enum ImageIndice_t
{
    ImageTo,
    ImageFrom,
    ImageInfo,
    ImageError,

    LastImage
} ImageIndice;

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

static inline NSColor* colorOfRgb( int r, int g, int b )
{
    return [[NSColor colorWithDeviceRed:r / 255.0f
                                  green:g / 255.0f
                                   blue:b / 255.0f
                                  alpha:1.0f] retain];
}

@interface NPDSession (Private)
+ (NSTextAttachment*)imageForIndex:(ImageIndice)idx;
+ (NSColor*)colorForIndex:(ColorIndice)idx;
- (void)scrollToBottom:(NSView*)sender;
- (void)appendUpdateLog:(NSString*)data
              withSense:(NSTextAttachment*)way
              isMessage:(BOOL)isMessageString
               andColor:(NSColor*)color;
- (void)disconnect;
@end

@implementation NPDSession (Private)
+ (NSTextAttachment*)loadImageFromBundle:(NSString*)img
{
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* imgPath =
        [bundle pathForResource:img ofType:@"png"];

    NSFileWrapper *wrapper =
        [[NSFileWrapper alloc]
            initWithURL:[NSURL fileURLWithPath:imgPath]
                options:0
                  error:nil];

    return [[NSTextAttachment alloc]
                    initWithFileWrapper:wrapper];
}

+ (NSTextAttachment*)imageForIndex:(ImageIndice)idx
{
    static NSTextAttachment* images[LastImage] = { 0 };
    static BOOL initialized = NO;

    if (!initialized)
    {
        images[ImageTo] =
            [NPDSession loadImageFromBundle:@"icon-To"];
        images[ImageFrom] =
            [NPDSession loadImageFromBundle:@"icon-From"];
        images[ImageInfo] =
            [NPDSession loadImageFromBundle:@"icon-info"];
        images[ImageError] =
            [NPDSession loadImageFromBundle:@"icon-error"];
        initialized = YES;
    }

    assert( idx < LastImage );
    return images[ idx ];
}

+ (NSColor*)colorForIndex:(ColorIndice)idx
{
    static NSColor* textColors[LastColor] = { 0 };
    static Boolean initialized = NO;

    if (!initialized)
    {
        textColors[ErrorColor]    = colorOfRgb( 0xBA, 0x72, 0x22 );
        textColors[SentColor]     = colorOfRgb( 0x7D, 0x95, 0xAD );
        textColors[ReceivedColor] = colorOfRgb( 0x60, 0x60, 0x60 );
        textColors[InfoColor]     = colorOfRgb( 0x00, 0x00, 0x00 );
        textColors[ClockColor]    = colorOfRgb( 0x7D, 0x64, 0xAF );
        textColors[ProtocolBackgroundColor] =
            colorOfRgb( 0xF3 , 0xF2 , 0xED );

        initialized = YES;
    }
    return textColors[ idx ];
}

- (void)disconnect
{
    [self setIsConnected:[NSNumber numberWithBool:NO]];
    [self setConnectionToggleString:
            NSLocalizedStringFromTable(@"connect_toggle"
                                      ,@"messages"
                                      ,@"A comment")];
    [self setConnectionDescr:
            NSLocalizedStringFromTable(@"UnconnectedTitle"
                                      ,@"messages"
                                      ,@"A comment")];
}

- (void)scrollToBottom:(NSScrollView*)scroll
{
    NSPoint newScrollOrigin;
 
    // assume that the scrollview is an existing variable
    if ([[scroll documentView] isFlipped]) {
        newScrollOrigin=NSMakePoint(0.0,NSMaxY([[scroll documentView] frame])
                                       -NSHeight([[scroll contentView] bounds]));
    } else {
        newScrollOrigin=NSMakePoint(0.0,0.0);
    }
 
    [[scroll documentView] scrollPoint:newScrollOrigin];
 
}

- (void)appendUpdateLog:(NSString*)data
              withSense:(NSTextAttachment*)way
              isMessage:(BOOL)isMessageString
               andColor:(NSColor*)color
{
    NSFont *clockFont = [NSFont userFontOfSize:11.0f];
    NSDictionary *sizeAttrib =
        [NSDictionary dictionaryWithObject:clockFont
                                    forKey:NSFontAttributeName];
    NSMutableAttributedString *acc =
        [[NSMutableAttributedString alloc] initWithString:@"["
                                               attributes:sizeAttrib];

    /////////
    // clock
    /////////
    NSColor *clockColor =
        [NPDSession colorForIndex:ClockColor];

    NSDictionary *clockAttributes =
        [NSDictionary
            dictionaryWithObjectsAndKeys:
                  clockColor, NSForegroundColorAttributeName,
                   clockFont, NSFontAttributeName
                            , nil];

    NSDate *currentDate = [NSDate date];
    NSString *clockString =
        [currentDate descriptionWithCalendarFormat:@"%H:%M:%S" 
                                          timeZone:nil
                                            locale:nil];

    [acc appendString:clockString attributes:clockAttributes];
    [acc appendString:@"] " attributes:sizeAttrib];

    unichar attachement[] = { NSAttachmentCharacter, ' ' };

    [acc appendString:[NSString
                stringWithCharacters:attachement
                              length:sizeof(attachement)
                                    /sizeof(unichar)]
           attributes:[NSDictionary 
              dictionaryWithObject:way
                            forKey:NSAttachmentAttributeName]];
    ////////
    // message formatting
    ////////

    // paragraph style to indent multi line messages
    NSMutableParagraphStyle *pstyle =
        [[NSParagraphStyle  defaultParagraphStyle]
            mutableCopy];

    //[pstyle setHeadIndent:5.0f];
    [pstyle setFirstLineHeadIndent:66.5f];

    NSFont *pfont;

    if (isMessageString)
        pfont = 
            [NSFont userFontOfSize:13.0f];
    else
        pfont = 
            [NSFont fontWithName:@"Andale Mono"
                            size:13.0f];

    NSDictionary *attr =
        [NSDictionary
            dictionaryWithObjectsAndKeys:
                color, NSForegroundColorAttributeName,
               pstyle, NSParagraphStyleAttributeName,
                pfont, NSFontAttributeName
                     , nil];


    if ( data == nil || [data length] < 2 )
        [acc appendString:@"\n" attributes:attr];
    else
        [acc appendString:data attributes:attr];

    [logString appendAttributedString:acc];

    NSRect neoBounds = [txtDialogView bounds];
    neoBounds.origin.x = 0;
    neoBounds.origin.y = 0;

    [txtDialogView setBounds:neoBounds];
    [self scrollToBottom:txtDialogScroll];
}
@end

@implementation NPDSession
@synthesize isConnected;
@synthesize connectionToggleString;
@synthesize connectionDescr;

- (id)init
{
    self = [super init];
    if (self)
    {
        logString = nil;
        isConnected = nil;
        connectionToggleString = nil;
        connectionDescr = nil;
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
        setBackgroundColor:
            [NPDSession colorForIndex:ProtocolBackgroundColor]];

    logString = [[txtDialogView textStorage] retain];

    [self loadSnippets:self];
    [self disconnect];
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once
    // the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName
                 error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type.
    // If the given outError != NULL, ensure that you set *outError when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:,
    // or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    // For applications targeted for Panther or earlier systems, you should use
    // the deprecated API -dataRepresentationOfType:. In this case you can also
    // choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data
              ofType:(NSString *)typeName
               error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the
    // specified type.  If the given outError != NULL, ensure that you set
    // *outError when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error:
    // or -readFromURL:ofType:error: instead. 
    // For applications targeted for Panther or earlier systems, you should use
    // the deprecated API -loadDataRepresentation:ofType. In this case you can
    // also choose to override -readFromFile:ofType: or
    // -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}

- (NSString*)snippetFileName
{
    NSString *home = NSHomeDirectory();
    NSString *path = 
        [home stringByAppendingPathComponent:
            @"Library/Application Support/NetDebug"];
            //@"snips.json"

    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ( ![fileManager fileExistsAtPath:path] )
    {
        [fileManager createDirectoryAtPath:path
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }

    return [path stringByAppendingPathComponent:
                    @"snips.json"];
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
    
    if ( fileString == nil )
    {
        fileString =
            NSLocalizedStringFromTable(@"defaultSnippet"
                                      ,@"messages"
                                      ,@"A comment");

        // write the string to be able to edit it easily
        // without error.
        [fileString writeToFile:jsonFile
                     atomically:NO
                       encoding:NSUTF8StringEncoding
                          error:nil];
    }

    SBJsonParser    *parser = [[SBJsonParser alloc] init];

    id  ret = [parser objectWithString:fileString];

    if (ret == nil || ![ret isKindOfClass:[NSArray class]])
    {
        [parser release];
        return;
    }

    // Remove all the elements in the array, not the cleanest
    // way possible, but hey, should work
    [snippetArray removeObjects:[snippetArray content]];

    int snippetCount = 1;
    for (id obj in ret)
    {
        // we want a basic key/value association
        if (obj == nil || ![obj isKindOfClass:[NSDictionary class]])
        {
            [parser release];
            return;
        }

        NSDictionary *dic = obj;
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
                withSense:[NPDSession imageForIndex:ImageTo]
                isMessage:NO
                 andColor:
                    [NPDSession colorForIndex:SentColor]];
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

        NSString *title =
            NSLocalizedStringFromTable(@"connectedTitle"
                                      ,@"messages"
                                      ,@"A comment");
        [self setConnectionDescr:
            [NSString stringWithFormat:title
                                      ,[txtAdress stringValue]
                                      ,[txtPort stringValue]]];
    }
    else
    {
        [self connectionInformation:
            NSLocalizedStringFromTable(@"MsgDisconnected"
                                      ,@"messages"
                                      ,@"A comment")];
        [connection release];
        connection = nil;
        [self disconnect];
    }
}

- (IBAction)sendCommand:(id)sender
{
    NSString *val = [NSString stringWithFormat:@"%@\n",
                                    [sender stringValue] ];
    [connection sendData:val];
    [self appendUpdateLog:val
                withSense:[NPDSession imageForIndex:ImageTo]
                isMessage:NO
                 andColor:[NPDSession colorForIndex:SentColor]];
    [sender setStringValue:@""];
}

- (void)connectionInformation:(NSString*)info
{
    [self appendUpdateLog:info
                withSense:[NPDSession imageForIndex:ImageInfo]
                isMessage:YES
                 andColor:[NPDSession colorForIndex:InfoColor]];
}

- (IBAction)clearLogView:(id)sender
{
    [logString setAttributedString:
        [[NSMutableAttributedString alloc] initWithString:@""]];
}

- (void)receivedData:(NSString*)data
{
    [self appendUpdateLog:data 
                withSense:[NPDSession imageForIndex:ImageFrom]
                isMessage:NO
                 andColor:[NPDSession colorForIndex:ReceivedColor]];
}

- (void)endOfConnection:(NSString*)text
{
    [self appendUpdateLog:text
                withSense:[NPDSession imageForIndex:ImageInfo]
                isMessage:YES
                 andColor:[NPDSession colorForIndex:InfoColor]];

    [self disconnect];
    [connection release];
    connection = nil;
}

- (void)connectionError:(NSString*)errorText
{
    [self appendUpdateLog:errorText
                withSense:[NPDSession imageForIndex:ImageError]
                isMessage:YES
                 andColor:[NPDSession colorForIndex:ErrorColor]];

    [connection release];
    connection = nil;
    [self disconnect];
}
@end

