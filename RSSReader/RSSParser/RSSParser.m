//
//  RSSChannel.m
//  MediaRSSParser
//
//  Created by Joshua Greene on 5/25/14.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "RSSParser.h"
#import "RSSParser_Protected.h"

#import "AFURLResponseSerialization.h"
#import "AFHTTPSessionManager.h"

@interface RSSParser()

@end

@implementation RSSParser

#pragma mark - Object Lifecycle

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _client = [[AFHTTPSessionManager alloc] init];
        
        _client.responseSerializer = [[AFXMLParserResponseSerializer alloc] init];
        _client.responseSerializer.acceptableContentTypes  = [NSSet setWithObjects:@"application/xml",
                                                              @"text/xml",
                                                              @"application/rss+xml",
                                                              @"application/atom+xml",
                                                              nil];
    }
    return self;
}

#pragma mark - Cancel

- (void)cancel
{
    [self cancelAllTasks];
    [self.xmlParser abortParsing];
    [self nilSuccessAndFailureBlocks];
}

- (void)cancelAllTasks
{
    for (NSURLSessionTask *task in self.client.tasks) {
        [task cancel];
    }
}

- (void)nilSuccessAndFailureBlocks
{
    [self setSuccessBlock:nil];
    [self setFailblock:nil];
}

#pragma mark - Starting Parser

+ (RSSParser *)parseRSSFeed:(NSString *)urlString
                 parameters:(NSDictionary *)parameters
                    success:(void (^)(RSSChannel *channel))success
                    failure:(void (^)(NSError *error))failure
{
    RSSParser *parser = [[RSSParser alloc] init];
    [parser parseRSSFeed:urlString parameters:parameters success:success failure:failure];
    return parser;
}

- (void)parseRSSFeed:(NSString *)urlString
          parameters:(NSDictionary *)parameters
             success:(void (^)(RSSChannel *channel))success
             failure:(void (^)(NSError *error))failure
{
    [self cancel];
    self.successBlock = success;
    self.failblock = failure;
    
    [self.client GET:urlString
          parameters:parameters
            progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 
                 [self GETSucceeded:responseObject];
                 
             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 
                 if (failure) {
                     failure(error);
                 }
                 [self nilSuccessAndFailureBlocks];
             }];
}

- (void)GETSucceeded:(NSXMLParser *)responseObject
{
    self.xmlParser = responseObject;
    (self.xmlParser).delegate = self;
    [self.xmlParser parse];
}

#pragma mark - NSXMLParserDelegate - Error Handling

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [parser abortParsing];
    
    if (self.failblock) {
        self.failblock(parseError);
    }
    
    [self nilSuccessAndFailureBlocks];
}

#pragma mark - NSXMLParserDelegate - Document Start

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.channel = [[RSSChannel alloc] init];
    self.items = [[NSMutableArray alloc] init];
}

#pragma mark - NSXMLParserDelegate - Found Characters

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [self.tempString appendString:string];
}

#pragma mark - NSXMLParserDelegate - Document End

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [self setChannelProperties];
    [self nilTemporaryProperties];
    [self dispatchSuccess];
}

- (void)setChannelProperties
{
    self.channel.items = self.items;
}

- (void)nilTemporaryProperties
{
    self.currentItem = nil;
    self.items = nil;
    self.tempString = nil;
}

- (void)dispatchSuccess
{
    if (self.successBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.successBlock(self.channel);
            [self nilSuccessAndFailureBlocks];
        });
    }
}

#pragma mark - NSXMLParserDelegate - Element Start

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict
{
    if ([self matchesItemElement:elementName]) {
        
        self.currentItem = [[RSSItem alloc] init];
    } else if ([self hasCurrentItem] && [self matchesEnclosureElement:elementName]) {
        
        NSString *typeOfElement = attributeDict[@"type"];
        if ([typeOfElement hasPrefix:@"image"]) {
            
            NSString *imageURL = attributeDict[@"url"];
            (self.currentItem).imageURL = [NSURL URLWithString:imageURL];
        }
    }
    self.tempString = [[NSMutableString alloc] init];
}

#pragma mark - Start Matchers

- (BOOL)matchesItemElement:(NSString *)elementName
{
    return [elementName isEqualToString:@"item"] || [elementName isEqualToString:@"entry"];
}

#pragma mark - NSXMLParserDelegate - Element End

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([self matchesItemElement:elementName]) {
        [self endCurrentItem];
        
    } else if ([self hasTempString] == NO) {
        return;
        
    } else if ([self hasCurrentItem] == NO) {
        
        if ([self matchesTitleElement:elementName]) {
            (self.channel).title = self.tempString;
            
        } else if ([self matchesLinkElement:elementName]) {
            
            (self.channel).link = [self urlFromTempString];
            
        } else if ([self matchesDescriptionElement:elementName]) {
            (self.channel).channelDescription = self.tempString;
            
        } else if ([self matchesLanguageElement:elementName]) {
            (self.channel).language = self.tempString;
            
        } else if ([self matchesCopyrightElement:elementName]) {
            (self.channel).copyright = self.tempString;
            
        } else if ([self matchesManagingEditorElement:elementName]) {
            (self.channel).managingEditorEmail = self.tempString;
            
        } else if ([self matchesWebMasterElement:elementName]) {
            (self.channel).webMasterEmail = self.tempString;
            
        } else if ([self matchesPubDateElement:elementName]) {
            
            (self.channel).pubDate = self.tempString;
            
        } else if ([self matchesLastBuildDate:elementName]) {
            
            (self.channel).lastBuildDate = self.tempString;
            
        } else if ([self matchesGeneratorElement:elementName]) {
            (self.channel).generator = self.tempString;
            
        } else if ([self matchesDocsElement:elementName]) {
            (self.channel).docsURL = [self urlFromTempString];
            
        } else if ([self matchesTTLElement:elementName]) {
            (self.channel).ttl = [self integerFromTempString];
            
        }
        
    } else {
        
        if ([self matchesTitleElement:elementName]) {
            (self.currentItem).title = self.tempString;
            
        } else if ([self matchesLinkElement:elementName]) {
            (self.currentItem).link = [self urlFromTempString];
            
        } else if ([self matchesDescriptionElement:elementName]) {
            (self.currentItem).itemDescription = self.tempString;
            
        } else if ([self matchesAuthorElement:elementName]) {
            (self.currentItem).authorEmail = self.tempString;
            
        } else if ([self matchesCommentsElement:elementName]) {
            (self.currentItem).commentsURL = [self urlFromTempString];
            
        } else if ([self matchesGuidElement:elementName]) {
            (self.currentItem).guid = self.tempString;
            
        } else if ([self matchesPubDateElement:elementName]) {
            
            self.currentItem.pubDate = self.tempString;
        }
    }
}

- (BOOL)hasTempString
{
    return self.tempString.length > 0;
}

- (BOOL)hasCurrentItem
{
    return self.currentItem != nil;
}

- (void)endCurrentItem
{
    [self.items addObject:self.currentItem];
}

- (NSURL *)urlFromTempString
{
    return [NSURL URLWithString:self.tempString];
}

- (NSInteger)integerFromTempString
{
    return (self.tempString).integerValue;
}

#pragma mark - End Matchers

- (BOOL)matchesEnclosureElement:(NSString *)elementName
{
    return [elementName isEqualToString:@"enclosure"];
}

- (BOOL)matchesTitleElement:(NSString *)elementName
{
    return [elementName isEqualToString:@"title"];
}

- (BOOL)matchesLinkElement:(NSString *)elementName
{
    return [elementName isEqualToString:@"link"];
}

- (BOOL)matchesDescriptionElement:(NSString *)elementName
{
    return [elementName isEqualToString:@"description"];
}

- (BOOL)matchesLanguageElement:(NSString *)elementName
{
    return [elementName isEqualToString:@"language"];
}

- (BOOL)matchesCopyrightElement:(NSString *)elementName
{
    return [elementName isEqualToString:@"copyright"];
}

- (BOOL)matchesManagingEditorElement:(NSString *)elementName
{
    return [elementName isEqualToString:@"managingEditor"];
}

- (BOOL)matchesWebMasterElement:(NSString *)elementName
{
    return [elementName isEqualToString:@"webMaster"];
}

- (BOOL)matchesPubDateElement:(NSString *)elementName
{
    return [elementName isEqualToString:@"pubDate"];
}

- (BOOL)matchesLastBuildDate:(NSString *)elementName
{
    return [elementName isEqualToString:@"lastBuildDate"];
}

- (BOOL)matchesGeneratorElement:(NSString *)elementName
{
    return [elementName isEqualToString:@"generator"];
}

- (BOOL)matchesDocsElement:(NSString *)elementName
{
    return [elementName isEqualToString:@"docs"];
}

- (BOOL)matchesTTLElement:(NSString *)elementName
{
    return [elementName isEqualToString:@"ttl"];
}

- (BOOL)matchesAuthorElement:(NSString *)elementName
{
    return [elementName isEqualToString:@"author"];
}

- (BOOL)matchesCommentsElement:(NSString *)elementName
{
    return [elementName isEqualToString:@"comments"];
}

- (BOOL)matchesGuidElement:(NSString *)elementName
{
    return [elementName isEqualToString:@"guid"];
}

@end
