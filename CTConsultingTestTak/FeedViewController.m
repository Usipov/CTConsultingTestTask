//
//  FeedViewController.m
//  CTConsultingTestTask
//
//  Created by Тимур Юсипов on 17.04.14.
//  Copyright (c) 2014 Timur. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "CoreDataManager.h"
#import "FeedViewController.h"
#import "FeedDownloader.h"
#import "AuthentificationManager.h"
#import "FeedCell.h"
#import "PlaceHolderCell.h"
#import "ThumbCache.h"
#import "FeedDetailsViewController.h"

@interface FeedViewController () <NSFetchedResultsControllerDelegate> {
    UITableView *_tableView;
    NSFetchedResultsController *_frc;
    __block NSString *_nextMaxID;
}

-(void)loadFeeds;
-(void)mergeContexts: (NSNotification *)sender;
-(void)refresh;
@end

@implementation FeedViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle: style];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(mergeContexts:) name: NSManagedObjectContextDidSaveNotification object: nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"feed", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target: self action: @selector(refresh)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"sign out", nil) style: UIBarButtonItemStylePlain target: self action: @selector(signOut:)];
}
-(void)signOut: (UIBarButtonItem *)sender
{
    [FeedRecord deleteAllInManagedObjectContext: [CoreDataManager sharedManager].mainManagedObjectContext];
    [[CoreDataManager sharedManager] saveMainManagedObjectContext];
    AuthentificationManager.sharedManager.userToken = @"";
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    //create a fetched results controller, operating on a main thread
    if (! _frc) {
        _frc = [FeedRecord fetchedResultsContollerInManagedObjectContext: CoreDataManager.sharedManager.mainManagedObjectContext];
        __autoreleasing NSError *error = nil;
        if (! [_frc performFetch: &error]) {
            #ifdef DEBUG
            NSLog(@"Failed to perfrom fetch in %s", __FUNCTION__);
            NSLog(@"     error: %@", error);
            #endif
        }

        _frc.delegate = self;
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[ThumbCache sharedCache] removeAllObjects];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self name: NSManagedObjectContextDidSaveNotification object: nil];
}

#pragma mark - extenstions

-(void)loadFeeds
{
    //success block (parses data in a background thread)
    DownloaderFinishBlock finishBLock = ^(NSArray *feeds, NSString *nextMaxID) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSManagedObjectContext *context2 = [[CoreDataManager sharedManager] newManagedObjectContext];
            [feeds enumerateObjectsUsingBlock: ^(NSDictionary *feedData, NSUInteger idx, BOOL *stop) {
                [FeedRecord insertNewInManagedObjectContext: context2 basedOnData: feedData orUpdateFetchedItemInstead: nil];
            }];
            
            [[CoreDataManager sharedManager] saveManagedObjectContext: context2];
            context2 = nil;

            dispatch_async(dispatch_get_main_queue(), ^{
                if (! nextMaxID) {
                    _nextMaxID = [NSNull null];
                    [self.tableView reloadRowsAtIndexPaths: @[[NSIndexPath indexPathForRow: _frc.fetchedObjects.count inSection: 0]] withRowAnimation: UITableViewRowAnimationFade];
                } else {
                    _nextMaxID = nextMaxID;
                }
                
                //enable refresh button
                self.navigationItem.rightBarButtonItem.enabled = YES;
            });
        });
    };
    
    //error block
    DownloaderFailBlock failBlock = ^(NSError *error) {
        //enable refresh button
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem.enabled = YES;
        });

        //try loading later
        [self performSelector: @selector(loadFeeds) withObject: nil afterDelay: 4];
    };
    
    //now load feeds
    if (_nextMaxID != [NSNull null]) {
        FeedRecord *lastRecord = [_frc.fetchedObjects lastObject];
        if (lastRecord) {
            _nextMaxID = lastRecord.identifier;
        }
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [FeedDownloader.sharedLoader loadFeedTilID: _nextMaxID withFinishBlock: finishBLock failBlock: failBlock];
    }
}

-(void)mergeContexts:(NSNotification *)sender
{
    [[CoreDataManager sharedManager].mainManagedObjectContext performSelectorOnMainThread: @selector(mergeChangesFromContextDidSaveNotification:) withObject: sender waitUntilDone: NO];
}

-(void)refresh
{
    [FeedRecord deleteAllInManagedObjectContext: [CoreDataManager sharedManager].mainManagedObjectContext];
    [[CoreDataManager sharedManager] saveMainManagedObjectContext];
    
    _nextMaxID = nil;
    [self.tableView reloadRowsAtIndexPaths: @[[NSIndexPath indexPathForRow: 0 inSection: 0]] withRowAnimation: UITableViewRowAnimationFade];
}


#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = _frc.sections[section];
    return sectionInfo.numberOfObjects + 1; //add a placeholder cell for pagination purposes
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.row == _frc.fetchedObjects.count) {
        //reached end. return a placeholder cell and start loading further
        UITableViewCell *placeHolderCell = [tableView dequeueReusableCellWithIdentifier: PlaceHolderCellReuseID];
        if (! placeHolderCell) {
            placeHolderCell = [[PlaceHolderCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: PlaceHolderCellReuseID];
        }
        if (_nextMaxID == [NSNull null]) {
            //no feeds left to load
            placeHolderCell.textLabel.text = [NSString stringWithFormat: NSLocalizedString(@"reached end", nil), _frc.fetchedObjects.count];
            placeHolderCell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            //can load more feeds
            placeHolderCell.textLabel.text = NSLocalizedString(@"tap to load", nil);
            placeHolderCell.selectionStyle = UITableViewCellSelectionStyleBlue;
            [self loadFeeds];
        }
        
        cell = placeHolderCell;

    } else {
        FeedCell *feedCell = [tableView dequeueReusableCellWithIdentifier: FeedCellReuseID];
        if (! feedCell) {
            feedCell = [[FeedCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: FeedCellReuseID];
        }
        
        FeedRecord *feed = [_frc objectAtIndexPath: indexPath];
        feedCell.textLabel.text = feed.user.userName;
        
        //user profile image
        ThumbRequest *request = [[ThumbRequest alloc] initWithThumbDownloadURL: feed.user.profilePicture thumbView: feedCell.userProfilePictureView thumbSize: CGSizeMake(30.0, 30.0f)];
        feedCell.userProfilePictureView.thumb = [[ThumbCache sharedCache] thumbImageForRequest: request];
        
        //content image
        ImageData *imageData = [feed imageDataForImageQuality: ImageQualityLow];
        request = [[ThumbRequest alloc] initWithThumbDownloadURL: imageData.url thumbView: feedCell.contentPreviewView thumbSize: CGSizeMake(320.0f, 320.0f)];
        feedCell.contentPreviewView.thumb = [[ThumbCache sharedCache] thumbImageForRequest: request];
        
        cell = feedCell;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _frc.fetchedObjects.count) {
        return 44.0f;
    } else {
        return 364.0f;
    }
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
    if (cell.selectionStyle != UITableViewCellSelectionStyleNone) {
        if (indexPath.row == _frc.fetchedObjects.count) {
            [self loadFeeds];
        } else {
            FeedDetailsViewController *vc = [[FeedDetailsViewController alloc] initWithStyle: UITableViewStylePlain];
            vc.feedItem = [_frc objectAtIndexPath: indexPath];
            [self.navigationController pushViewController: vc animated: YES];
        }
        [tableView deselectRowAtIndexPath: indexPath animated: YES];
    }
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths: @[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths: @[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections: [NSIndexSet indexSetWithIndex: sectionIndex] withRowAnimation: UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections: [NSIndexSet indexSetWithIndex: sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
