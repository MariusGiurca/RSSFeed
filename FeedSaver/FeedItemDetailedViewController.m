//
//  FeedItemDetailedViewController.m
//  FeedSaver
//
//  Created by admin on 18/12/14.
//  Copyright (c) 2014 Radu Pop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedItemDetailedViewController.h"

typedef enum {
    TitleSection = 0,
    LinkSection,
    DateTimeSection,
    DescriptionSection
}Sections;

@implementation FeedItemDetailedViewController

-(id)initWithStyle:(UITableViewStyle)style {
    if((self = [super initWithStyle:style])) {
        
    }
    return self;
}

-(void) viewDidLoad {
    [super viewDidLoad];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return DescriptionSection + 1;
}




-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"feedDetailsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(self.item) {
        switch(indexPath.row) {
            case TitleSection:
                cell.textLabel.text = [self.item.title length] ? self.item.title : @"No title";
                cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
                cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
                cell.textLabel.numberOfLines = 3;
                break;
            case LinkSection:
                cell.textLabel.text = [self.item.link length] ? self.item.link : @"No link";
                break;
            case DateTimeSection:
                cell.textLabel.text = [self.item.date length] ? self.item.date : @"No date";
                break;
            case DescriptionSection:
                cell.textLabel.text = [self.item.itemDescription length] ? self.item.itemDescription : @"No description";
                cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
                cell.textLabel.numberOfLines = 0;
                break;
            default:
                break;
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionText = @"";
    switch(indexPath.row) {
        case DescriptionSection:
            sectionText = self.item.itemDescription;
            break;
        case TitleSection:
            sectionText = self.item.title;
            break;
    }
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:20]};
    CGRect rect = [sectionText boundingRectWithSize:self.tableView.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    return rect.size.height+20;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == LinkSection) {
        if(self.item.link.length) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.item.link]];
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}


@end
