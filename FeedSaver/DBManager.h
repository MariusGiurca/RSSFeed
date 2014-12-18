//
//  DBManager.h
//  DownloadRSS
//
//  Created by Marius Giurca on 12/8/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBManager : NSObject

{
    NSString *databasePath;
}

+(DBManager*)getSharedInstance;

-(BOOL)createDB;
-(BOOL) saveData:(NSString*)link title:(NSString*)title
      decription:(NSString*)decription pubDate:(NSString*)pubDate;
-(BOOL) readDBEntries:(NSMutableArray*)feedItems;
@end
