/* inspectors - Various inspectors for data elements

   Copyright (C) 2001 Free Software Foundation, Inc.

   Author:  Laurent Julliard <laurent@julliard-online.org>
   Date: Nov 2001
   
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

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <InterfaceBuilder/InterfaceBuilder.h>
#include <GormCore/GormPrivate.h>
#include <GormCore/GormViewEditor.h>
#include <GormCore/NSColorWell+GormExtensions.h>


/* this macro makes sure that the string contains a value, even if @"" */
#define VSTR(str) ({id _str = str; (_str) ? _str : @"";})


extern NSArray *predefinedDateFormats, *predefinedNumberFormats;



/*----------------------------------------------------------------------------
 * NSImageView
 */


/*----------------------------------------------------------------------------
 * NSTextView (possibly embedded in a Scroll view)
 */

@interface GormViewSizeInspector : IBInspector
{
  NSButton	*top;
  NSButton	*bottom;
  NSButton	*left;
  NSButton	*right;
  NSButton	*width;
  NSButton	*height;
  NSForm        *sizeForm;
}
@end

@interface GormTextViewSizeInspector : GormViewSizeInspector
@end
@implementation GormTextViewSizeInspector
- (void) setObject: (id)anObject
{
  id scrollView;
  scrollView = [anObject enclosingScrollView];

  [super setObject: scrollView];
}
@end


@implementation	NSTextView (IBInspectorClassNames)

- (NSString*) sizeInspectorClassName
{
  return @"GormTextViewSizeInspector";
}

@end

@interface GormTextViewEditor : GormViewEditor
{
  NSTextView *textView;
}
@end

@implementation GormTextViewEditor

- (BOOL) activate
{
  if ([super activate])
    {
      if ([_editedObject isKindOfClass: [NSScrollView class]])
	textView = [(NSScrollView *)_editedObject documentView];
      else
	textView = (NSTextView *)_editedObject;
      return YES;
    }
  return NO;
}

- (unsigned) draggingUpdated: (id<NSDraggingInfo>)sender

{
  NSPasteboard	*dragPb;
  NSArray	*types;
  
  dragPb = [sender draggingPasteboard];
  types = [dragPb types];
  if ([types containsObject: GormLinkPboardType] == YES)
    {
      id destination = nil;
      NSView *hitView = 
	[[textView enclosingScrollView] 
	  hitTest: 
	    [[[textView enclosingScrollView] superview]
	      convertPoint: [sender draggingLocation]
	      fromView: nil]];

      if ((hitView == textView) || (hitView == [textView superview]))
	destination = textView;

      if (destination == nil)
	destination = _editedObject;

      [NSApp displayConnectionBetween: [NSApp connectSource] 
	     and: destination];
      return NSDragOperationLink;
    }
  else
    {
      return NSDragOperationNone;
    }
}
- (BOOL) performDragOperation: (id<NSDraggingInfo>)sender
{
  NSPasteboard	*dragPb;
  NSArray	*types;
  
  dragPb = [sender draggingPasteboard];
  types = [dragPb types];
  if ([types containsObject: GormLinkPboardType] == YES)
    {
      id destination = nil;
      NSView *hitView = 
	[[textView enclosingScrollView] 
	  hitTest: 
	    [[[textView enclosingScrollView] superview]
	      convertPoint: [sender draggingLocation]
	      fromView: nil]];
      
      if ((hitView == textView) || (hitView == [textView superview]))
	destination = textView;

      if (destination == nil)
	destination = _editedObject;

      [NSApp displayConnectionBetween: [NSApp connectSource] 
	     and: destination];
      [NSApp startConnecting];
      return YES;
    }
  return YES;
}

- (NSWindow *)windowAndRect: (NSRect *)prect
		  forObject: (id) object
{
  if (object == textView)
    {
      *prect = [[textView superview] convertRect: [[textView superview] visibleRect]
			  toView :nil];
      return _window;
    }
  else
    {
      return [super windowAndRect: prect forObject: object];
    }
}
@end


/*------------------------------------------------------------------
 * NSDateFormatter
 *
 * Rk: The Inspector object is also the table view delegate and data source
 *-----------------------------------------------------------------*/

@implementation	NSDateFormatter (IBInspectorClassNames)

- (NSString*) inspectorClassName
{
  return @"GormDateFormatterAttributesInspector";
}

@end

@interface GormDateFormatterAttributesInspector : IBInspector
{
  NSTableView *formatTable;
  id formatField;
  id languageSwitch;
  id detachButton;
}
@end

@implementation GormDateFormatterAttributesInspector

- (void) _setValuesFromControl: control
{
  BOOL allowslanguage;
  NSString *dateFmt;
  NSDateFormatter *fmtr;
    
  if (control == detachButton)
    {
      [[object cell] setFormatter: nil];
      [[(id<IB>)NSApp activeDocument] setSelectionFromEditor: nil];
    }
  else
    {
      NSCell *cell = [object cell];

      if (control == formatTable)
        {
          int row;
          
          if ((row = [control selectedRow]) != -1)
            {
              dateFmt = [NSDateFormatter formatAtIndex: row];            
            }
          
          [formatField setStringValue: VSTR(dateFmt) ];
        }
      else if (control == formatField)
        {
          int idx;
          
          dateFmt = [control stringValue];

          // If the string typed is a predefined one then highligh it in
          // table dateFormat table view above
          if ( (idx = [NSDateFormatter indexOfFormat: dateFmt]) == NSNotFound)
            {
              [formatTable deselectAll:self];
            }
          else
            {
              [formatTable selectRow:idx byExtendingSelection:NO];
            }
          
        }
      else if (control == languageSwitch)
        {
          allowslanguage = ([control state] == NSOnState);
        }

      // Update the Formatter and refresh the Cell value
      fmtr = [[NSDateFormatter alloc] initWithDateFormat:dateFmt
                                      allowNaturalLanguage:allowslanguage];
      [cell setFormatter:fmtr];
      RELEASE(fmtr);
      
      [cell setObjectValue: [cell objectValue]];
      
    }
  
}

- (void) _getValuesFromObject: (id) anObject
{
  int idx;
  NSDateFormatter *fmtr = [[anObject cell] formatter];
  
  if (anObject != object)
    {
      return;
    }

  
  // If the string typed is a predefined one then highligh it in
  // table dateFormat table view above
  if ( (idx = [NSDateFormatter indexOfFormat: [fmtr dateFormat]]) == NSNotFound)
    {
      [formatTable deselectAll:self];
    }
  else
    {
      [formatTable selectRow:idx byExtendingSelection:NO];
    }
  [formatField setStringValue: VSTR([fmtr dateFormat]) ];
  [languageSwitch setState: [fmtr allowsNaturalLanguage]];
}

- (id) init
{

  if ([super init] == nil)
    {
      return nil;
    }
  if ([NSBundle loadNibNamed: @"GormNSDateFormatterInspector" owner: self] == NO)
    {
      NSLog(@"Could not gorm GormDateFormatterInspector");
      return nil;
    }

  return self;
}

- (void) ok: (id)sender
{
  [super ok: sender];
  [self _setValuesFromControl: sender];
}

- (void) setObject: (id)anObject
{
  NSDebugLog(@"Formatting object: %@", anObject);
  [super setObject: anObject];
  [self _getValuesFromObject: anObject];
}

/* NSDateFormatter inspector: table view delegate and data source */

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
  return [NSDateFormatter formatCount];
}

- (id)tableView:(NSTableView *)aTableView
  objectValueForTableColumn:(NSTableColumn *)aTableColumn
  row:(int)rowIndex
{
  NSString *fmt = [NSDateFormatter formatAtIndex:rowIndex];
  
  if ( [[aTableColumn identifier] isEqualToString: @"format"] )
    {
      return fmt;
    }
  else if ( [[aTableColumn identifier] isEqualToString: @"date"] )
    {
      return [[NSDateFormatter defaultFormatValue]
               descriptionWithCalendarFormat:fmt ];
    }
  else 
    {
      // Huuh?? Only 2 columns
      NSLog(@"Date table view only doesn't known column identifier: %@", [aTableColumn identifier]);
    }
  
  return nil;
  
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
  [self _setValuesFromControl: formatTable];
}

@end


/*------------------------------------------------------------------
 * NSNumberFormatter
 *
 * Rk: The Inspector object is also the table view delegate and data source
 *-----------------------------------------------------------------*/

@implementation	NSNumberFormatter (IBInspectorClassNames)

- (NSString*) inspectorClassName
{
  return @"GormNumberFormatterAttributesInspector";
}

@end

@interface GormNumberFormatterAttributesInspector : IBInspector
{
  id addThousandSeparatorSwitch;
  id commaPointSwitch;
  id formatForm;
  id formatTable;
  id localizeSwitch;
  id negativeField;
  id negativeRedSwitch;
  id positiveField;
  id detachButton;
}
@end

@implementation GormNumberFormatterAttributesInspector

- (void) updateAppearanceFieldsWithFormat: (NSString *)format;
{

  [[[positiveField cell] formatter] setFormat: format];
  [[positiveField cell] setObjectValue:
        [NSDecimalNumber decimalNumberWithString: @"123456.789"]];
  
  [[[negativeField cell] formatter] setFormat: format];
  [[negativeField cell] setObjectValue:
        [NSDecimalNumber decimalNumberWithString: @"-123456.789"]];
}


- (void) _setValuesFromControl: control
{
  NSString *positiveFmt, *negativeFmt, *zeroFmt, *fullFmt;
  NSString *minValue, *maxValue;
  NSCell   *cell = [object cell];
  NSNumberFormatter *fmtr = [cell formatter];
    
  if (control == detachButton)
    { 
      [cell setFormatter: nil];
      [[(id<IB>)NSApp activeDocument] setSelectionFromEditor: nil];
    }
  else
    {

      if (control == formatTable)
        {
          int row;

          if ((row = [control selectedRow]) != -1)
            {
              positiveFmt = [NSNumberFormatter positiveFormatAtIndex:row];
              zeroFmt     = [NSNumberFormatter zeroFormatAtIndex:row];
              negativeFmt = [NSNumberFormatter negativeFormatAtIndex:row];
              fullFmt     = [NSNumberFormatter formatAtIndex:row];
            }
          
          // Update Appearance samples
          [self updateAppearanceFieldsWithFormat: fullFmt];
           
          // Update editable format fields
          [[formatForm cellAtIndex:0] setStringValue: VSTR(positiveFmt)];
          [[formatForm cellAtIndex:1] setStringValue: VSTR(zeroFmt)];
          [[formatForm cellAtIndex:2] setStringValue: VSTR(negativeFmt)];

          [fmtr setFormat:fullFmt];
          
         }

      else if (control == formatForm)
        {
          int idx;
          
          positiveFmt = [[control cellAtIndex:0] stringValue];
          zeroFmt = [[control cellAtIndex:1] stringValue];
          negativeFmt = [[control cellAtIndex:2] stringValue];
          minValue = [[control cellAtIndex:3] stringValue];
          maxValue = [[control cellAtIndex:4] stringValue];
          NSDebugLog(@"min,max: %@, %@", minValue, maxValue);
          
          fullFmt = [NSString stringWithFormat:@"%@;%@;%@",
                              positiveFmt, zeroFmt, negativeFmt];

          // If the 3 formats correspond to a predefined set  then highlight it in
          // number Format table view above
          if ( (idx = [NSNumberFormatter indexOfFormat: fullFmt]) == NSNotFound)
            {
              [formatTable deselectAll:self];
            }
          else
            {
              [formatTable selectRow:idx byExtendingSelection:NO];
              NSDebugLog(@"format found at index: %d", idx);
            }

          // Update Appearance samples
          [self updateAppearanceFieldsWithFormat: fullFmt];

          [fmtr setFormat: fullFmt];

          if (minValue != nil)
            [fmtr setMinimum: [NSDecimalNumber decimalNumberWithString: minValue]];
          if (maxValue != nil)
            [fmtr setMaximum: [NSDecimalNumber decimalNumberWithString: maxValue]];
          
          
        }
      else if (control == localizeSwitch)
        {
          [fmtr setLocalizesFormat:([control state] == NSOnState)];
        }
      else if (control == negativeRedSwitch)
        {
          NSMutableDictionary *newAttrs = [NSMutableDictionary dictionary];

          [newAttrs setObject:[NSColor redColor] forKey:@"NSColor"];
          [fmtr setTextAttributesForNegativeValues:newAttrs];
        }
      else if (control == addThousandSeparatorSwitch)
        {
          [fmtr setHasThousandSeparators:([control state] == NSOnState)];
        }
      else if (control == commaPointSwitch)
        {
         [fmtr setDecimalSeparator:([control state] == NSOnState) ? @"," : @"."];
         }
      
      // FIXME: Force cell refresh with the new formatter. Really useful ?
      //[cell setObjectValue: [cell objectValue]];
 
    }
  
}

- (void) _getValuesFromObject: (id) anObject
{
  int idx;
  NSNumberFormatter *fmtr = [[anObject cell] formatter];


  if (anObject != object)
    {
      return;
    }

  // Format form
  NSDebugLog(@"format from object: %@", [fmtr format]);
  [[formatForm cellAtIndex:0] setStringValue: [fmtr positiveFormat]];
  [[formatForm cellAtIndex:1] setStringValue: [fmtr zeroFormat]];
  [[formatForm cellAtIndex:2] setStringValue: [fmtr negativeFormat]];
  [[formatForm cellAtIndex:3] setObjectValue: [fmtr minimum]];
  [[formatForm cellAtIndex:4] setObjectValue: [fmtr maximum]];

  // If the string typed is a predefined one then highligh it in
  // Number Format table view above  
  if ( (idx = [NSNumberFormatter indexOfFormat: [fmtr format]]) == NSNotFound)
    {
      [formatTable deselectAll:self];
    }
  else
    {
      [formatTable selectRow:idx byExtendingSelection:NO];
    }

  // Option switches
  [localizeSwitch setState: ([fmtr localizesFormat] == YES) ? NSOnState : NSOffState];

  [addThousandSeparatorSwitch setState: ([fmtr hasThousandSeparators] == YES) ? NSOnState : NSOffState];

  if ([[fmtr decimalSeparator] isEqualToString: @","] )
    [commaPointSwitch setState: NSOnState];
  else 
    [commaPointSwitch setState: NSOffState];

  if ( [[[fmtr textAttributesForNegativeValues] objectForKey: @"NSColor"] isEqual: [NSColor redColor] ] )
      [negativeRedSwitch setState: NSOnState];
  else
      [negativeRedSwitch setState: NSOffState];
  
}

- (id) init
{

  if ([super init] == nil)
    {
      return nil;
    }
  if ([NSBundle loadNibNamed: @"GormNSNumberFormatterInspector"
		       owner: self] == NO)
    {
      NSLog(@"Could not gorm GormNumberFormatterInspector");
      return nil;
    }

  // Initialize Positive/Negative appearance fields formatter
  {
    NSNumberFormatter *fmtr = [[NSNumberFormatter alloc] init];
    [fmtr setFormat: [NSNumberFormatter defaultFormat]];
    [[positiveField cell] setFormatter: fmtr];
    [[negativeField cell] setFormatter: fmtr];
  }
  
  return self;
}

- (void) ok: (id)sender
{
  [super ok: sender];
  [self _setValuesFromControl: sender];
}

- (void) setObject: (id)anObject
{
  NSDebugLog(@"Formatting object: %@", anObject);
  [super setObject: anObject];
  [self _getValuesFromObject: anObject];
}

/* Positive/Negative Format table data source */

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
  return [NSNumberFormatter formatCount];
}

- (id)tableView:(NSTableView *)aTableView
  objectValueForTableColumn:(NSTableColumn *)aTableColumn
  row:(int)rowIndex
{  
  if ( [[aTableColumn identifier] isEqualToString: @"positive"] )
    {
      return [NSNumberFormatter positiveValueAtIndex:rowIndex];
    }
  else if ( [[aTableColumn identifier] isEqualToString: @"negative"] )
    {
      return [NSNumberFormatter negativeValueAtIndex:rowIndex];
    }
  else 
    {
      // Huuh?? Only 2 columns
      NSLog(@"Number table view doesn't known column identifier: %@", [aTableColumn identifier]);
    }
  
  return nil;
  
}

/* Positive/Negative Format table Delegate */

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
  // When a row is selected update the rest of the inspector accordingly
  [self _setValuesFromControl: formatTable];
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell
   forTableColumn:(NSTableColumn*)aTableColumn row:(int)rowIndex
{
  NSNumberFormatter *fmtr;
  
  // Adjust the cell formatter before it is displayed
  fmtr = [[NSNumberFormatter alloc] init];
  [fmtr setFormat: [NSNumberFormatter formatAtIndex:rowIndex]];
  [aCell setFormatter: fmtr];
  //RELEASE(fmtr);
  
}

@end
