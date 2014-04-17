//
//  CoreDataManager.m
//  RocketBankMail
//
//  Created by Тимур Юсипов on 31.08.13.
//  Copyright (c) 2013 Usipov Timur. All rights reserved.
//

#import "CoreDataManager.h"

@interface CoreDataManager ()

@property (nonatomic, retain, readwrite) NSManagedObjectModel *mainManagedObjectModel;
@property (nonatomic, retain, readwrite) NSPersistentStoreCoordinator *mainPersistentStoreCoordinator;
@property (nonatomic, retain, readwrite) NSManagedObjectContext *mainManagedObjectContext;

+(NSURL *)applicationCoreDataStoreFileURL;

@end

#pragma mark -

@implementation CoreDataManager

@synthesize mainManagedObjectContext        = _mainManagedObjectContext,
            mainManagedObjectModel          = _mainManagedObjectModel,
            mainPersistentStoreCoordinator  = _mainPersistentStoreCoordinator;

-(id)init
{
    self = [super init];
    if (self) {
        //instantiate model, coordinator and a main context
        [self mainManagedObjectContext];
    }
    return self;
}

#pragma mark - public methods

+(CoreDataManager *)sharedManager
{
	static dispatch_once_t predicate = 0;
	static CoreDataManager *object = nil;
	dispatch_once(&predicate, ^{
        object = [self new];
    });
	return object; // CoreDataManager singleton
}



#pragma mark - properties

-(NSManagedObjectModel *)mainManagedObjectModel
{
	if (! _mainManagedObjectModel) {
        NSAssert([NSThread isMainThread], @"Create mainManagedObjectModel only on the main thread");
		NSURL *modelURL = [[NSBundle mainBundle] URLForResource: @"Model" withExtension: @"momd"];
		_mainManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];
	}
	return _mainManagedObjectModel;
}

-(NSPersistentStoreCoordinator *)mainPersistentStoreCoordinator
{
	if (! _mainPersistentStoreCoordinator) {
		NSAssert([NSThread isMainThread], @"Create mainPersistentStoreCoordinator only on the main thread");
        
		NSURL *storeURL = [CoreDataManager applicationCoreDataStoreFileURL];
        
		__autoreleasing NSError *error = nil;
		NSDictionary *migratingOptions = @ {
            NSMigratePersistentStoresAutomaticallyOption : @YES,
            NSInferMappingModelAutomaticallyOption : @YES };

		_mainPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self mainManagedObjectModel]];
        
        NSPersistentStore *store = [_mainPersistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType configuration: nil URL: storeURL options: migratingOptions error: &error];
        if (! store) {
            #ifdef DEBUG
            NSLog(@"Failed to create an SQLite store");
            NSLog(@"error: %@", error);
            #endif
        }
	}
    
	return _mainPersistentStoreCoordinator;
}

-(NSManagedObjectContext *)mainManagedObjectContext
{
	if (! _mainManagedObjectContext) {
		NSAssert([NSThread isMainThread], @"Create mainManagedObjectContext only on the main thread");
        _mainManagedObjectContext = [self newManagedObjectContext];
	}
	return _mainManagedObjectContext;
}


#pragma mark - public methods

-(NSManagedObjectContext *)newManagedObjectContext
{
	NSManagedObjectContext *someManagedObjectContext = nil;
    
	NSPersistentStoreCoordinator *coordinator = [self mainPersistentStoreCoordinator];
    
	if (coordinator) {
		someManagedObjectContext = [NSManagedObjectContext new];
		[someManagedObjectContext setPersistentStoreCoordinator: coordinator];
	}
    
	return someManagedObjectContext;
}

-(void)saveMainManagedObjectContext
{
    NSAssert([NSThread isMainThread], @"Save main moc only on a main thread");
    
	if (_mainManagedObjectContext) {
        [self saveManagedObjectContext: _mainManagedObjectContext];
	}
}

-(void)saveManagedObjectContext: (NSManagedObjectContext *)context;
{
    __autoreleasing NSError *error = nil;
    
    if (YES == [context hasChanges]) {
        if (! [context save: &error]) {
#ifdef DEBUG
            NSLog(@"%s %@", __FUNCTION__, error);
#endif
        }
    }
}

#pragma mark - private methods

+(NSURL *)applicationCoreDataStoreFileURL
{
    NSFileManager *fileManager = [NSFileManager new];
    NSURL *url = [fileManager URLForDirectory: NSApplicationSupportDirectory inDomain: NSUserDomainMask appropriateForURL: nil create: YES error: NULL];
    return [url URLByAppendingPathComponent: @"CTConsultingTestTask.sqlite"];
}


@end
