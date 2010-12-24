//
//  SnippetView.m
//  NetDebug
//
//  Created by Vincent Berthoux on 28/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SnippetView.h"
#import "NetworkSnippet.h"


@implementation SnippetView
- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
    return NSDragOperationCopy;
}

- (void)awakeFromNib
{
    [self setDrawsBackground:YES];
    [self setBackgroundColor:[NSColor yellowColor]];
}

- (NSImage*)renderInImage
{
    NSRect size = [self frame];
    NSImage *drawingImage =
        [[NSImage alloc] initWithSize:size.size];
    
    [drawingImage lockFocus];
    [self drawRect:size];
    [drawingImage unlockFocus];
    return [drawingImage autorelease];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSSize       nullSize = { 0, 0 };
    NSRect       ourSize = [self frame];
    NSPoint      where = [theEvent locationInWindow];
    
    where.x -= ourSize.size.width / 2.0f;
    where.y -= ourSize.size.height / 2.0f;
    NSPasteboard *board =
        [NSPasteboard pasteboardWithName:NSDragPboard];

    [board declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString]
                  owner:self];
    [board setString:[self toolTip]
             forType:NSPasteboardTypeString];
    

    [[self window]
        dragImage:[self renderInImage]
               at:where
           offset:nullSize
            event:theEvent
       pasteboard:board
           source:self
        slideBack:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect frame = [self bounds];
    
    NSBezierPath *back = 
        [NSBezierPath
            bezierPathWithRoundedRect:frame
                              xRadius:frame.size.height / 2.0f
                              yRadius:frame.size.height / 2.0f];


	[[NSColor colorWithDeviceRed: 75.0f / 255.0f
						   green:137.0f / 255.0f
						   	blue:208.0f / 255.0f
						   alpha:1.0f] setFill];
	[back fill];
    //[[NSColor whiteColor] setStroke];
    //[NSBezierPath setDefaultLineWidth:4.0f];

    //[back stroke];
    
	[[NSColor blackColor] setFill];

    [super drawRect:dirtyRect];
}
@end

