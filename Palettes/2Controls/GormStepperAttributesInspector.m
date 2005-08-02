/*
  GormStepperAttributesInspector.m

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

#include "GormStepperAttributesInspector.h"

#include <Foundation/NSNotification.h>

#include <AppKit/NSButton.h>
#include <AppKit/NSNibLoading.h>
#include <AppKit/NSStepper.h>
#include <AppKit/NSTextField.h>




@implementation	NSStepper (IBObjectAdditions)
- (NSString*) inspectorClassName
{
  return @"GormStepperAttributesInspector";
}
@end

@implementation GormStepperAttributesInspector

- (id) init
{
  if ([super init] == nil)
    {
      return nil;
    }
  if ([NSBundle loadNibNamed: @"GormNSStepperInspector" owner: self] == NO)
    {
      NSLog(@"Could not gorm GormStepperAttributesInspector");
      return nil;
    }

  return self;
}

/* Commit changes that the user makes in the Attributes Inspector */
- (void) ok: (id) sender
{
#warning setNeedsDisplay required ? 
  if (sender == valueField)
    {
      [object setDoubleValue:[sender doubleValue]];
      [object setNeedsDisplay: YES];
    }
  else if (sender == minimumValueField)
    {
      [object setMinValue:[sender doubleValue]];
      [object setNeedsDisplay: YES];
    }
  else if (sender == maximumValueField)
    {
      [object setMaxValue:[sender doubleValue]];
      [object setNeedsDisplay: YES];
    }
  else if (sender == incrementValueField)
    {
      [object setIncrement:[sender doubleValue]];
      [object setNeedsDisplay: YES];
    }
  else if (sender == autorepeatButton)
    {
      switch ([sender state])
	{
	case 0:
	  [object setAutorepeat: NO];
	  break;
	case 1:
	  [object setAutorepeat: YES];
	  break;
	}
    }
  else if (sender == valueWrapsButton)
    {
      switch ([sender state])
	{
	case 0:
	  [object setValueWraps: NO];
	  break;
	case 1:
	  [object setValueWraps: YES];
	  break;
	}
    }

  [super ok:(id) sender];
}

/* Sync from object ( NSStepper ) changes to the inspector   */
- (void) revert:(id) sender
{
  if (object == nil)
    return;
    
  [valueField setDoubleValue: [object doubleValue]];
  [minimumValueField setDoubleValue: [object minValue]];
  [maximumValueField setDoubleValue: [object maxValue]];
  [incrementValueField setDoubleValue: [object increment]];

  if ([object autorepeat])
    [autorepeatButton setState: 1];
  else
    [autorepeatButton setState: 0];

  if ([object valueWraps])
    [valueWrapsButton setState: 1];
  else
    [valueWrapsButton setState: 0];

  [super revert:sender];
}

/* delegate methods for NSForms */
-(void) controlTextDidChange:(NSNotification *)aNotification
{
  [self ok:[aNotification object]];
}



@end 
