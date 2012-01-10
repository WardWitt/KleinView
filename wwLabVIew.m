//
//  wwLabView.m
//  KleinView
//
//  Created by Ward Witt on 6/20/11.
//  Copyright 2012 Filmworkers Club. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following
//  conditions are met:
//  •	Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  •	Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
//      disclaimer in the documentation and/or other materials provided with the distribution.
//  •	Neither the name of the Filmworkers Club nor the names of its contributors may be used to endorse or promote products derived
//      from this software without specific prior written permission.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT
//  NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
//  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
//  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "wwLabView.h"


@implementation wwLabView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

-(void)setA:(float)Lab_a B:(float)Lab_b
{
    a = Lab_a;
    b = Lab_b;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    NSRect        bounds = [self bounds];

    NSBezierPath*    clipShape = [NSBezierPath bezierPath];
    //[clipShape appendBezierPathWithRoundedRect:NSMakeRect(3.0, 3.0, 194.0, 194.0) xRadius:8 yRadius:8];
    [clipShape appendBezierPathWithRoundedRect:bounds xRadius:8 yRadius:8];
    
    NSRect  target = NSMakeRect(NSMidX(bounds)-25,NSMidY(bounds)-25,50.0,50.0);
    NSBezierPath*   targetShape = [NSBezierPath bezierPathWithOvalInRect:target];
    [targetShape moveToPoint:NSMakePoint(96.0, 100.0)];
    [targetShape lineToPoint:NSMakePoint(104.0, 100.0)];
    [targetShape moveToPoint:NSMakePoint(100.0, 96.0)];
    [targetShape lineToPoint:NSMakePoint(100.0, 104.0)];
    
    NSGradient* aGradient = [[NSGradient alloc]initWithStartingColor:[NSColor whiteColor] endingColor:[NSColor blackColor]];
    [aGradient drawInBezierPath:clipShape relativeCenterPosition:NSMakePoint(a/4, b/4)];
    
    NSBezierPath* measuredLab = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(a*25+95, b*25+95, 10.0, 10.0)];
    [targetShape stroke];
    [measuredLab stroke];

    [aGradient release];
}

@end
