//
//  RdioTrackBrowserViewController.m
//  Play
//
//  Created by Drew Ingebretsen on 3/7/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "RdioCollectionViewController.h"
#import "RdioSong.h"
#import "RdioArtist.h"
#import "RdioAlbum.h"
#import "SonosController.h"
#import "SonosInput.h"
#import "SonosInputStore.h"
#import "PLNowPlayingViewController.h"

@interface RdioCollectionViewController () <RDAPIRequestDelegate, RdioDelegate>
{
  Rdio *rdio;
  NSInteger trackCount;
  NSMutableArray *sections;
  UILocalizedIndexedCollation *collation;
}
@end

@implementation RdioCollectionViewController

- (id)init
{
  self = [super init];
  if (self) {
    [self setTitle:@"Collection"];

    // Now Playing Button
    UIBarButtonItem *nowPlayingButton = [[UIBarButtonItem alloc] initWithTitle:@"Playing" style:UIBarButtonItemStyleDone target:self action:@selector(nowPlaying)];
    [self.navigationItem setRightBarButtonItem:nowPlayingButton];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  if ([_itemList count] == 0) {
    NSString *key = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFRdioConsumerKey"];
    NSString *secret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFRdioConsumerSecret"];
    rdio = [[Rdio alloc] initWithConsumerKey:key andSecret:secret delegate:self];
    [rdio authorizeUsingAccessToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"rdioAccessKey"] fromController:self];
  } else {
    [self configureSections];
  }
}

- (void)nowPlaying
{
  PLNowPlayingViewController *viewController = [[PLNowPlayingViewController alloc] init];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
  [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)configureSections
{
  collation = [UILocalizedIndexedCollation currentCollation];

  NSInteger sectionTitlesCount = [[collation sectionTitles] count];
  NSMutableArray *newSections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];

  for (int i = 0; i < sectionTitlesCount; i++) {
    [newSections addObject:[NSMutableArray array]];
  }

  for (id item in _itemList) {
    NSInteger sectionNumber = [collation sectionForObject:item collationStringSelector:@selector(name)];
    NSLog(@"Section: %d", sectionNumber);
    [[newSections objectAtIndex:sectionNumber] addObject:item];
  }

  for (int i = 0; i < sectionTitlesCount; i++) {
    NSMutableArray *itemsForSection = [newSections objectAtIndex:i];
    NSArray *sortedItemsForSection = [collation sortedArrayFromArray:itemsForSection collationStringSelector:@selector(name)];
    [newSections replaceObjectAtIndex:i withObject:sortedItemsForSection];
  }

  sections = newSections;
  [self.tableView reloadData];
}

#pragma mark - Rdio API

- (void)rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken{
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"rdioAccessKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // TODO: Add persistance so it doesn't rebuild Rdio library each time
    if ([_itemList count] == 0){
      [self syncRdioCollection];
    }
}

- (void)syncRdioCollection
{
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  NSLog(@"Starting RdioCollectionSync");
  [rdio callAPIMethod:@"currentUser" withParameters:@{@"extras":@"trackCount"} delegate:self];
}

- (void)rdioAuthorizationFailed:(NSString *)error
{
  NSLog(@"Rdio authorization failed: %@", error);
}

- (void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError *)error
{
  NSLog(@"Rdio request failed: %@", [error localizedDescription]);
}


- (void)rdioRequest:(RDAPIRequest *)request didLoadData:(id)data
{
  if ([[request.parameters objectForKey:@"method"] isEqualToString:@"getTracksInCollection"]) {
    static NSMutableArray *trackArray;
    if (!trackArray){
      trackArray = [[NSMutableArray alloc] init];
    }

    [trackArray addObjectsFromArray:data];
    if ([trackArray count] == trackCount) {
      [self buildRdioDataFromArray:trackArray];
    }
  } else if ([[request.parameters objectForKey:@"method"] isEqualToString:@"currentUser"]) {
    // Got the users track count. Divide it by 1000 and launch a new request
    // for every method to get a total of all tracks.
    trackCount = [[data objectForKey:@"trackCount"] integerValue];
    NSInteger count = 0;
    while (count < trackCount) {
      [rdio callAPIMethod:@"getTracksInCollection" withParameters:@{
        @"count":@"500",
        @"start":[NSString stringWithFormat:@"%i", count]
      } delegate:self];
      count += 500;
    }
  }
}

- (void)buildRdioDataFromArray:(NSArray *)collection {
  // TODO: This is a very slow and inefficient way of doing this.
  NSLog(@"Rdio Data recieved. Starting Collection build");
  NSMutableArray *rdioCollection = [[NSMutableArray alloc] init];
  
  // Build a list of artists and keys
  NSOrderedSet *artistNames =[NSOrderedSet orderedSetWithArray:[collection valueForKey:@"artist"]];
  NSOrderedSet *artistKeys =[NSOrderedSet orderedSetWithArray:[collection valueForKey:@"artistKey"]];
  
  // Create each Artist and add it to the collection
  for (int i=0; i < [artistNames count]; i++) {
    RdioArtist *artist = [[RdioArtist alloc] init];
    artist.albums = [[NSMutableArray alloc] init];
    artist.name = [artistNames objectAtIndex:i];
    artist.key = [artistKeys objectAtIndex:i];
      
    // Build a list of albums and keys for the artist
    NSArray *albumCollection = [collection filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"artistKey == %@", artist.key]];
    NSOrderedSet *albumNames = [NSOrderedSet orderedSetWithArray:[albumCollection valueForKey:@"album"]];
    NSOrderedSet *albumKeys = [NSOrderedSet orderedSetWithArray:[albumCollection valueForKeyPath:@"albumKey"]];
      
    // Add all albums to the artist
    for (int j=0; j < [albumNames count]; j++) {
      RdioAlbum *album = [[RdioAlbum alloc] init];
      album.songs = [[NSMutableArray alloc] init];
      album.name = [albumNames objectAtIndex:j];
      album.key = [albumKeys objectAtIndex:j];
      album.artist = artist;

      // Get all tracks for album
      NSArray *trackCollection = [collection filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"albumKey == %@",album.key]];
          
      // Add all tracks to the album
      for (NSDictionary *dictionary in trackCollection) {
        RdioSong *song = [[RdioSong alloc] init];
        song.name = [dictionary objectForKey:@"name"];
        song.key = [dictionary objectForKey:@"key"];
        song.album = album;
        [album.songs addObject:song];
      }
      [artist.albums addObject:album];
    }
    [rdioCollection addObject:artist];
  }
  NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
  [rdioCollection sortUsingDescriptors:@[sortDescriptor]];

  _itemList = rdioCollection;
  [self configureSections];

  NSLog(@"Finished collection build.");
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return [[collation sectionTitles] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//  if ([_itemList count] == 0) {
//    return 1;
//  }
//  return [_itemList count];
  return [[sections objectAtIndex:section] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RdioCell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RdioCell"];
  }
  if ([_itemList count] == 0) {
    [cell.textLabel setText:@"Loading..."];
    [cell.textLabel setTextColor:[UIColor grayColor]];
  } else {
    NSArray *itemsInSection = [sections objectAtIndex:indexPath.section];
    [cell.textLabel setText:[[itemsInSection objectAtIndex:indexPath.row] name]];
    [cell.textLabel setTextColor:[UIColor blackColor]];
  }
  return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return [[collation sectionTitles] objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
  return [collation sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
  return [collation sectionForSectionIndexTitleAtIndex:index];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  id rdioObject = [_itemList objectAtIndex:indexPath.row];
  if ([rdioObject isKindOfClass:[RdioSong class]]) {
    SonosController *sonos = [SonosController sharedController];
    [sonos play:nil rdioSong:(RdioSong *)rdioObject completion:^(SOAPEnvelope *envelope, NSError *error){
      [[[UIAlertView alloc] initWithTitle:@"Notice" message:@"Sent Rdio Track To Sonos" delegate:nil cancelButtonTitle:@"Okay!" otherButtonTitles:nil] show];
    }];
  } else if ([rdioObject isKindOfClass:[RdioAlbum class]]) {
    RdioAlbum *album = (RdioAlbum *)rdioObject;
    RdioCollectionViewController *viewController = [[RdioCollectionViewController alloc] init];
    [viewController setItemList:[album songs]];
    [viewController setTitle:[album name]];
    [self.navigationController pushViewController:viewController animated:YES];
  } else if ([rdioObject isKindOfClass:[RdioArtist class]]) {
    RdioArtist *artist = (RdioArtist *)rdioObject;
    RdioCollectionViewController *viewController = [[RdioCollectionViewController alloc] init];
    [viewController setItemList:[artist albums]];
    [viewController setTitle:[artist name]];
    [self.navigationController pushViewController:viewController animated:YES];
  }
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
