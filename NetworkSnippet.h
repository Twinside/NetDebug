//
//  NetworkSnippet.h
//  NetDebug
//
//  Created by Vincent Berthoux on 28/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NPDNetworkSnippet : NSObject {
    NSString    *snippetText;
    NSString    *snippetName;
}
+ (id)snippetOfText:(NSString*)txt
            andName:(NSString*)name;

- (id)initWithText:(NSString*)txt
           andName:(NSString*)name;

@property(copy)NSString* snippetName;
@property(copy)NSString* snippetText;
@end
