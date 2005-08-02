/*
  GormSliderAttributesInspector.m

   Copyright (C) 2001-2005 Free Software Foundation, Inc.

   Author:  Adam Fedor <fedor@gnu.org>
              Laurent Julliard <laurent@julliard-online.org>
   Date: Aug 2001
   
   This file is part of GNUstep.
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02111 USA.
*/

/*
  July 2005 : Spilt inspector in separate classes.
  Always use ok: revert: methods
  Clean up
  Author : Fabien Vallon <fabien@sonappart.net>
*/

#include "GormSliderAttributesInspector.h"

#include <Foundation/NSNotification.h>

#include <AppKit/NSButton.h>
#include <AppKit/NSForm.h>
#include <AppKit/NSNibLoading.h>
#include <AppKit/NSSlider.h>

/* 
   IBObjectAdditions category
*/
@implementation	NSSlider (IBObjectAdditions)
- (NSString*) inspectorClassName
{
  return @"GormSliderAttributesInspector";
}
@end


@implementation GormSliderAttributesInspector

- (id) init
{
  if ([super init] == nil)
    {
      return nil;
    }
  if ([NSBundle loadNibNamed: @"GormNSSliderInspector" owner: self] == NO)
    {
      NSLog(@"Could not gorm GormSliderInspector");
      return nil;
    }
  return self;
}

/* Commit changes that the user makes in the Attributes Inspector */
- (void) ok:(id) sender
{
  if (sender == valuesForm)
    {
      [object setMinValue: [[sender cellAtIndex: 0] doubleValue]];
      [object setDoubleValue: [[sender cellAtIndex: 1] doubleValue]];
      [object setMaxValue: [[sender cellAtIndex: 2] doubleValue]];
    }
  else if ( sender == continuousSwitch ) 
    {
      [object setContinuous: [continuousSwitch state]];
    }
  else if ( sender == enabledSwitch ) 
    {
      [object setEnabled: [enabledSwitch state]];
    }
  else if (sender == altIncrementForm)
    {
      [[object cell] setAltIncrementValue: 
		       [[sender cellAtIndex: 0] doubleValue]];
    }
  else if (sender == knobThicknessForm)
    {
      [[object cell] setKnobThickness: 
		       [[sender cellAtIndex: 0] floatValue]];
    }
  else if (sender == tagForm)
    {
      [[object cell] setTag: [[sender cellAtIndex: 0] intValue]];
    }
}

/* Sync from object ( NSSlider ) changes to the inspector   */
- (void) revert:(id) sender
{
  if ( object == nil)
      return;
  
  [[valuesForm cellAtIndex: 0] setDoubleValue: [object minValue]];
  [[valuesForm cellAtIndex: 1] setDoubleValue: [object doubleValue]];
  [[valuesForm cellAtIndex: 2] setDoubleValue: [object maxValue]];

  [continuousSwitch setState:[object isContinuous]];
  [enabledSwitch setState:[object isEnabled]];

  [[altIncrementForm cellAtIndex: 0] setDoubleValue:
				       [[object cell] altIncrementValue]];

  [[knobThicknessForm cellAtIndex: 0] setFloatValue: 
			       [[object cell] knobThickness]];

  [[tagForm cellAtIndex: 0] setIntValue: [[object cell] tag]];

  [super revert:sender];
}


/* delegate methods for all Forms */
-(void) controlTextDidChange:(NSNotification *)aNotification
{
  [self ok:[aNotification object]];
}

@end
