//
//  WWLevelIndicator.m
//  KleinView
//
//  Created by Ward Witt on 11/25/09.
//  Copyright (c) 2012 Filmworkers Club, Ward Witt
//  All rights reserved.
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



#import "WWLevelIndicator.h"

NSImage *baseImage;
NSImage *levelImage;


@implementation WWLevelIndicator

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		imageFile = @"Green.png";
		baseImage = [[NSImage imageNamed:@"base.png"]retain];
		maxValue = 10.0;
		minValue = 0.0;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	levelImage = [NSImage imageNamed:imageFile];

	NSRect bds = [self bounds];
	float gain, offset, level;
	gain = maxValue - minValue;
	offset = (gain - maxValue) / gain;
	level = (fLevel * (NSMaxX(bds) / gain)+(NSMaxX(bds) * offset));
	NSRect levelRect = NSMakeRect(0.0, 0.0, level, 12.0);
	[baseImage drawInRect:bds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];	
	[levelImage drawInRect:levelRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

- (void)setFloatValue:(float)f {
	fLevel = f;
	[self setNeedsDisplay:TRUE];
}

- (void)setImageFile:(NSString *)image {
	imageFile = image;
}

@synthesize maxValue;
@synthesize minValue;

@end
