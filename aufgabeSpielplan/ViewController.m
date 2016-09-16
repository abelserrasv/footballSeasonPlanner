//
//  ViewController.m
//  aufgabeSpielplan
//
//  Created by Abel Serra on 25.08.16.
//  Copyright © 2016 Abel Serra. All rights reserved.
//

#import "SPSeason.h"
#import "ViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property SPSeason *season;
@property (weak, nonatomic) IBOutlet UITableView *matchesTableView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.season = [[SPSeason alloc] init];

    self.title = [NSString stringWithFormat:@"%@ (%@)", self.season.leagueName, self.season.seasonName];

    self.matchesTableView.dataSource = self;
    self.matchesTableView.delegate = self;
}

#pragma mark - TableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.season getNumberOfMatchDays];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.season getNumberOfMatchesForADay:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }

    cell.textLabel.text = [self.season getMatchStringForADay:indexPath.section andMatch:indexPath.row];
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.season getStringForMatchDate:section];
}

@end
