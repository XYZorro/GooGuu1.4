//
//  TopComsViewController.m
//  GooGuu
//
//  Created by Xcode on 14-1-14.
//  Copyright (c) 2014年 Xcode. All rights reserved.
//

#import "TopComsViewController.h"
#import "TopComCell.h"

@interface TopComsViewController ()

@end

@implementation TopComsViewController

- (id)initWithTopical:(NSString *)topical type:(TopPoints)type
{
    self = [super init];
    if (self) {
        self.topical = topical;
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.topical;
	[self initComponents];
    [self getComsInfo];
}

-(void)initComponents {
    
    UITableView *temp = [[[UITableView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT)] autorelease];
    temp.delegate = self;
    temp.dataSource = self;
    temp.showsVerticalScrollIndicator = NO;
    self.comTable = temp;
    [self.view addSubview:self.comTable];
    
    UIRefreshControl *tempRefresh = [[[UIRefreshControl alloc] init] autorelease];
    tempRefresh.attributedTitle = [[[NSAttributedString alloc] initWithString:@"下拉刷新"] autorelease];
    [tempRefresh addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = tempRefresh;
    [self.comTable addSubview:self.refreshControl];
    
}

-(void)handleRefresh:(UIRefreshControl *)control {
    control.attributedTitle = [[[NSAttributedString alloc] initWithString:@"刷新中"] autorelease];
    [control endRefreshing];
    [self performSelector:@selector(loadData) withObject:nil afterDelay:2.0f];
}

-(void)loadData{
    
    [self.refreshControl endRefreshing];
    self.refreshControl.attributedTitle = [[[NSAttributedString alloc] initWithString:@"下拉刷新"] autorelease];
    [self getComsInfo];
    
}

#pragma mark -
#pragma NetConection

-(void)getComsInfo {
    
    NSString *url = @"";
    if (self.type == TopCompany) {
        url = @"GetTopCompanys";
    } else if (self.type == RiseSpace) {
        url = @"RiseSpace";
    } else if (self.type == FallSpace) {
        url = @"FallSpace";
    }
    
    [Utiles getNetInfoWithPath:url andParams:nil besidesBlock:^(id obj) {
        
        NSMutableArray *temps = [[[NSMutableArray alloc] init] autorelease];
        for (id model in obj) {
            [temps addObject:model];
        }
        self.comList = temps;
        [self.comTable reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    NSDictionary *params = @{
                             @"token":[Utiles getUserToken],
                             @"from":@"googuu",
                             @"state":@"1"
                             };
    
    [Utiles getNetInfoWithPath:@"AttentionData" andParams:params besidesBlock:^(id obj) {
        
        NSMutableArray *codes = [[[NSMutableArray alloc] init] autorelease];
        id data = obj[@"data"];
        for (id model in data) {
            [codes addObject:model[@"stockcode"]];
        }
        self.attentionCodes = codes;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
    
}

-(BOOL)isAttention:(NSString *)stockCode {
    return [self.attentionCodes containsObject:stockCode];
}

-(void)attentionBtClicked:(UIButton *)bt {
    
    NSDictionary *params = @{
                             @"stockcode":self.comList[bt.tag][@"stockcode"],
                             @"token":[Utiles getUserToken],
                             @"from":@"googuu",
                             @"state":@"1"
                             };
   
    if ([bt.titleLabel.text isEqualToString:@"添加关注"]) {
        
        [Utiles postNetInfoWithPath:@"AddAttention" andParams:params besidesBlock:^(id obj) {
            
            if ([obj[@"status"] isEqualToString:@"1"]) {
                
                [bt setTitle:@"取消关注" forState:UIControlStateNormal];
                [self.attentionCodes addObject:self.comList[bt.tag][@"stockcode"]];
                
            } else {
                [Utiles showToastView:self.view withTitle:nil andContent:obj[@"msg"] duration:1.0];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
        }];
        
    } else {
        
        [Utiles postNetInfoWithPath:@"DeleteAttention" andParams:params besidesBlock:^(id obj) {
            
            if ([obj[@"status"] isEqualToString:@"1"]) {
                
                [bt setTitle:@"添加关注" forState:UIControlStateNormal];
                [self.attentionCodes removeObject:self.comList[bt.tag][@"stockcode"]];
                
            } else {
                [Utiles showToastView:self.view withTitle:nil andContent:obj[@"msg"] duration:1.0];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
        }];
        
    }
    
}

#pragma mark -
#pragma Table DataSource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.comList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *TopComCellIdentifier = @"TopComCellIdentifier";
    
    TopComCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             TopComCellIdentifier];
    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"TopComCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
        
        [cell.attentionBt addTarget:self action:@selector(attentionBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    id model = self.comList[indexPath.row];
    float marketPrice = [model[@"marketprice"] floatValue];
    float percent = 0;
    cell.comNameLabel.text = model[@"companyname"];
    cell.marketPriLable.text = [NSString stringWithFormat:@"%.2f",marketPrice];
    cell.attentionBt.tag = indexPath.row;
    if ([self isAttention:model[@"stockcode"]]) {
        [cell.attentionBt setTitle:@"取消关注" forState:UIControlStateNormal];
    } else {
        [cell.attentionBt setTitle:@"添加关注" forState:UIControlStateNormal];
    }
    
    if (self.type == TopCompany) {
        
        float ggPrice = [model[@"googuuprice"] floatValue];

        cell.marketLabel.text = [NSString stringWithFormat:@"%@.%@",model[@"stockcode"],model[@"market"]];
        cell.googuuPriLable.text = [NSString stringWithFormat:@"%.2f",ggPrice];
        percent = (ggPrice - marketPrice) / marketPrice;
        
    } else {
        
        float ggPrice = [model[@"analystprice"] floatValue];
        cell.marketLabel.text = [NSString stringWithFormat:@"%@.%@",model[@"stockcode"],model[@"marketname"]];
        cell.googuuPriLable.text = [NSString stringWithFormat:@"%.2f",ggPrice];
        percent = (ggPrice - marketPrice) / marketPrice;

    }
    cell.percentLable.text = [NSString stringWithFormat:@"%.0f%%",percent*100];
    if (percent > 0) {
        cell.indicatorImg.image = [UIImage imageNamed:@"stockUpArrow"];
    } else {
        cell.indicatorImg.image = [UIImage imageNamed:@"stockDownArrow"];
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
}

@end
