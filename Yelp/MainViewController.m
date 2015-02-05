//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "BusinessCell.h"
#import "FiltersViewController.h"

NSString * const kYelpConsumerKey = @"a8ApPQST3Qp-T399mnVUOw";
NSString * const kYelpConsumerSecret = @"9uZNRNXiN4-iEs8hynxXgdGfWJ4";
NSString * const kYelpToken = @"ZKRkWnEBhfYN03BfJxIgGB7qn0ERm3bh";
NSString * const kYelpTokenSecret = @"fUb1f-8ioqFAsL2DpPgNTzfBLZM";

NSString *defaultTerm = @"Restaurants";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSArray *businesses;
@property (nonatomic, strong) BusinessCell *prototypeBusinessCell;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSString *searchTerm;

- (void)fetchBusinessWithQuery:(NSString *)query params:(NSDictionary *)params;
- (void)searchBusinessData;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        [self fetchBusinessWithQuery:defaultTerm params:nil];
    
        // navigation bar appearance
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:200.0/255 green:11.0/255 blue:5.0/255 alpha:1.0]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    
    self.searchBar = [[UISearchBar alloc] init];
    [self.searchBar sizeToFit];
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    cell.business = self.businesses[indexPath.row];
    
    return cell;
}

- (BusinessCell *)prototypeBusinessCell {
    if (_prototypeBusinessCell == nil ) {
        _prototypeBusinessCell = [self.tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    }
    
    return _prototypeBusinessCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.prototypeBusinessCell.business = self.businesses[indexPath.row];
    CGSize size = [self.prototypeBusinessCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return size.height + 1;
}

#pragma mark - Filter delegate methods

- (void)filtersViewController:(FiltersViewController *)filterViewController didChangeFilters:(NSDictionary *)filters {
    [self fetchBusinessWithQuery:defaultTerm params:filters];
}

#pragma mark - Private methods

- (void)onFilterButton {
    FiltersViewController *vc = [[FiltersViewController alloc] init];
    vc.delegate = self;
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)fetchBusinessWithQuery:(NSString *)query params:(NSDictionary *)params {
    
    [self.client searchWithTerm:query params:params success:^(AFHTTPRequestOperation *operation, id response) {
        
        NSArray *businessDict = response[@"businesses"];
        self.businesses = [Business businessesWithDictionaries:businessDict];
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];
}

#pragma mark - SearchBar methods

- (void)searchBusinessData {
    [self fetchBusinessWithQuery:self.searchTerm params:nil];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    self.searchTerm = nil;
    
    if ([self.searchBar.text length] == 0) {
        self.searchTerm = defaultTerm;
    } else {
        self.searchTerm = self.searchBar.text;
    }

    [self searchBusinessData];
}

@end
