//
//  FiltersViewController.m
//  Yelp
//
//  Created by Austin Oh on 1/28/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchCell.h"

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate>

@property (nonatomic, readonly) NSDictionary *filters;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *sectionTitles;

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic) NSInteger selectedCategory;

@property (nonatomic) BOOL deal;
@property (nonatomic, strong) NSArray *distances;
@property (nonatomic) NSInteger selectedDistance;

@property (nonatomic, strong) NSArray *sorts;
@property (nonatomic) NSInteger selectedSort;

@property (nonatomic, retain) NSArray *categoryFilters;
@property (nonatomic, strong) NSMutableSet *selectedCategories;


- (void)initDistances;
- (void)initSortBy;
- (void)initCategories;
- (void)initCategoryFilters;

@end

@implementation FiltersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.sectionTitles = @[@"Most Popular", @"Distance", @"Sort By", @"Category", @"Category Filters"];
        self.deal = NO;
        self.selectedSort = -1;
        [self initSortBy];
        
        self.selectedDistance = -1;
        [self initDistances];
        
        self.selectedCategory = 0;
        [self initCategories];
        
        self.selectedCategories = [NSMutableSet set];
        [self initCategoryFilters];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(onSearchButton)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationItem.title = @"Filters";
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SwitchCell deleage methods

- (void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (indexPath.section == 0) { // deals
        self.deal = value;
    } else if (indexPath.section == 1) { // distance
        if (value) {
            self.selectedDistance = indexPath.row;
        } else {
            self.selectedDistance = -1;
        }
    } else if (indexPath.section == 2) { // sort by
        if (value) {
            self.selectedSort = indexPath.row;
        } else {
            self.selectedSort = -1;
        }
    } else if (indexPath.section == 3) { // categories
        if (value) {
            self.selectedCategory = indexPath.row;
        } else {
            self.selectedCategory = 0;
        }
        [self.selectedCategories removeAllObjects];
        [self.tableView reloadData];
    } else if (indexPath.section == 4) { // category filters
        
        NSArray *categoryFilterArray = self.categoryFilters[self.selectedCategory];
        if (value) {
            [self.selectedCategories addObject:categoryFilterArray[indexPath.row]];
        } else {
            [self.selectedCategories removeObject:categoryFilterArray[indexPath.row]];
        }
        
    }
}

#pragma mark - TableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitles.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionTitles[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: // Most Popular - deals
            return 1;
        case 1: // Distance
            return self.distances.count;
        case 2: // Sort by
            return self.sorts.count;
        case 3: // Category
            return self.categories.count;
        case 4: // Category Filters
            return [self.categoryFilters[self.selectedCategory] count];
        default:
            return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
    
    switch (indexPath.section) {
        case 0: { // deals
            cell.titleLabel.text = @"Offering a Deal";
            [cell setOn:self.deal animated:YES];
            break;
        }
        case 1: { // Distance
            cell.titleLabel.text = self.distances[indexPath.row][@"name"];
            [cell setOn:(self.selectedDistance == indexPath.row ? YES : NO) animated:YES];
            break;
        }
        case 2: { // Sort by
            cell.titleLabel.text = self.sorts[indexPath.row][@"name"];
            [cell setOn:(self.selectedSort == indexPath.row ? YES : NO) animated:YES];
            break;
        }
        case 3: { // Categories
            cell.titleLabel.text = self.categories[indexPath.row][@"name"];
            [cell setOn:(self.selectedCategory == indexPath.row ? YES : NO) animated:YES];
            break;
        }
        case 4: { // Category Filters
            NSArray *categoryFilterArray = self.categoryFilters[self.selectedCategory];
            cell.titleLabel.text = categoryFilterArray[indexPath.row][@"name"];
            [cell setOn:[self.selectedCategories containsObject:categoryFilterArray[indexPath.row]] animated:YES];
            break;
        }
        default:
            break;
    }
    
    cell.delegate = self;
    
    return cell;
}

#pragma mark - Private methods

- (NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    // deals
    if (self.deal) {
        [filters setObject:@NO forKey:@"deals_filter"];
    }
    
    // distance
    if (self.selectedDistance > -1) {
        NSNumber* distance = (NSNumber *)(self.distances[self.selectedDistance][@"code"]);
        [filters setObject:distance forKey:@"radius_filter"];
    }
    
    // sort
    if (self.selectedSort > -1) {
        NSNumber *sortBy = (NSNumber *)(self.sorts[self.selectedSort][@"code"]);
        [filters setObject:sortBy forKey:@"sort"];
    }
    
    // categories
    if (self.selectedCategory >= 0) {
        [filters setObject:self.categories[self.selectedCategory][@"code"] forKey:@"term"];
    }
    
    // category filters
    if (self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories) {
            [names addObject:category[@"code"]];
        }
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
    }
    
    return filters;
}

- (void)onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSearchButton {
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initDistances {
    self.distances =
    @[@{@"name": @"Best Match", @"code": @800},
      @{@"name": @"0.3 miles", @"code": @482},
      @{@"name": @"1 mile", @"code": @1610},
      @{@"name": @"5 miles", @"code": @8047},
      @{@"name": @"20 miles", @"code": @32187}];
}

- (void)initSortBy {
    self.sorts =
    @[@{@"name": @"Best Match", @"code": @0},
      @{@"name": @"Distance", @"code": @1},
      @{@"name": @"Rating", @"code": @2}];
}


- (void)initCategories {
    self.categories =
    @[@{@"name":@"Restaurants", @"code":@"restaurants"},
      @{@"name":@"Arts & Entertainment", @"code":@"arts"},
      @{@"name":@"Education", @"code":@"education"}];
}


- (void)initCategoryFilters {
    self.categoryFilters =
    @[@[@{@"name":@"Afghan", @"code":@"afghani"},
      @{@"name":@"African", @"code":@"african"},
      @{@"name":@"Senegalese", @"code":@"senegalese"},
      @{@"name":@"South African", @"code":@"southafrican"},
      @{@"name":@"American (New)", @"code":@"newamerican"},
      @{@"name":@"American (Traditional)", @"code":@"tradamerican"},
      @{@"name":@"Arabian", @"code":@"arabian"},
      @{@"name":@"Arab Pizza", @"code":@"arabpizza"},
      @{@"name":@"Argentine", @"code":@"argentine"},
      @{@"name":@"Armenian", @"code":@"armenian"},
      @{@"name":@"Asian Fusion", @"code":@"asianfusion"},
      @{@"name":@"Asturian", @"code":@"asturian"},
      @{@"name":@"Australian", @"code":@"australian"},
      @{@"name":@"Austrian", @"code":@"austrian"},
      @{@"name":@"Baguettes", @"code":@"baguettes"},
      @{@"name":@"Bangladeshi", @"code":@"bangladeshi"},
      @{@"name":@"Barbeque", @"code":@"bbq"},
      @{@"name":@"Basque", @"code":@"basque"},
      @{@"name":@"Bavarian", @"code":@"bavarian"},
      @{@"name":@"Beer Garden", @"code":@"beergarden"},
      @{@"name":@"Beer Hall", @"code":@"beerhall"},
      @{@"name":@"Beisl", @"code":@"beisl"},
      @{@"name":@"Belgian", @"code":@"belgian"},
      @{@"name":@"Flemish", @"code":@"flemish"},
      @{@"name":@"Bistros", @"code":@"bistros"},
      @{@"name":@"Black Sea", @"code":@"blacksea"},
      @{@"name":@"Brasseries", @"code":@"brasseries"},
      @{@"name":@"Brazilian", @"code":@"brazilian"},
      @{@"name":@"Brazilian Empanadas", @"code":@"brazilianempanadas"},
      @{@"name":@"Central Brazilian", @"code":@"centralbrazilian"},
      @{@"name":@"Northeastern Brazilian", @"code":@"northeasternbrazilian"},
      @{@"name":@"Northern Brazilian", @"code":@"northernbrazilian"},
      @{@"name":@"Rodizios", @"code":@"rodizios"},
      @{@"name":@"Breakfast & Brunch", @"code":@"breakfast_brunch"},
      @{@"name":@"British", @"code":@"british"},
      @{@"name":@"Buffets", @"code":@"buffets"},
      @{@"name":@"Bulgarian", @"code":@"bulgarian"},
      @{@"name":@"Burgers", @"code":@"burgers"},
      @{@"name":@"Burmese", @"code":@"burmese"},
      @{@"name":@"Cafes", @"code":@"cafes"},
      @{@"name":@"Cafeteria", @"code":@"cafeteria"},
      @{@"name":@"Cajun/Creole", @"code":@"cajun"},
      @{@"name":@"Cambodian", @"code":@"cambodian"},
      @{@"name":@"Canadian (New)", @"code":@"newcanadian"},
      @{@"name":@"Canteen", @"code":@"canteen"},
      @{@"name":@"Caribbean", @"code":@"caribbean"},
      @{@"name":@"Dominican", @"code":@"dominican"},
      @{@"name":@"Haitian", @"code":@"haitian"},
      @{@"name":@"Puerto Rican", @"code":@"puertorican"},
      @{@"name":@"Trinidadian", @"code":@"trinidadian"},
      @{@"name":@"Catalan", @"code":@"catalan"},
      @{@"name":@"Chech", @"code":@"chech"},
      @{@"name":@"Cheesesteaks", @"code":@"cheesesteaks"},
      @{@"name":@"Chicken Shop", @"code":@"chickenshop"},
      @{@"name":@"Chicken Wings", @"code":@"chicken_wings"},
      @{@"name":@"Chilean", @"code":@"chilean"},
      @{@"name":@"Chinese", @"code":@"chinese"},
      @{@"name":@"Cantonese", @"code":@"cantonese"},
      @{@"name":@"Congee", @"code":@"congee"},
      @{@"name":@"Dim Sum", @"code":@"dimsum"},
      @{@"name":@"Fuzhou", @"code":@"fuzhou"},
      @{@"name":@"Hakka", @"code":@"hakka"},
      @{@"name":@"Henghwa", @"code":@"henghwa"},
      @{@"name":@"Hokkien", @"code":@"hokkien"},
      @{@"name":@"Hunan", @"code":@"hunan"},
      @{@"name":@"Pekinese", @"code":@"pekinese"},
      @{@"name":@"Shanghainese", @"code":@"shanghainese"},
      @{@"name":@"Szechuan", @"code":@"szechuan"},
      @{@"name":@"Teochew", @"code":@"teochew"},
      @{@"name":@"Comfort Food", @"code":@"comfortfood"},
      @{@"name":@"Corsican", @"code":@"corsican"},
      @{@"name":@"Creperies", @"code":@"creperies"},
      @{@"name":@"Cuban", @"code":@"cuban"},
      @{@"name":@"Curry Sausage", @"code":@"currysausage"},
      @{@"name":@"Cypriot", @"code":@"cypriot"},
      @{@"name":@"Czech", @"code":@"czech"},
      @{@"name":@"Czech/Slovakian", @"code":@"czechslovakian"},
      @{@"name":@"Danish", @"code":@"danish"},
      @{@"name":@"Delis", @"code":@"delis"},
      @{@"name":@"Diners", @"code":@"diners"},
      @{@"name":@"Dumplings", @"code":@"dumplings"},
      @{@"name":@"Eastern European", @"code":@"eastern_european"},
      @{@"name":@"Ethiopian", @"code":@"ethiopian"},
      @{@"name":@"Fast Food", @"code":@"hotdogs"},
      @{@"name":@"Filipino", @"code":@"filipino"},
      @{@"name":@"Fischbroetchen", @"code":@"fischbroetchen"},
      @{@"name":@"Fish & Chips", @"code":@"fishnchips"},
      @{@"name":@"Fondue", @"code":@"fondue"},
      @{@"name":@"Food Court", @"code":@"food_court"},
      @{@"name":@"Food Stands", @"code":@"foodstands"},
      @{@"name":@"French", @"code":@"french"},
      @{@"name":@"Alsatian", @"code":@"alsatian"},
      @{@"name":@"Auvergnat", @"code":@"auvergnat"},
      @{@"name":@"Berrichon", @"code":@"berrichon"},
      @{@"name":@"Bourguignon", @"code":@"bourguignon"},
      @{@"name":@"Nicoise", @"code":@"nicois"},
      @{@"name":@"Provencal", @"code":@"provencal"},
      @{@"name":@"French Southwest", @"code":@"sud_ouest"},
      @{@"name":@"Galician", @"code":@"galician"},
      @{@"name":@"Gastropubs", @"code":@"gastropubs"},
      @{@"name":@"Georgian", @"code":@"georgian"},
      @{@"name":@"German", @"code":@"german"},
      @{@"name":@"Baden", @"code":@"baden"},
      @{@"name":@"Eastern German", @"code":@"easterngerman"},
      @{@"name":@"Hessian", @"code":@"hessian"},
      @{@"name":@"Northern German", @"code":@"northerngerman"},
      @{@"name":@"Palatine", @"code":@"palatine"},
      @{@"name":@"Rhinelandian", @"code":@"rhinelandian"},
      @{@"name":@"Giblets", @"code":@"giblets"},
      @{@"name":@"Gluten-Free", @"code":@"gluten_free"},
      @{@"name":@"Greek", @"code":@"greek"},
      @{@"name":@"Halal", @"code":@"halal"},
      @{@"name":@"Hawaiian", @"code":@"hawaiian"},
      @{@"name":@"Heuriger", @"code":@"heuriger"},
      @{@"name":@"Himalayan/Nepalese", @"code":@"himalayan"},
      @{@"name":@"Hong Kong Style Cafe", @"code":@"hkcafe"},
      @{@"name":@"Hot Dogs", @"code":@"hotdog"},
      @{@"name":@"Hot Pot", @"code":@"hotpot"},
      @{@"name":@"Hungarian", @"code":@"hungarian"},
      @{@"name":@"Iberian", @"code":@"iberian"},
      @{@"name":@"Indian", @"code":@"indpak"},
      @{@"name":@"Indonesian", @"code":@"indonesian"},
      @{@"name":@"International", @"code":@"international"},
      @{@"name":@"Irish", @"code":@"irish"},
      @{@"name":@"Island Pub", @"code":@"island_pub"},
      @{@"name":@"Israeli", @"code":@"israeli"},
      @{@"name":@"Italian", @"code":@"italian"},
      @{@"name":@"Abruzzese", @"code":@"abruzzese"},
      @{@"name":@"Altoatesine", @"code":@"altoatesine"},
      @{@"name":@"Apulian", @"code":@"apulian"},
      @{@"name":@"Calabrian", @"code":@"calabrian"},
      @{@"name":@"Cucina campana", @"code":@"cucinacampana"},
      @{@"name":@"Emilian", @"code":@"emilian"},
      @{@"name":@"Friulan", @"code":@"friulan"},
      @{@"name":@"Ligurian", @"code":@"ligurian"},
      @{@"name":@"Lumbard", @"code":@"lumbard"},
      @{@"name":@"Napoletana", @"code":@"napoletana"},
      @{@"name":@"Piemonte", @"code":@"piemonte"},
      @{@"name":@"Roman", @"code":@"roman"},
      @{@"name":@"Sardinian", @"code":@"sardinian"},
      @{@"name":@"Sicilian", @"code":@"sicilian"},
      @{@"name":@"Tuscan", @"code":@"tuscan"},
      @{@"name":@"Venetian", @"code":@"venetian"},
      @{@"name":@"Japanese", @"code":@"japanese"},
      @{@"name":@"Blowfish", @"code":@"blowfish"},
      @{@"name":@"Conveyor Belt Sushi", @"code":@"conveyorsushi"},
      @{@"name":@"Donburi", @"code":@"donburi"},
      @{@"name":@"Gyudon", @"code":@"gyudon"},
      @{@"name":@"Oyakodon", @"code":@"oyakodon"},
      @{@"name":@"Hand Rolls", @"code":@"handrolls"},
      @{@"name":@"Horumon", @"code":@"horumon"},
      @{@"name":@"Izakaya", @"code":@"izakaya"},
      @{@"name":@"Japanese Curry", @"code":@"japacurry"},
      @{@"name":@"Kaiseki", @"code":@"kaiseki"},
      @{@"name":@"Kushikatsu", @"code":@"kushikatsu"},
      @{@"name":@"Oden", @"code":@"oden"},
      @{@"name":@"Okinawan", @"code":@"okinawan"},
      @{@"name":@"Okonomiyaki", @"code":@"okonomiyaki"},
      @{@"name":@"Onigiri", @"code":@"onigiri"},
      @{@"name":@"Ramen", @"code":@"ramen"},
      @{@"name":@"Robatayaki", @"code":@"robatayaki"},
      @{@"name":@"Soba", @"code":@"soba"},
      @{@"name":@"Sukiyaki", @"code":@"sukiyaki"},
      @{@"name":@"Takoyaki", @"code":@"takoyaki"},
      @{@"name":@"Tempura", @"code":@"tempura"},
      @{@"name":@"Teppanyaki", @"code":@"teppanyaki"},
      @{@"name":@"Tonkatsu", @"code":@"tonkatsu"},
      @{@"name":@"Udon", @"code":@"udon"},
      @{@"name":@"Unagi", @"code":@"unagi"},
      @{@"name":@"Western Style Japanese Food", @"code":@"westernjapanese"},
      @{@"name":@"Yakiniku", @"code":@"yakiniku"},
      @{@"name":@"Yakitori", @"code":@"yakitori"},
      @{@"name":@"Jewish", @"code":@"jewish"},
      @{@"name":@"Kebab", @"code":@"kebab"},
      @{@"name":@"Korean", @"code":@"korean"},
      @{@"name":@"Kosher", @"code":@"kosher"},
      @{@"name":@"Kurdish", @"code":@"kurdish"},
      @{@"name":@"Laos", @"code":@"laos"},
      @{@"name":@"Laotian", @"code":@"laotian"},
      @{@"name":@"Latin American", @"code":@"latin"},
      @{@"name":@"Colombian", @"code":@"colombian"},
      @{@"name":@"Salvadoran", @"code":@"salvadoran"},
      @{@"name":@"Venezuelan", @"code":@"venezuelan"},
      @{@"name":@"Live/Raw Food", @"code":@"raw_food"},
      @{@"name":@"Lyonnais", @"code":@"lyonnais"},
      @{@"name":@"Malaysian", @"code":@"malaysian"},
      @{@"name":@"Mamak", @"code":@"mamak"},
      @{@"name":@"Nyonya", @"code":@"nyonya"},
      @{@"name":@"Meatballs", @"code":@"meatballs"},
      @{@"name":@"Mediterranean", @"code":@"mediterranean"},
      @{@"name":@"Falafel", @"code":@"falafel"},
      @{@"name":@"Mexican", @"code":@"mexican"},
      @{@"name":@"Eastern Mexican", @"code":@"easternmexican"},
      @{@"name":@"Jaliscan", @"code":@"jaliscan"},
      @{@"name":@"Northern Mexican", @"code":@"northernmexican"},
      @{@"name":@"Oaxacan", @"code":@"oaxacan"},
      @{@"name":@"Pueblan", @"code":@"pueblan"},
      @{@"name":@"Tacos", @"code":@"tacos"},
      @{@"name":@"Tamales", @"code":@"tamales"},
      @{@"name":@"Yucatan", @"code":@"yucatan"},
      @{@"name":@"Middle Eastern", @"code":@"mideastern"},
      @{@"name":@"Egyptian", @"code":@"egyptian"},
      @{@"name":@"Lebanese", @"code":@"lebanese"},
      @{@"name":@"Milk Bars", @"code":@"milkbars"},
      @{@"name":@"Modern Australian", @"code":@"modern_australian"},
      @{@"name":@"Modern European", @"code":@"modern_european"},
      @{@"name":@"Mongolian", @"code":@"mongolian"},
      @{@"name":@"Moroccan", @"code":@"moroccan"},
      @{@"name":@"New Zealand", @"code":@"newzealand"},
      @{@"name":@"Night Food", @"code":@"nightfood"},
      @{@"name":@"Norcinerie", @"code":@"norcinerie"},
      @{@"name":@"Open Sandwiches", @"code":@"opensandwiches"},
      @{@"name":@"Oriental", @"code":@"oriental"},
      @{@"name":@"Pakistani", @"code":@"pakistani"},
      @{@"name":@"Parent Cafes", @"code":@"eltern_cafes"},
      @{@"name":@"Parma", @"code":@"parma"},
      @{@"name":@"Persian/Iranian", @"code":@"persian"},
      @{@"name":@"Peruvian", @"code":@"peruvian"},
      @{@"name":@"Pita", @"code":@"pita"},
      @{@"name":@"Pizza", @"code":@"pizza"},
      @{@"name":@"Polish", @"code":@"polish"},
      @{@"name":@"Pierogis", @"code":@"pierogis"},
      @{@"name":@"Portuguese", @"code":@"portuguese"},
      @{@"name":@"Alentejo", @"code":@"alentejo"},
      @{@"name":@"Algarve", @"code":@"algarve"},
      @{@"name":@"Azores", @"code":@"azores"},
      @{@"name":@"Beira", @"code":@"beira"},
      @{@"name":@"Fado Houses", @"code":@"fado_houses"},
      @{@"name":@"Madeira", @"code":@"madeira"},
      @{@"name":@"Minho", @"code":@"minho"},
      @{@"name":@"Ribatejo", @"code":@"ribatejo"},
      @{@"name":@"Tras-os-Montes", @"code":@"tras_os_montes"},
      @{@"name":@"Potatoes", @"code":@"potatoes"},
      @{@"name":@"Poutineries", @"code":@"poutineries"},
      @{@"name":@"Pub Food", @"code":@"pubfood"},
      @{@"name":@"Rice", @"code":@"riceshop"},
      @{@"name":@"Romanian", @"code":@"romanian"},
      @{@"name":@"Rotisserie Chicken", @"code":@"rotisserie_chicken"},
      @{@"name":@"Rumanian", @"code":@"rumanian"},
      @{@"name":@"Russian", @"code":@"russian"},
      @{@"name":@"Salad", @"code":@"salad"},
      @{@"name":@"Sandwiches", @"code":@"sandwiches"},
      @{@"name":@"Scandinavian", @"code":@"scandinavian"},
      @{@"name":@"Scottish", @"code":@"scottish"},
      @{@"name":@"Seafood", @"code":@"seafood"},
      @{@"name":@"Serbo Croatian", @"code":@"serbocroatian"},
      @{@"name":@"Signature Cuisine", @"code":@"signature_cuisine"},
      @{@"name":@"Singaporean", @"code":@"singaporean"},
      @{@"name":@"Slovakian", @"code":@"slovakian"},
      @{@"name":@"Soul Food", @"code":@"soulfood"},
      @{@"name":@"Soup", @"code":@"soup"},
      @{@"name":@"Southern", @"code":@"southern"},
      @{@"name":@"Spanish", @"code":@"spanish"},
      @{@"name":@"Arroceria / Paella", @"code":@"arroceria_paella"},
      @{@"name":@"Steakhouses", @"code":@"steak"},
      @{@"name":@"Sushi Bars", @"code":@"sushi"},
      @{@"name":@"Swabian", @"code":@"swabian"},
      @{@"name":@"Swedish", @"code":@"swedish"},
      @{@"name":@"Swiss Food", @"code":@"swissfood"},
      @{@"name":@"Tabernas", @"code":@"tabernas"},
      @{@"name":@"Taiwanese", @"code":@"taiwanese"},
      @{@"name":@"Tapas Bars", @"code":@"tapas"},
      @{@"name":@"Tapas/Small Plates", @"code":@"tapasmallplates"},
      @{@"name":@"Tex-Mex", @"code":@"mex"},
      @{@"name":@"Thai", @"code":@"thai"},
      @{@"name":@"Traditional Norwegian", @"code":@"norwegian"},
      @{@"name":@"Traditional Swedish", @"code":@"traditional_swedish"},
      @{@"name":@"Trattorie", @"code":@"trattorie"},
      @{@"name":@"Turkish", @"code":@"turkish"},
      @{@"name":@"Chee Kufta", @"code":@"cheekufta"},
      @{@"name":@"Gozleme", @"code":@"gozleme"},
      @{@"name":@"Turkish Ravioli", @"code":@"turkishravioli"},
      @{@"name":@"Ukrainian", @"code":@"ukrainian"},
      @{@"name":@"Uzbek", @"code":@"uzbek"},
      @{@"name":@"Vegan", @"code":@"vegan"},
      @{@"name":@"Vegetarian", @"code":@"vegetarian"},
      @{@"name":@"Venison", @"code":@"venison"},
      @{@"name":@"Vietnamese", @"code":@"vietnamese"},
      @{@"name":@"Wok", @"code":@"wok"},
      @{@"name":@"Wraps", @"code":@"wraps"},
      @{@"name":@"Yugoslav", @"code":@"yugoslav"}],
      
      // Arts & Entertainment
      @[@{@"name":@"Arcades", @"code":@"arcades"},
        @{@"name":@"Art Galleries", @"code":@"galleries"},
        @{@"name":@"Casinos", @"code":@"casinos"},
        @{@"name":@"Cinema", @"code":@"movietheaters"}],
      
      // Education
      @[@{@"name":@"Colleges & Universities", @"code":@"collegeuniv"},
        @{@"name":@"Elementary Schools", @"code":@"elementaryschools"},
        @{@"name":@"Middle Schools & High Schools", @"code":@"highschools"},
        @{@"name":@"Preschools", @"code":@"preschools"},
        @{@"name":@"Special Education", @"code":@"specialed"}]
      ];
}

@end
