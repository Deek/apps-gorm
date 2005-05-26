/* IBConnectors.m
 *
 * Copyright (C) 2003 Free Software Foundation, Inc.
 *
 * Author:	Gregory John Casamento <greg_casamento@yahoo.com>
 * Date:	2003
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

#include <Foundation/NSString.h>
#include <AppKit/NSNibConnector.h>

NSString *IBWillAddConnectorNotification
  = @"IBWillAddConnectorNotification";
NSString *IBDidAddConnectorNotification
  = @"IBDidAddConnectorNotification";
NSString *IBWillRemoveConnectorNotification
  = @"IBWillRemoveConnectorNotification";
NSString *IBDidRemoveConnectorNotification
  = @"IBDidRemoveConnectorNotification";


@interface NSObject (IBNibInstantiation)
- (id) nibInstantiate;
@end

@implementation NSObject (IBNibInstantiation)
- (id) nibInstantiate
{
  // default implementation of nibInstantiate
  return self;
}
@end
