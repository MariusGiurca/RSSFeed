//
//  ViewController.h
//  FeedSaver
//
//  Created by admin on 02/12/14.
//  Copyright (c) 2014 Radu Pop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedParser.h"

@interface ViewController : UIViewController <FeedParserDelegate, UITableViewDataSource,  UITableViewDelegate> {
    FeedParser* feedParser;
}

@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *itemArray;
@end

