//
//  FeedParser.m
//  FeedSaver
//
//  Created by admin on 02/12/14.
//  Copyright (c) 2014 Radu Pop. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "FeedParser.h"

@implementation  FeedParser

-(instancetype)initWithURL:(NSURL *)feedURL {
    if(self == [self init]) {
        [self reset];
        self.url = feedURL;
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:feedURL
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                                timeoutInterval:60];
        self.request = req;
        feedDateFormatter = [[NSDateFormatter alloc] init];
        [feedDateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss Z"];
        
        removeWeekdayFormatter = [[NSDateFormatter alloc] init];
        [removeWeekdayFormatter setDateFormat:@"d MMM yyyy HH:mm:ss Z"];
    }
    return self;
}

-(void)reset {
    self.currentPath = @"/";
    self.currentText = [[NSMutableString alloc] init];
    self.hasEncounteredItems = NO;
}

-(BOOL)parse {
    
    self.urlConnection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    if (self.urlConnection) {
        self.asyncData = [[NSMutableData alloc] init];
    }
    else {
        //inform delegate
        if([self.delegate respondsToSelector:@selector(feedParser:didFailWithError:)]) {
            NSError *error = [NSError errorWithDomain:FeedParserErrorDomain
                                                 code:ConnectionFailed
                                             userInfo:[NSDictionary dictionaryWithObject:@"Connection failed" forKey:NSLocalizedDescriptionKey]];
            [self.delegate feedParser:self didFailWithError:error];
        }
    }
    
    return YES;
}

#pragma mark NSURLConnectionDataDelegate
-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data {
    [self.asyncData appendData:data];
}

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
    [self.asyncData setLength:0];
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection {
    if(self.asyncData.length) {
        NSLog(@"Read %lu bytes of data", self.asyncData.length);
        NSXMLParser *newXMLParser = [[NSXMLParser alloc] initWithData:self.asyncData];
        self.XMLParser = newXMLParser;
        self.XMLParser.shouldProcessNamespaces = YES;
        self.XMLParser.delegate = self;
        [self.XMLParser parse];
    }
    
}

-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError *)error {
    [self.delegate feedParser:self didFailWithError:error];
}


#pragma mark NSXMLParserDelegate
-(void)parserDidStartDocument:(NSXMLParser *)parser {
    //inform delegate
    if([self.delegate respondsToSelector:@selector(feedParserDidStart:)]) {
        [self.delegate feedParserDidStart:self];
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    //inform delegate
    if([self.delegate respondsToSelector:@selector(feedParserDidFinish:)]) {
        [self.delegate feedParserDidFinish:self];
        [self reset];
    }
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    //abort parsing
    [self.XMLParser abortParsing];
    [self reset];
    //inform delegate
    if ([self.delegate respondsToSelector:@selector(feedParser:didFailWithError:)])
        [self.delegate feedParser:self didFailWithError:parseError];
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
    //NSLog(@"XMLParser: found CDATA (%lu bytes)", CDATABlock.length);
    
    //we just ignore CDATA for now
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    
    [self.currentText setString:@""];
    self.currentPath = [self.currentPath stringByAppendingPathComponent:qualifiedName];
   // NSLog(@"Started %@", self.currentPath);
    
    if([self.currentPath isEqualToString:@"/rss/channel/item"]) {
        //found an item
        FeedItem *newItem = [[FeedItem alloc] init];
        self.currentItem = newItem;
    }

    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //NSLog(@"Ended %@", self.currentPath);
    
    BOOL processed = NO;
    if([self.currentPath isEqualToString:@"/rss/channel/item/title"]) {
        self.currentItem.title = self.currentText;
        processed = YES;
        //NSLog(@"Title: %@", self.currentItem.title);
    }
    else if([self.currentPath isEqualToString:@"/rss/channel/item/link"]) {
        self.currentItem.link =  self.currentText;
        //NSLog(@"link: %@",self.currentItem.link);
    }
    else if([self.currentPath isEqualToString:@"/rss/channel/item/pubDate"]) {
        //convert from format found in feed to format needed by sqlite
        NSDate *tmpDate = [feedDateFormatter dateFromString:self.currentText];
        self.currentItem.date = [removeWeekdayFormatter stringFromDate:tmpDate];
        processed = YES;
        //NSLog(@"date:%@",self.currentItem.date);
    }
    else if ([self.currentPath isEqualToString:@"/rss/channel/item/description"]) {
        self.currentItem.itemDescription = [FeedParser escapeQuotes:self.currentText];
        processed = YES;
        //NSLog(@"description: %@", self.currentItem.itemDescription);
    }
    self.currentPath = [self.currentPath stringByDeletingLastPathComponent];
    
    if(!processed && [qName isEqualToString:@"item"]) {
        // Inform delegate
        if ([self.delegate respondsToSelector:@selector(feedParser:didParseFeedItem:)])
            [self.delegate feedParser:self didParseFeedItem:self.currentItem];
        self.currentItem = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    //NSLog(@"foundCharacters: %@", string);
    [self.currentText appendString:string];
}

#pragma mark HTML utility methods
+(NSString*)escapeQuotes:(NSString*)HTMLString {
    NSString *newString = [HTMLString stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    return newString;
}

@end
