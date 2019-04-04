//
//  FeedsViewController.m
//  RSSReader
//
//  Created by NSSimpleApps on 31.05.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

#import "FeedsViewController.h"
#import "EGOCache.h"
#import "RSSParser/RSSParser.h"
#import "RSSParser/RSSChannel.h"
#import "StarButton.h"
#import "NewsViewController.h"

static NSString *const kPrefixRSSChannel = @"RSSChannel_"; // специальный префикс для для каждого канала

static NSString *const kPrefixRSSSource = @"RSSSource_"; // специальный префикс для для каждого канала


@interface FeedsViewController ()

@property (strong, nonatomic) NSMutableArray<RSSChannel *> *RSSChannels; // массив с источниками лент

@property (strong, nonatomic) EGOCache *cache; // кэширует каджый источник RSS-ленты

@end

@implementation FeedsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.refreshControl = [UIRefreshControl new];
    self.refreshControl.backgroundColor = [UIColor blueColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(updateRSSSources:)
                  forControlEvents:UIControlEventValueChanged];
    
    self.RSSChannels = [NSMutableArray new];
    
    self.cache = [[EGOCache alloc] initWithCacheDirectory:[NSBundle mainBundle].resourcePath];
    
    for (NSString *key in [self.cache allKeys]) {
        
        if ([key hasPrefix:kPrefixRSSSource]) {
            
            @try {
                
                NSString *RSSChannelKey = [self.cache stringForKey:key];
                
                RSSChannel *channel = (RSSChannel*)[self.cache objectForKey:RSSChannelKey]; // достаем из кэша
                [self.RSSChannels addObject:channel];
                
            } @catch (NSException* e) { // если что - пишем ошибку
                
                NSLog(@"%@", e.reason);
                
                RSSChannel *channel = [[RSSChannel alloc] init];
                channel.link = [NSURL URLWithString:[key substringFromIndex:kPrefixRSSSource.length]];
                [self.RSSChannels addObject:channel];
            }
        }
    }
}

- (void)updateRSSSources:(UIRefreshControl*)sender {
    
    // TO DO
    
    
    [sender endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*)customKeyForRSSSource:(NSString*)RSSSource {
    
    if (RSSSource) {
        
        return [kPrefixRSSSource stringByAppendingString:RSSSource];
    }
    return kPrefixRSSSource;
}

- (NSString*)customKeyForRSSChannel:(NSURL*)RSSSource {
    
    if (RSSSource) {
        
        return [kPrefixRSSChannel stringByAppendingString:RSSSource.absoluteString];
    }
    return kPrefixRSSChannel;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.RSSChannels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    RSSChannel *channel = self.RSSChannels[indexPath.row];
    
    StarButton *starButton = [[StarButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    starButton.isFavorite = channel.isFavorite;
    [starButton addTarget:self
                   action:@selector(markRSSChannel:)
         forControlEvents:UIControlEventTouchUpInside];
    
    cell.textLabel.text = (channel.link).absoluteString;
    cell.accessoryView = starButton;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        RSSChannel *channel = self.RSSChannels[indexPath.row];
        
        [self.cache removeCacheForKey:[self customKeyForRSSChannel:channel.link]];
        [self.cache removeCacheForKey:[self customKeyForRSSSource:(channel.link).absoluteString]];
        [self.RSSChannels removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (IBAction)addRSSSource:(UIBarButtonItem *)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add RSS source" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        textField.keyboardType = UIKeyboardTypeURL;
        textField.placeholder = @"URL";
    }];
    
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self loadRSSSource:alertController.textFields[0].text];
    }];
    
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:addAction];
    [alertController addAction:closeAction];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

- (void)markRSSChannel:(StarButton*)sender {
    
    if ([sender.superview isKindOfClass:[UITableViewCell class]]) {
        
        UITableViewCell *cell = (UITableViewCell *)sender.superview;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        RSSChannel *channel = self.RSSChannels[indexPath.row];
        sender.isFavorite = !sender.isFavorite;
        channel.isFavorite = sender.isFavorite;
        
        [self.cache setObject:channel forKey:[self customKeyForRSSChannel:channel.link]];
        
        [sender setNeedsDisplay];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ShowNewsSegue"]) {
        
        NewsViewController *newsViewController = segue.destinationViewController;
        newsViewController.RSSChannels = self.RSSChannels;
    }
}

#pragma mark - UIAlerViewDelegate

- (void)loadRSSSource:(NSString *)RSSSource {
    
    if (!RSSSource) return;
    
    __weak typeof(self) weakSelf = self;
    
    NSDictionary *parameters = @{ @"cachePolicy" : @"NSURLRequestReloadIgnoringCacheData" };
    
    [RSSParser parseRSSFeed:RSSSource
                 parameters:parameters
                    success:^(RSSChannel *channel) {
                        
                        channel.link = [NSURL URLWithString:RSSSource];
                        [weakSelf.cache setObject:channel forKey:[weakSelf customKeyForRSSChannel:channel.link]];
                        [weakSelf.cache setString:[weakSelf customKeyForRSSChannel:channel.link]
                                           forKey:[weakSelf customKeyForRSSSource:RSSSource] withTimeoutInterval:DBL_MAX];
                        [weakSelf.RSSChannels addObject:channel];
                        
                        NSIndexPath *indexPathForInsert = [NSIndexPath indexPathForRow:self.RSSChannels.count - 1
                                                                             inSection:0];
                        [weakSelf.tableView insertRowsAtIndexPaths:@[indexPathForInsert]
                                              withRowAnimation:UITableViewRowAnimationAutomatic];
                        
                    } failure:^(NSError *error) {
                        
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"RSS cannot be load" preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
                        
                        [alertController addAction:closeAction];
                        
                        [weakSelf presentViewController:alertController
                                           animated:YES
                                         completion:nil];
                    }];
}
@end
