//
//  ViewController.m
//  FeedSaver
//
//  Created by admin on 02/12/14.
//  Copyright (c) 2014 Radu Pop. All rights reserved.
//

#import "ViewController.h"
#import "DBManager.h"
#import "FeedItem.h"
#import "FeedItemDetailedViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[DBManager getSharedInstance] createDB];
    
    NSURL *feedURL = [NSURL URLWithString:@"http://feeds.gpupdate.net/en/rss.xml"];
    feedParser = [[FeedParser alloc] initWithURL:feedURL];
    feedParser.delegate = self;
    [feedParser parse];
    feedURL = [NSURL URLWithString:@"http://techcrunch.com/feed"];
    feedParser = [[FeedParser alloc] initWithURL:feedURL];
    feedParser.delegate = self;
    [feedParser parse];
    feedURL = [NSURL URLWithString:@"http://rss.realitatea.net/stiri.xml"];
    feedParser = [[FeedParser alloc] initWithURL:feedURL];
    feedParser.delegate = self;
    [feedParser parse];
    
    CGRect tableFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    self.tableView = [[UITableView alloc] initWithFrame:tableFrame style: UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.itemArray = [[NSMutableArray alloc] init];
    [[DBManager getSharedInstance] readDBEntries:self.itemArray];
    
}

-(void)updateTable {
    [[DBManager getSharedInstance] readDBEntries:self.itemArray];
    self.tableView.userInteractionEnabled = YES;
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark Feed Parser delegate
-(void)feedParserDidStart:(FeedParser *)parser {
    NSLog(@"started parsing url %@",[feedParser.url absoluteString]);
}

-(void)feedParser:(FeedParser *)parser didParseFeedItem:(FeedItem *)item {
    [[DBManager getSharedInstance] saveData:item.link title:item.title decription:item.itemDescription pubDate:item.date];
}

-(void)feedParserDidFinish:(FeedParser *)parser {
    NSLog(@"done parsing url %@",[feedParser.url absoluteString]);
    [self updateTable];
}

-(void)feedParser:(FeedParser *)parser didFailWithError:(NSError *)error {
    NSLog(@"encountered error %@",error);
}

#pragma mark -
#pragma mark table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"feedTitleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"feedTitleCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    cell.backgroundColor = [UIColor clearColor];

    FeedItem *item =  [self.itemArray objectAtIndex:indexPath.row];
    if (item) {
        cell.textLabel.text = item.title ? item.title : @"No Title";
    }
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedItem *item =  [self.itemArray objectAtIndex:indexPath.row];
    FeedItemDetailedViewController *detailedViewController = [[FeedItemDetailedViewController alloc]initWithStyle:UITableViewStyleGrouped];
    detailedViewController.item = item;
    [self.navigationController pushViewController:detailedViewController animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
