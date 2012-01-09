//
//  KleinController.m
//  KleinView
//
//  Created by Ward Witt on 1/13/11.
//  Copyright 2011 Filmworkers Club. All rights reserved.
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

#import "KleinController.h"


@implementation KleinController

-(void)awakeFromNib
{
    [self getAvailablePorts];
	defaults = [NSUserDefaults standardUserDefaults];
	[scalePopup selectItemAtIndex:[defaults integerForKey:@"lastUsedScale"]];
	[scalePopup sendAction:@selector(setScale:) to:self];
    [luminanceUnitsPopup selectItemAtIndex:[defaults integerForKey:@"lastUsedLuminanceUnits"]];
    [luminanceUnitsPopup sendAction:@selector(setLuminanceUnits:) to:self];
    [serialPopUp selectItemWithTitle:[defaults stringForKey:@"lastUsedSerialPort"]];
    [serialPopUp sendAction:@selector(selectSerialPort:) to:self];
	[rLevelIndicator setImageFile:@"Red.png"];
	[gLevelIndicator setImageFile:@"Green.png"];
	[bLevelIndicator setImageFile:@"Blue.png"];
    
    NSTimer *takeSample = [NSTimer scheduledTimerWithTimeInterval:0.125
														   target:self 
														 selector:@selector(getXYZ) 
                                                        userInfo:nil repeats:YES];
    NSLog(@"%@",takeSample);
}

- (void)getAvailablePorts
{
    NSMutableArray *availPorts = [NSMutableArray array];
	NSEnumerator *enumerator = [AMSerialPortList portEnumerator];
	AMSerialPort *aPort;
	while ((aPort = [enumerator nextObject])) {
		[availPorts addObject:[aPort bsdPath]];
	}
	[serialPopUp removeAllItems];
	[serialPopUp addItemsWithTitles:availPorts];
}

- (void)initPort
{
    [self setPort:[[[AMSerialPort alloc] init:deviceName withName:deviceName type:(NSString*)CFSTR(kIOSerialBSDModemType)] autorelease]];
	
	// register self as delegate for port
	[port setDelegate:self];
	
	
	// open port - may take a few seconds ...
	if ([port openExclusively]) {
		
	} else { // an error occured while creating port
		[self setPort:nil];
	}

}

- (AMSerialPort *)port
{
	//NSLog(@"Port called");
    return port;
}

- (void)setPort:(AMSerialPort *)newPort
{
    id old = nil;
	
    if (newPort != port) {
        old = port;
        port = [newPort retain];
        [old release];
		//NSLog(@"New Port called");
    }
}

- (void)getProbeModelSN {
	if (!port) {
		// open a new port if we don't already have one
		[self initPort];
	}
	if([port isOpen]) { // in case an error occured while opening the port
		[port writeString:@"P0\r" usingEncoding:NSUTF8StringEncoding error:NULL];
		
	}
	NSError *theError;
	NSString *reply = [port readStringUsingEncoding:NSUTF8StringEncoding error:&theError];
	NSLog(@"%@",reply);
}

- (void)getXYZ {
	static unsigned char buffer[15];
	float Xraw,Yraw,Zraw,x,y;
	
	if (!port) {
		// open a new port if we don't already have one
		[self initPort];
	}
	if([port isOpen]) { // in case an error occured while opening the port
		[port writeString:@"N5\r" usingEncoding:NSUTF8StringEncoding error:NULL];
    }
	NSError *theError;
	NSData *reply = [port readBytes:15 error:&theError];
	[reply getBytes:&buffer length:15];
	//test for valad data
	if (buffer[0] == 'N' && buffer[13] == '0') {
        // Found that you must divide raw samples by two to get correct value
        Xraw = [self kleinFloatMagMSB:buffer[2] magLSB:buffer[3] exponent:buffer[4]]/2;
		Yraw = [self kleinFloatMagMSB:buffer[5] magLSB:buffer[6] exponent:buffer[7]]/2;
        Zraw = [self kleinFloatMagMSB:buffer[8] magLSB:buffer[9] exponent:buffer[10]]/2;
        
        SampleXYZ.X = Xraw * XYZCalibrationMatrix[0] + Yraw * XYZCalibrationMatrix[1] + Zraw * XYZCalibrationMatrix[2];
        SampleXYZ.Y = Xraw * XYZCalibrationMatrix[3] + Yraw * XYZCalibrationMatrix[4] + Zraw * XYZCalibrationMatrix[5];
        SampleXYZ.Z = Xraw * XYZCalibrationMatrix[6] + Yraw * XYZCalibrationMatrix[7] + Zraw * XYZCalibrationMatrix[8];
        
        [XTextField setFloatValue:SampleXYZ.X];
		[YTextField setFloatValue:SampleXYZ.Y];
		[ZTextField setFloatValue:SampleXYZ.Z];
        
        if ([[luminanceUnitsPopup titleOfSelectedItem]isEqualToString:@"ftL"]) {
            [LuminanceTextField setFloatValue:SampleXYZ.Y*0.29188558];
        }else{
            [LuminanceTextField setFloatValue:SampleXYZ.Y];
        }
        x = SampleXYZ.X/(SampleXYZ.X+SampleXYZ.Y+SampleXYZ.Z);
        y = SampleXYZ.Y/(SampleXYZ.X+SampleXYZ.Y+SampleXYZ.Z);
        
        [x_TextField setFloatValue:x];
        [y_TextField setFloatValue:y];
        [Y_TextField setFloatValue:SampleXYZ.Y];
        
        // CIE LAB
        float ref_X = 95.047; //Observer= 2°, Illuminant= D65
        float ref_Y = 100.000;
        float ref_Z = 108.883;
        float var_X, var_Y, var_Z, CIE_L, CIE_a, CIE_b;
        
        var_X = SampleXYZ.X / ref_X;
        var_Y = SampleXYZ.Y / ref_Y;
        var_Z = SampleXYZ.Z / ref_Z;
        
        if ( var_X > 0.008856 ){
            var_X = pow(var_X, 0.33333333);
        }else {
            var_X = (7.787 * var_X) + (16/116);
        }
        if ( var_Y > 0.008856 ){
            var_Y = pow(var_Y, 0.33333333);
        }else {
            var_Y = (7.787 * var_Y) + (16 / 116);
        }
        if ( var_Z > 0.008856 ){
            var_Z = pow(var_Z, 0.33333333);
        }else{
            var_Z = (7.787 * var_Z) + (16 / 116);
        }
        
        CIE_L = (116 * var_Y) - 16;
        CIE_a = 500 * (var_X - var_Y);
        CIE_b = 200 * (var_Y - var_Z);
        
        [L_TextField setFloatValue:CIE_L];
        [a_TextField setFloatValue:CIE_a];
        [b_TextField setFloatValue:CIE_b];
        [labView setA:CIE_a B:CIE_b];
        
        KVRGBColor temp = [self RGBfromXYZ:SampleXYZ];
        float Gain = 5 / temp.G;

        [rLevelIndicator setFloatValue:temp.R*Gain];
		[gLevelIndicator setFloatValue:temp.G*Gain];
		[bLevelIndicator setFloatValue:temp.B*Gain];

		//NSLog(@"XYZ = %f,%f,%f - Yxy = %f,%f,%f",X,Y,Z,Y,x,y);
        //NSLog(@"Device in use %@ %lu",deviceName,[deviceName retainCount]);
	}	
}

- (void)getCalibrationList{
	if (!port) {
		// open a new port if we don't already have one
		[self initPort];
	}
	if([port isOpen]) { // in case an error occured while opening the port
		[port writeString:@"D7\r" usingEncoding:NSUTF8StringEncoding error:NULL];
	}
	calibrations = [NSMutableArray arrayWithCapacity:96];
	[port setReadTimeout:6];
	NSData *reply = [port readBytes:1925 error:NULL];
	int loc;
	for(loc = 2; loc < 1922; loc +=20)
	{
		NSString *temp = [[NSString alloc]initWithData:[reply subdataWithRange:NSMakeRange(loc,20)] encoding:NSUTF8StringEncoding];
		if (temp != nil) {
			[calibrations addObject:temp];
		}
		else
			[calibrations addObject:[NSString stringWithFormat:@"Empty %i",loc/20]];
		[temp release];
	}
	[calibrationPopUp removeAllItems];
	[calibrationPopUp addItemsWithTitles:calibrations];
}

-(IBAction)chooseCalibration:(id)sender
{
    int selection = [sender indexOfSelectedItem];
	[defaults setInteger:selection forKey:@"lastUsedCalibration"];

    if ([[sender titleOfSelectedItem]hasPrefix:@"Empty"]) {
        [self clearCalibrationMatrix];
        NSLog(@"Unity Calibration Matrix selected");
    }
    else{
    [self loadCalibrationMatrix:selection+1];
    }
}

-(IBAction)selectSerialPort:(id)sender
{   
    NSString *portName = [sender titleOfSelectedItem];
	[defaults setObject:portName forKey:@"lastUsedSerialPort"];
    deviceName = portName;
    [self initPort];
	[self getProbeModelSN];
	[self getCalibrationList];
    [calibrationPopUp selectItemAtIndex:[defaults integerForKey:@"lastUsedCalibration"]];
    [calibrationPopUp sendAction:@selector(chooseCalibration:) to:self];

}


- (IBAction)setScale:(id)sender{
	int selection = [sender indexOfSelectedItem];
	[defaults setInteger:selection forKey:@"lastUsedScale"];
	
	if (selection == 0)
	{
		[rLevelIndicator setMaxValue:10.0];
		[rLevelIndicator setMinValue:0.0];
		[gLevelIndicator setMaxValue:10.0];
		[gLevelIndicator setMinValue:0.0];
		[bLevelIndicator setMaxValue:10.0];
		[bLevelIndicator setMinValue:0.0];
		[upperScaleTextField setStringValue:@"200%"];
		[lowerScaleTextField setStringValue:@"0%"];
	}
	if (selection == 1)
	{
		[rLevelIndicator setMaxValue:6.25];
		[rLevelIndicator setMinValue:3.75];
		[gLevelIndicator setMaxValue:6.25];
		[gLevelIndicator setMinValue:3.75];
		[bLevelIndicator setMaxValue:6.25];
		[bLevelIndicator setMinValue:3.75];
		[upperScaleTextField setStringValue:@"125%"];
		[lowerScaleTextField setStringValue:@"75%"];
	}
	if (selection == 2)
	{
		[rLevelIndicator setMaxValue:5.5];
		[rLevelIndicator setMinValue:4.5];
		[gLevelIndicator setMaxValue:5.5];
		[gLevelIndicator setMinValue:4.5];
		[bLevelIndicator setMaxValue:5.5];
		[bLevelIndicator setMinValue:4.5];
		[upperScaleTextField setStringValue:@"110%"];
		[lowerScaleTextField setStringValue:@"90%"];
	}
}

- (IBAction)setLuminanceUnits:(id)sender{
    int selection = [sender indexOfSelectedItem];
	[defaults setInteger:selection forKey:@"lastUsedLuminanceUnits"];

}

- (void)loadCalibrationMatrix:(int)matrixNumber{
	unsigned char n[2];
    static unsigned char buffer[131];
    
	if (!port) {
		// open a new port if we don't already have one
		[self initPort];
	}
	if([port isOpen]) { // in case an error occured while opening the port
		[port writeString:@"D1\r" usingEncoding:NSUTF8StringEncoding error:NULL];
	}
	[port readBytes:2 error:NULL];
    // dont use this just "D1" reflected back letting us know it's OK to ask for the cal data
	n[0] = (unsigned char)matrixNumber;
	n[1] = '\r';
	[port writeBytes:&n length:2 error:NULL];
	NSData *reply = [port readBytes:131 error:NULL];
	[reply getBytes:&buffer length:131];
	NSString *matrixName = [[NSString alloc]initWithData:[reply subdataWithRange:NSMakeRange(0, 20)] encoding:NSUTF8StringEncoding];
    // White Spec XYZ + Tolerance
    WhiteSpac[0] = [self kleinFloatMagMSB:buffer[59] magLSB:buffer[60] exponent:buffer[61]];
    WhiteSpac[1] = [self kleinFloatMagMSB:buffer[62] magLSB:buffer[63] exponent:buffer[64]];
    WhiteSpac[2] = [self kleinFloatMagMSB:buffer[65] magLSB:buffer[66] exponent:buffer[67]];
    WhiteSpac[3] = [self kleinFloatMagMSB:buffer[68] magLSB:buffer[69] exponent:buffer[70]];
    WhiteSpac[4] = [self kleinFloatMagMSB:buffer[71] magLSB:buffer[72] exponent:buffer[73]];
    // RGB% Matrix
    RGBPercentMatrix[0] = [self kleinFloatMagMSB:buffer[74] magLSB:buffer[75] exponent:buffer[76]];
    RGBPercentMatrix[1] = [self kleinFloatMagMSB:buffer[77] magLSB:buffer[78] exponent:buffer[79]];
    RGBPercentMatrix[2] = [self kleinFloatMagMSB:buffer[80] magLSB:buffer[81] exponent:buffer[82]];
    RGBPercentMatrix[3] = [self kleinFloatMagMSB:buffer[83] magLSB:buffer[84] exponent:buffer[85]];
    RGBPercentMatrix[4] = [self kleinFloatMagMSB:buffer[86] magLSB:buffer[87] exponent:buffer[88]];
    RGBPercentMatrix[5] = [self kleinFloatMagMSB:buffer[89] magLSB:buffer[90] exponent:buffer[91]];
    RGBPercentMatrix[6] = [self kleinFloatMagMSB:buffer[92] magLSB:buffer[93] exponent:buffer[94]];
    RGBPercentMatrix[7] = [self kleinFloatMagMSB:buffer[95] magLSB:buffer[96] exponent:buffer[97]];
    RGBPercentMatrix[8] = [self kleinFloatMagMSB:buffer[98] magLSB:buffer[99] exponent:buffer[100]];
    // XYZ Matrix
    XYZCalibrationMatrix[0] = [self kleinFloatMagMSB:buffer[101] magLSB:buffer[102] exponent:buffer[103]];
    XYZCalibrationMatrix[1] = [self kleinFloatMagMSB:buffer[104] magLSB:buffer[105] exponent:buffer[106]];
    XYZCalibrationMatrix[2] = [self kleinFloatMagMSB:buffer[107] magLSB:buffer[108] exponent:buffer[109]];
    XYZCalibrationMatrix[3] = [self kleinFloatMagMSB:buffer[110] magLSB:buffer[111] exponent:buffer[112]];
    XYZCalibrationMatrix[4] = [self kleinFloatMagMSB:buffer[113] magLSB:buffer[114] exponent:buffer[115]];
    XYZCalibrationMatrix[5] = [self kleinFloatMagMSB:buffer[116] magLSB:buffer[117] exponent:buffer[118]];
    XYZCalibrationMatrix[6] = [self kleinFloatMagMSB:buffer[119] magLSB:buffer[120] exponent:buffer[121]];
    XYZCalibrationMatrix[7] = [self kleinFloatMagMSB:buffer[122] magLSB:buffer[123] exponent:buffer[124]];
    XYZCalibrationMatrix[8] = [self kleinFloatMagMSB:buffer[125] magLSB:buffer[126] exponent:buffer[127]];

	NSLog(@"Matrix Name = %@", matrixName);
    NSLog(@"%f  %f  %f",XYZCalibrationMatrix[0],XYZCalibrationMatrix[1],XYZCalibrationMatrix[2]);
    NSLog(@"%f  %f  %f",XYZCalibrationMatrix[3],XYZCalibrationMatrix[4],XYZCalibrationMatrix[5]);
    NSLog(@"%f  %f  %f",XYZCalibrationMatrix[6],XYZCalibrationMatrix[7],XYZCalibrationMatrix[8]);
    
    //NSLog(@"White Spec X %f Y %f Z %f tol %f %f",WhiteSpac[0],WhiteSpac[1],WhiteSpac[2],WhiteSpac[3],WhiteSpac[4]);
    [matrixName release];
}

- (double)kleinFloatMagMSB:(unsigned char)magMSB magLSB:(unsigned char)magLSB exponent:(int)exponent{
    int sign;
    float fraction;
    
    if (magMSB >= 128) {
        magMSB = magMSB - 128;
        sign = -1;
    }
    else {
        sign = 1;
    }
    fraction = (magMSB + magLSB /256.0)/128.0;
    
    if (exponent > 128) {
        exponent = exponent - 256;
    }
    return (sign * fraction * pow(2.0, exponent));
}

- (KVRGBColor)RGBfromXYZ:(KVXYZColor)XYZSample
{
	double var_X, var_Y, var_Z, var_R, var_G, var_B;
    KVRGBColor SampleRGB;

	
	var_X = SampleXYZ.X / 100.0;
	var_Y = SampleXYZ.Y / 100.0;
	var_Z = SampleXYZ.Z / 100.0;
	
	var_R = var_X * 3.2406 + var_Y * -1.5372 + var_Z * -0.4986;
	var_G = var_X * -0.9689 + var_Y * 1.8758 + var_Z * 0.0415;
	var_B = var_X * 0.0557 + var_Y * -0.2040 + var_Z * 1.0570;
	
	SampleRGB.R = var_R;
	SampleRGB.G = var_G;
	SampleRGB.B = var_B;
    return SampleRGB;
}

- (void)clearCalibrationMatrix
{
    XYZCalibrationMatrix[0] = 1.0;
    XYZCalibrationMatrix[1] = 0.0;
    XYZCalibrationMatrix[2] = 0.0;
    XYZCalibrationMatrix[3] = 0.0;
    XYZCalibrationMatrix[4] = 1.0;
    XYZCalibrationMatrix[5] = 0.0;
    XYZCalibrationMatrix[6] = 0.0;
    XYZCalibrationMatrix[7] = 0.0;
    XYZCalibrationMatrix[8] = 1.0;
}

@end
