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

#import <Foundation/Foundation.h>

/**
 *  `RSSItem` corresponds to a single `item` or `entry` element within an RSS feed.
 *
 *  Many properties on `RSSItem` are from the RSS 2.0 specification, see http://cyber.law.harvard.edu/rss/rss.html for reference, and some are from the Media RSS 1.5.1 specification, see http://www.rssboard.org/media-rss for reference,  which is a namespace extension to the RSS 2.0 specification.
 *
 *  Per the RSS 2.0 specification, "an item may represent a "story" -- much like a story in a newspaper or magazine; if so its description is a synopsis of the story, and the link points to the full story. An item may also be complete in itself, if so, the description contains the text (entity-encoded HTML is allowed), and the link and title may be omitted. All elements of an item are optional, however at least one of title or description must be present."
 */
@interface RSSItem : NSObject <NSCoding>

#pragma mark - RSS 2.0
///---------------------
/// @name RSS 2.0
///---------------------

/**
 *  This property corresponds to the `title` element within an `item` element.
 *
 *  Per RSS 2.0 specification, it is the "title of the item."
 */
@property (nonatomic, copy) NSString *title;

/**
 *  This property corresponds to the `link` element within an `item` element.
 *
 *  Per RSS 2.0 specification, it is the "URL of the item," e.g. to the HTML web page for the item.
 */
@property (nonatomic, copy) NSURL *link;

/**
 *  This property corresponds to the `description` element within an `item`.
 *
 *  Per RSS 2.0 specification, it is the "item synopsis."
 */
@property (nonatomic, copy) NSString *itemDescription;

/**
 *  This property corresponds to the `author` element within an `item` element.
 *
 *  Per RSS 2.0 specification, it is the "email address of the author of the item."
 */
@property (nonatomic, copy) NSString *authorEmail;

/**
 *  This property corresponds to the `comments` element within an `item` element.
 *
 *  Per RSS 2.0 specification, it is the "URL of a page for comments relating to the item."
 */
@property (nonatomic, copy) NSURL *commentsURL;

/**
 *  This property corresponds to the `guid` element within an `item` element.
 *
 *  Per RSS 2.0 specification, it is "a string that uniquely identifies the item."
 */
@property (nonatomic, copy) NSString *guid;

/**
 *  This property corresponds to the `pubDate` element within an `item` element.
 *
 *  Per RSS 2.0 specification, it "indicates when the item was published."
 *
 *  The date format is expected to be `EEE, dd MMM yyyy HH:mm:ss Z`.
 */
@property (nonatomic, copy) NSString *pubDate;

/**
 *  This property corresponds to the `enclosure` element within an `item` element.
 */
@property (nonatomic, copy) NSURL *imageURL;

@end