//
//  TopCommentsViewController.m
//  GooGuu
//
//  Created by Xcode on 14-1-14.
//  Copyright (c) 2014年 Xcode. All rights reserved.
//

#import "TopCommentsViewController.h"
#import "TopCommentCell.h"
#import "RegexKitLite.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface TopCommentsViewController ()

@end

@implementation TopCommentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"精彩评论";
	[self initComponents];
    [self getArticlesInfo];
}

-(void)initComponents {
    
    UITableView *temp = [[[UITableView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT)] autorelease];
    temp.delegate = self;
    temp.dataSource = self;
    temp.showsVerticalScrollIndicator = NO;
    self.commentTable = temp;
    [self.view addSubview:self.commentTable];
    
    UIRefreshControl *tempRefresh = [[[UIRefreshControl alloc] init] autorelease];
    tempRefresh.attributedTitle = [[[NSAttributedString alloc] initWithString:@"下拉刷新"] autorelease];
    [tempRefresh addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = tempRefresh;
    [self.commentTable addSubview:self.refreshControl];
    
}

-(void)handleRefresh:(UIRefreshControl *)control {
    control.attributedTitle = [[[NSAttributedString alloc] initWithString:@"刷新中"] autorelease];
    [control endRefreshing];
    [self performSelector:@selector(loadData) withObject:nil afterDelay:2.0f];
}

-(void)loadData{
    
    [self.refreshControl endRefreshing];
    self.refreshControl.attributedTitle = [[[NSAttributedString alloc] initWithString:@"下拉刷新"] autorelease];
    [self getArticlesInfo];
    
}

#pragma mark -
#pragma NetConection

-(void)getArticlesInfo {
    
    [Utiles getNetInfoWithPath:@"GetTopComments" andParams:nil besidesBlock:^(id obj) {
        
        NSMutableArray *temps = [[[NSMutableArray alloc] init] autorelease];
        for (id model in obj) {
            [temps addObject:model];
        }
        self.commentList = temps;
        [self.commentTable reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}

#pragma mark -
#pragma Table DataSource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *arr = [self.commentList[indexPath.row][@"replycontent"] split:@"<br/>"];
    CGSize size = [Utiles getLabelSizeFromString:arr[0] font:[UIFont fontWithName:@"Heiti SC" size:12.0] width:275];
    
    if ([arr count] > 1) {
        return size.height + 95;
    } else {
       return size.height + 45;
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.commentList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *TopCommentCellIdentifier = @"TopCommentCellIdentifier";
    
    TopCommentCell *cell = (TopCommentCell *)[tableView cellForRowAtIndexPath:indexPath];
                         
    id model = self.commentList[indexPath.row];
    
    if (cell == nil) {
        cell = [[[TopCommentCell alloc]
                 initWithStyle:UITableViewCellStyleSubtitle
                 reuseIdentifier:TopCommentCellIdentifier] autorelease];
    }
    
    NSArray *arr = [model[@"replycontent"] split:@"<br/>"];
    
    cell.content = arr[0];
    cell.userName = model[@"realname"];
    cell.artTitle = [NSString stringWithFormat:@"[%@]%@",model[@"classify"],model[@"title"]];
    cell.updateTime = [Utiles intervalSinceNow:model[@"replytime"]];
    cell.avaURL = model[@"headerpicurl"];
    
    //添加评论缩略图
    if ([arr count] > 1) {
        NSString *regexString  = @"http.*((.gif)|(.jpg)|(.bmp)|(.png)|(.GIF)|(.JPG)|(.PNG)|(.BMP))";
        NSArray  *matchArray  = [[arr JSONString] componentsMatchedByRegex:regexString];
        cell.thumbnailsURL = matchArray;
    }

    return cell;
}



#pragma mark -
#pragma Table Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



-(BOOL)shouldAutorotate{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
