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

+ (id)snippetOfText:(NSString*)txt
            andName:(NSString*)name
{
    NPDNetworkSnippet *s =
        [[NPDNetworkSnippet alloc]
                 initWithText:txt andName:name];
    
    return [s autorelease];
}

- (id)initWithText:(NSString *)txt andName:(NSString *)name
{
    self = [super init];
    
    snippetName = name;
    snippetText = txt;
    
    [snippetName retain];
    [snippetText retain];
    
    return self;
}
@end
