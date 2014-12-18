//
//  FeedItem.h
//  FeedSaver
//
//  Created by admin on 03/12/14.
//  Copyright (c) 2014 Radu Pop. All rights reserved.
//

@interface FeedItem : NSObject

@property (nonatomic,copy) NSString* title;
@property (nonatomic,copy) NSString* link;
@property (nonatomic,copy) NSString* itemDescription;
@property (nonatomic,copy) NSString* date;//using date value as string beacause sqlite3 lib only reads string from DB

@end
