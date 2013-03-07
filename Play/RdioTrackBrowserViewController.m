//
//  RdioTrackBrowserViewController.m
//  Play
//
//  Created by Drew Ingebretsen on 3/7/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "RdioTrackBrowserViewController.h"
#import "RdioConstants.h"
#import "RdioSong.h"
#import "RdioArtist.h"
#import "RdioAlbum.h"
#import "SonosController.h"
#import "SonosInput.h"

@interface RdioTrackBrowserViewController ()<RDAPIRequestDelegate, RdioDelegate>
@property (nonatomic, strong) Rdio *rdio;
@property (nonatomic, assign) NSInteger trackCount;
@end

@implementation RdioTrackBrowserViewController


#pragma mark Rdio API
-(void)rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken{
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"rdioAccessKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //TODO Add persistance so it doesn't rebuild Rdio library each time
    if ([self.itemList count] == 0){
        [self syncRdioCollection];
    }
}

-(void)viewDidLoad{
    [super viewDidLoad];
    if ([self.itemList count] == 0){
        self.rdio = [[Rdio alloc] initWithConsumerKey:RDIO_CONSUMER_KEY andSecret:RDIO_CONSUMER_SECRET delegate:self];
        [self.rdio authorizeUsingAccessToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"rdioAccessKey"] fromController:self];
    }
}

-(void)syncRdioCollection{
    self.title = @"Downloading...";
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSLog(@"Starting RdioCollectionSync");
    [self.rdio callAPIMethod:@"currentUser" withParameters:@{@"extras":@"trackCount"} delegate:self];
}

-(void)rdioAuthorizationFailed:(NSString *)error{
    NSLog(@"Error!");
}

-(void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"Error!");
}


-(void)rdioRequest:(RDAPIRequest *)request didLoadData:(id)data{
    if ([[request.parameters objectForKey:@"method"] isEqualToString:@"getTracksInCollection"]){
        
        static NSMutableArray *trackArray;
        if (!trackArray){
            trackArray = [[NSMutableArray alloc] init];
        }
        
        [trackArray addObjectsFromArray:data];
        if ([trackArray count] == self.trackCount){
            self.title = @"Organizing...";
            [self buildRdioDataFromArray:trackArray];
        }
    }
    else if ([[request.parameters objectForKey:@"method"] isEqualToString:@"currentUser"]){
        //Got the users track count. Divide it by 1000 and launch a new request for every method to get a total of all tracks.
        self.trackCount = [[data objectForKey:@"trackCount"] integerValue];
        NSInteger count = 0;
        
        while (count < self.trackCount){
            [self.rdio callAPIMethod:@"getTracksInCollection" withParameters:@{@"count":@"500", @"start":[NSString stringWithFormat:@"%i", count]} delegate:self];
            count +=500;
        }
    }
    
}

-(void)buildRdioDataFromArray:(NSArray*)collection{
    //TODO This is a very slow and inefficient way of doing this.
    NSLog(@"Rdio Data recieved. Starting Collection build");
    NSMutableArray *rdioCollection = [[NSMutableArray alloc] init];
    
    //Build a list of artists and keys
    NSOrderedSet *artistNames =[NSOrderedSet orderedSetWithArray:[collection valueForKey:@"artist"]];
    NSOrderedSet *artistKeys =[NSOrderedSet orderedSetWithArray:[collection valueForKey:@"artistKey"]];
    
    //Create each Artist and add it to the collection
    for (int i=0; i < [artistNames count]; i++){
        RdioArtist *artistObject = [[RdioArtist alloc] init];
        artistObject.albums = [[NSMutableArray alloc] init];
        artistObject.name = [artistNames objectAtIndex:i];
        artistObject.key = [artistKeys objectAtIndex:i];
        
        //Build a list of albums and keys for the artist
        NSArray *albumCollection = [collection filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"artistKey == %@",artistObject.key]];
        NSOrderedSet *albumNames = [NSOrderedSet orderedSetWithArray:[albumCollection valueForKey:@"album"]];
        NSOrderedSet *albumKeys = [NSOrderedSet orderedSetWithArray:[albumCollection valueForKeyPath:@"albumKey"]];
        
        //Add all albums to the artist
        for (int j=0; j < [albumNames count]; j++){
            RdioAlbum *albumObject = [[RdioAlbum alloc] init];
            albumObject.songs = [[NSMutableArray alloc] init];
            albumObject.name = [albumNames objectAtIndex:j];
            albumObject.key = [albumKeys objectAtIndex:j];
            albumObject.artist = artistObject;
            
            //Get all tracks for album
            NSArray *trackCollection = [collection filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"albumKey == %@",albumObject.key]];
            
            //Add all tracks to the album
            for (NSDictionary *dictionary in trackCollection){
                RdioSong *songObject = [[RdioSong alloc] init];
                songObject.name = [dictionary objectForKey:@"name"];
                songObject.key = [dictionary objectForKey:@"key"];
                songObject.album = albumObject;
                [albumObject.songs addObject:songObject];
            }
            [artistObject.albums addObject:albumObject];
        }
    [rdioCollection addObject:artistObject];
    }
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    [rdioCollection sortUsingDescriptors:@[sortDescriptor]];
    self.itemList = rdioCollection;
    self.title = @"";
    NSLog(@"Finished collection build");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.tableView reloadData];
    
}

#pragma mark UITableView Datasource/Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.itemList count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = [[self.itemList objectAtIndex:indexPath.row] name];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id rdioObject = [self.itemList objectAtIndex:indexPath.row];
    if ([rdioObject isKindOfClass:[RdioSong class]]){
        RdioSong *song = rdioObject;
        SonosInput *input = [[SonosInput alloc] initWithIP:@"192.168.8.100" name:@"Family Room" uid:@"RINCON_000E58F8361601400_MR"];
        SonosController *sonos = [[SonosController alloc] initWithInput:input];
        [sonos play:input rdioSong:song completion:^(SonosResponse *response, NSError *error){
            [[[UIAlertView alloc] initWithTitle:@"Notice" message:@"Sent Rdio Track To Sonos" delegate:nil cancelButtonTitle:@"Okay!" otherButtonTitles:nil] show];
        }];
    }
    else if ([rdioObject isKindOfClass:[RdioAlbum class]]){
        RdioTrackBrowserViewController *next = [[RdioTrackBrowserViewController alloc] init];
        RdioAlbum *album = rdioObject;
        next.itemList = album.songs;
        [self.navigationController pushViewController:next animated:YES];
    }
    else if ([rdioObject isKindOfClass:[RdioArtist class]]){
        RdioTrackBrowserViewController *next = [[RdioTrackBrowserViewController alloc] init];
        RdioArtist *artist = rdioObject;
        next.itemList = artist.albums;
        [self.navigationController pushViewController:next animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
