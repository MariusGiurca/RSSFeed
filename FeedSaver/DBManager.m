//
//  DBManager.m
//  DownloadRSS
//
//  Created by Marius Giurca on 12/8/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "DBManager.h"
#include "FeedItem.h"


@implementation DBManager

static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;


+(DBManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}

-(BOOL)createDB{
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"rss.db"]];
    
    NSLog(@"databasePath = %@",databasePath);
    
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt ="create table if not exists items (link text primary key, title text, decription text, pubDate datetime)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}
-(BOOL) saveData:(NSString*)link title:(NSString*)title
      decription:(NSString*)decription pubDate:(NSString*)pubDate
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into items (link,title, decription, pubDate) values (\"%@\",\"%@\", \"%@\", \"%@\")",link,title, decription , pubDate];
        
       //NSLog(@"insertSQL = %@",insertSQL);
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        
        int retVal = sqlite3_step(statement);
        if (retVal == SQLITE_DONE)
        {
            return YES;
        }
        else {
            //NSLog(@"%s: step error: %s (%d)", __FUNCTION__, sqlite3_errmsg(database), retVal);
            return NO;
        }
        //sqlite3_reset(statement);
    }
    return NO;
}

-(BOOL)readDBEntries:(NSMutableArray*)feedItems {
    const char *dbPath = [databasePath UTF8String];
    if(sqlite3_open(dbPath, &database) == SQLITE_OK) {
        NSString *selectSQL = @"SELECT link,title,decription,pubDate FROM items ORDER BY pubDate DESC";
        const char* select_stmt = [selectSQL UTF8String];
        sqlite3_prepare_v2(database, select_stmt, -1, &statement, NULL);
        
        int i = 0;
        while(sqlite3_step(statement) == SQLITE_ROW) {
            FeedItem *item = [[FeedItem alloc] init];
            char *link = (char *) sqlite3_column_text(statement, 0);
            item.link = [[NSString alloc] initWithUTF8String:link];
            char *title = (char *) sqlite3_column_text(statement, 1);
            item.title = [[NSString alloc] initWithUTF8String:title];
            char *description = (char *) sqlite3_column_text(statement, 2);
            item.itemDescription = [[NSString alloc] initWithUTF8String:description];
            char *date = (char *) sqlite3_column_text(statement, 3);
            item.date = [[NSString alloc] initWithUTF8String:date];
            [feedItems insertObject:item atIndex:i++];
        }
        return  YES;
    }
    else {
        return NO;
    }
    
}


@end
