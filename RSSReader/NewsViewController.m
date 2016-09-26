//
//  NewsViewController.m
//  RSSReader
//
//  Created by NSSimpleApps on 31.05.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

#import "NewsViewController.h"
#import "EGOCache.h"
#import "RSSParser/RSSChannel.h"
#import "RSSParser/RSSItem.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

static NSString *const kPrefixImageURL = @"ImageURL_";

@interface NewsViewController ()

@property (strong, nonatomic) EGOCache *cache;

@property (copy, nonatomic) NSArray *filteredRSSChannels;

@end

@implementation NewsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.cache = [[EGOCache alloc] initWithCacheDirectory:[NSBundle mainBundle].resourcePath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.RSSChannels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    RSSChannel *channel = self.RSSChannels[section];
    
    return (channel.items).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    RSSChannel *channel = self.RSSChannels[indexPath.section];
    RSSItem *item = channel.items[indexPath.row];
    
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.pubDate;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    RSSChannel *channel = self.RSSChannels[section];
    return channel.title;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.imageView.image = nil;
    
    RSSChannel *channel = self.RSSChannels[indexPath.section];
    RSSItem *item = channel.items[indexPath.row];
    
    UIImage *cachedImage = [self.cache imageForKey:[self customKeyForImageURL:item.imageURL]];
    
    if (cachedImage) {
        
        cell.imageView.image = cachedImage;
        [cell setNeedsLayout];
    } else {
        
        __weak typeof(cell) weakCell = cell;
        __weak typeof(self) weakSelf = self;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:item.imageURL
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:10];
        
        [cell.imageView setImageWithURLRequest:request
                              placeholderImage:nil
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           
                                           [weakSelf.cache setImage:image forKey:[weakSelf customKeyForImageURL:item.imageURL]];
                                           weakCell.imageView.image = image;
                                           [weakCell setNeedsLayout];
                                           
                                       } failure:nil];
    }
}

- (NSString*)customKeyForImageURL:(NSURL*)imageURL {
    
    if (imageURL) {
        
        return [kPrefixImageURL stringByAppendingString:imageURL.absoluteString];
    }
    return kPrefixImageURL;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ShowDetailsSegue"]) {
        
        NSIndexPath *selectedIndexPath = (self.tableView).indexPathForSelectedRow;
        
        RSSChannel *channel = self.RSSChannels[selectedIndexPath.section];
        RSSItem *item = channel.items[selectedIndexPath.row];
        
        DetailsViewController *detailsViewController = segue.destinationViewController;
        detailsViewController.details = item.itemDescription;
        detailsViewController.webLink = item.link;
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    
}

@end
