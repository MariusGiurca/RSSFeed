//
//  FeedParser.h
//  FeedSaver
//
//  Created by admin on 02/12/14.
//  Copyright (c) 2014 Radu Pop. All rights reserved.
//
#import "FeedItem.h"
#import "FeedParser.h"

@class FeedParser;

//Error codes
#define FeedParserErrorDomain @"FeedParser"
typedef enum {
    ConnectionFailed = 0,
    FeedParsingError,
    UnknownError
} FeedParserErrorCode;

@protocol FeedParserDelegate <NSObject>
@optional
-(void)feedParserDidStart:(FeedParser *)parser;
-(void)feedParser:(FeedParser *)parser didParseFeedItem:(FeedItem *)item;
-(void)feedParserDidFinish:(FeedParser *)parser;
-(void)feedParser:(FeedParser *)parser didFailWithError:(NSError *)error;
@end

@interface FeedParser : NSObject <NSXMLParserDelegate> {
    NSDateFormatter *dateFormatter;
}

@property (weak,nonatomic) id <FeedParserDelegate> delegate;
@property (strong, nonatomic) NSURL *url;
@property (strong,nonatomic) NSURLConnection *urlConnection;
@property (strong,nonatomic) NSMutableURLRequest *request;
@property (strong,nonatomic) NSXMLParser *XMLParser;
@property (strong,nonatomic) NSString *currentPath;
@property (strong,nonatomic) NSMutableString* currentText;
@property (strong,nonatomic) FeedItem *currentItem;
@property (nonatomic) BOOL hasEncounteredItems;
@property (strong,nonatomic) NSMutableData *asyncData;//TODO: async needed?

-(instancetype)initWithURL:(NSURL *)feedURL;
-(void)reset;
-(BOOL)parse;

@end