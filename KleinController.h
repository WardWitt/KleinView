//
//  KleinController.h
//  KleinView
//
//  Created by Ward Witt on 1/13/11.
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

#import <Foundation/Foundation.h>
#import "AMSerialPort.h"
#import "AMSerialPortList.h"
#import "AMSerialPortAdditions.h"
#import "wwLabView.h"
#import "WWLevelIndicator.h"

typedef struct
{
    float X;
    float Y;
    float Z;
}
KVXYZColor;

typedef struct
{
    float R;
    float G;
    float B;
}
KVRGBColor;

typedef struct
{
    float Y;
    float x;
    float y;
}
KVYxyColor;

@interface KleinController : NSObject {
	NSUserDefaults *defaults;
	AMSerialPort *port;
    BOOL probeFound;
    NSString *deviceName;
	NSMutableArray *calibrations;
    IBOutlet NSTextField *statusTextField;
	IBOutlet NSPopUpButton *serialPopUp;
	IBOutlet NSPopUpButton *calibrationPopUp;
	IBOutlet NSTextField *XTextField;
	IBOutlet NSTextField *YTextField;
	IBOutlet NSTextField *ZTextField;
    IBOutlet NSTextField *x_TextField;
    IBOutlet NSTextField *y_TextField;
    IBOutlet NSTextField *Y_TextField;
    IBOutlet NSTextField *L_TextField;
    IBOutlet NSTextField *a_TextField;
    IBOutlet NSTextField *b_TextField;
    IBOutlet NSTextField *LuminanceTextField;
    IBOutlet wwLabView *labView;
    IBOutlet WWLevelIndicator *rLevelIndicator;
    IBOutlet WWLevelIndicator *gLevelIndicator;
    IBOutlet WWLevelIndicator *bLevelIndicator;
	IBOutlet NSTextField *upperScaleTextField;
	IBOutlet NSTextField *lowerScaleTextField;
	IBOutlet NSPopUpButton *scalePopup;
    IBOutlet NSPopUpButton *luminanceUnitsPopup;
    float RGBPercentMatrix[9];
    float WhiteSpac[5];
    float XYZCalibrationMatrix[9];
    KVXYZColor SampleXYZ;
}

- (IBAction)chooseCalibration:(id)sender;
- (IBAction)setScale:(id)sender;
- (IBAction)setLuminanceUnits:(id)sender;
- (IBAction)selectSerialPort:(id)sender;
- (void)getAvailablePorts;
- (void)setPort:(AMSerialPort *)newPort;
- (void)initPort;
- (void)getProbeModelSN;
- (void)getXYZ;
- (void)getCalibrationList;
- (void)clearCalibrationMatrix;
- (void)loadCalibrationMatrix:(int)matrixNumber;
- (double)kleinFloatMagMSB:(unsigned char)magMSB magLSB:(unsigned char)magLSB exponent:(int)exponent;
- (KVRGBColor)RGBfromXYZ:(KVXYZColor)XYZSample;
@end
