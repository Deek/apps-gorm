#ifndef GORMDOCUMENT_H
#define GORMDOCUMENT_H

@interface GormDocument : GSNibContainer <IBDocuments>
{
  GormResourcesManager	*resourcesManager;
  NSString		*documentPath;
  NSMapTable		*objToName;
  id			owner;		/* Dummy object	*/
}
- (void) addConnector: (id<IBConnectors>)aConnector;
- (NSArray*) allConnectors;
- (void) attachObject: (id)anObject toParent: (id)aParent;
- (void) attachObjects: (NSArray*)anArray toParent: (id)aParent;
- (NSArray*) connectorsForDestination: (id)destination;
- (NSArray*) connectorsForDestination: (id)destination
			      ofClass: (Class)aConnectorClass;
- (NSArray*) connectorsForSource: (id)source;
- (NSArray*) connectorsForSource: (id)source
			 ofClass: (Class)aConnectorClass;
- (BOOL) containsObject: (id)anObject;
- (BOOL) containsObjectWithName: (NSString*)aName forParent: (id)parent;
- (BOOL) copyObject: (id)anObject
	       type: (NSString*)aType
       toPasteboard: (NSPasteboard*)aPasteboard;
- (BOOL) copyObjects: (NSArray*)anArray
		type: (NSString*)aType
	toPasteboard: (NSPasteboard*)aPasteboard;
- (void) detachObject: (id)anObject;
- (void) detachObjects: (NSArray*)anArray;
- (NSString*) documentPath;
- (BOOL) documentShouldClose;
- (void) documentWillClose;
- (NSString*) nameForObject: (id)anObject;
- (id) objectForName: (NSString*)aString;
- (NSArray*) objects;
- (id) openDocument: (id)sender;
- (id) parentOfObject: (id)anObject;
- (NSArray*) pasteType: (NSString*)aType
	fromPasteboard: (NSPasteboard*)aPasteboard
		parent: (id)parent;
- (GormResourcesManager*) resourcesManager;
- (void) removeConnector: (id<IBConnectors>)aConnector;
- (id) saveAsDocument: (id)sender;
- (id) saveDocument: (id)sender;
- (void) setDocumentActive: (BOOL)flag;
- (void) setName: (NSString*)aName forObject: (id)object;
- (void) touch;		/* Mark document as having been changed.	*/
@end

#endif
