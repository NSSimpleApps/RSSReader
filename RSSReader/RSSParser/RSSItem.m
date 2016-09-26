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

#import "RSSItem.h"

@implementation RSSItem

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    
    if (self) {
        
        _title = [aDecoder decodeObjectForKey:@"title"];
        _link = [aDecoder decodeObjectForKey:@"link"];
        _itemDescription = [aDecoder decodeObjectForKey:@"itemDescription"];
        _authorEmail = [aDecoder decodeObjectForKey:@"authorEmail"];
        _commentsURL = [aDecoder decodeObjectForKey:@"commentsURL"];
        _guid = [aDecoder decodeObjectForKey:@"guid"];
        _pubDate = [aDecoder decodeObjectForKey:@"pubDate"];
        _imageURL = [aDecoder decodeObjectForKey:@"imageURL"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.link forKey:@"link"];
    [aCoder encodeObject:self.itemDescription forKey:@"itemDescription"];
    [aCoder encodeObject:self.authorEmail forKey:@"authorEmail"];
    [aCoder encodeObject:self.commentsURL forKey:@"commentsLink"];
    [aCoder encodeObject:self.guid forKey:@"guid"];
    [aCoder encodeObject:self.pubDate forKey:@"pubDate"];
    [aCoder encodeObject:self.imageURL forKey:@"imageURL"];
}

#pragma mark - NSObject Protocol

- (BOOL)isEqual:(RSSItem *)object
{
    return [object isKindOfClass:[self class]] &&
    [object.link.absoluteString isEqualToString:self.link.absoluteString];
}

- (NSUInteger)hash
{
    return (self.link.absoluteString).hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@>", [self class],
            [self.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

@end
