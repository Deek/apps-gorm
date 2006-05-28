/* GormImageEditor.m
 *
 * Copyright (C) 2002 Free Software Foundation, Inc.
 *
 * Author:	Gregory John Casamento <greg_casamento@yahoo.com>
 * Date:	2002
 * 
 * This file is part of GNUstep.
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02111 USA.
 */

#include <AppKit/NSImage.h>
#include <InterfaceBuilder/IBObjectAdditions.h>
#include "GormImage.h"

// implementation of category on NSImage.
@implementation NSImage (GormNSImageAddition)
- (void) setArchiveByName: (BOOL) archiveByName
{
  _flags.archiveByName = archiveByName;
}

- (BOOL) archiveByName
{
  return _flags.archiveByName;
}
@end

// image proxy object...
@implementation GormImage
+ (GormImage*)imageForPath: (NSString *)aPath
{  
  return [GormImage imageForPath: aPath inWrapper: NO];
}

+ (GormImage*)imageForPath: (NSString *)aPath inWrapper: (BOOL)flag
{  
  return AUTORELEASE([[GormImage alloc] initWithPath: aPath inWrapper: flag]);
}

+ (GormImage*)imageForData: (NSData *)aData withFileName: (NSString *)aName inWrapper: (BOOL)flag
{
  return AUTORELEASE([[GormImage alloc] initWithData: aData withFileName: aName inWrapper: flag]);
}

- (id) initWithData: (NSData *)aData withFileName: (NSString *)aName inWrapper: (BOOL)flag
{
  if((self = [super initWithData: aData withFileName: aName inWrapper: flag]))
    {
      ASSIGN(image, AUTORELEASE([[NSImage alloc] initWithData: aData]));
    }
  return self;
}

- (id) initWithName: (NSString *)aName
	       path: (NSString *)aPath
	  inWrapper: (BOOL)flag
{
  if((self = [super initWithName: aName path: aPath inWrapper: flag]))
    {
      NSSize originalSize;
      float ratioH;
      float ratioW;

      image = RETAIN([[NSImage alloc] initByReferencingFile: aPath]);
      smallImage = RETAIN([[NSImage alloc] initWithContentsOfFile: aPath]);
      [image setName: aName];
      
      if (smallImage == nil)
	{
	  RELEASE(self);
	  return nil;
	}
      
      originalSize = [smallImage size];
      ratioW = originalSize.width / 70;
      ratioH = originalSize.height / 55;
      
      if (ratioH > 1 || ratioW > 1)
	{
	  [smallImage setScalesWhenResized: YES];
	  if (ratioH > ratioW)
	    {
	      [smallImage setSize: NSMakeSize(originalSize.width / ratioH, 55)];
	    }
	  else 
	    {
	      [smallImage setSize: NSMakeSize(70, originalSize.height / ratioW)];
	    }
	}

      [image setArchiveByName: NO];
      [smallImage setArchiveByName: NO];
    }
  else
    {
      RELEASE(self);
    }

  return self;
}

- (void) dealloc
{
  RELEASE(image);
  RELEASE(smallImage);
  [super dealloc];
}

- (NSImage *) normalImage
{
  return image;
}

- (NSImage *) image
{
  return smallImage;
}

- (void) setSystemResource: (BOOL)flag
{
  [super setSystemResource: flag];
  [image setArchiveByName: flag];
  [smallImage setArchiveByName: flag];
}
@end

@implementation GormImage (IBObjectAdditions)
- (NSString *)inspectorClassName
{
  return @"GormImageInspector"; 
}

- (NSString *) classInspectorClassName
{
  return @"GormNotApplicableInspector";
}

- (NSString *) connectInspectorClassName
{
  return @"GormNotApplicableInspector";
}

- (NSString *) objectNameForInspectorTitle
{
  return @"Image";
}

- (NSImage *) imageForViewer
{
  return [self image];
}
@end
