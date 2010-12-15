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

@implementation NPDSession

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSString *)windowNibName
{
    return @"MyDocument";
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addSnippets];
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

- (void)addSnippets
{
    NSString *fileString =
        [NSString stringWithContentsOfFile:@"/Users/vince/Desktop/snips.json"
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

    NSDictionary *dic = ret;
    for (id key in dic)
    {
        if ( ![key isKindOfClass:[NSString class]] )
            continue;

        id obj = [dic objectForKey:key];
        if ( ![obj isKindOfClass:[NSString class]] )
            continue;

        [snippetArray addObject:
            [NPDNetworkSnippet snippetOfText:(NSString*)obj
                                     andName:(NSString*)key]];
    }

    [parser release];
}

- (IBAction)connectTo:(id)sender
{
    
}
@end
