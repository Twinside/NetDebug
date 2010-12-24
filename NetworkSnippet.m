//
//  NetworkSnippet.m
//  NetDebug
//
//  Created by Vincent Berthoux on 28/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NetworkSnippet.h"


@implementation NPDNetworkSnippet
@synthesize snippetName;
@synthesize snippetText;
@synthesize snippetId;
@synthesize snippetTextId;

+ (id)snippetOfText:(NSString*)txt
            andName:(NSString*)name
	  withIndex:(int)snipId
{
    NPDNetworkSnippet *s =
        [[NPDNetworkSnippet alloc]
                 initWithText:txt andName:name
		    withIndex:snipId];
    
    return [s autorelease];
}

- (id)initWithText:(NSString *)txt 
	   andName:(NSString *)name
	 withIndex:(int)snipId
{
    self = [super init];
    
    snippetName = name;
    snippetText = txt;
    snippetId = [[NSNumber alloc] initWithInt:snipId];
    snippetTextId =
        [[NSString stringWithFormat:@"⌘%@"
          ,[NSNumber numberWithInt:snipId]] retain];
    
    [snippetName retain];
    [snippetText retain];
    
    return self;
}
@end

