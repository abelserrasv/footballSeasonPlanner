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


/**
 Spielplan
 
 Beigefügt finden Sie eine Datei "mannschaften.json", welche eine Auflistung von Mannschaften einer Liga beinhaltet. 
 
 Schreiben Sie ein Programm, dass die Mannschaften von der Datei einliest und anschließend einen Spielplan erstellt.
 
 Der Spielplan soll aus einer Hin- und Rückrunde bestehen. Jeder spielt gegen jeden zweimal, einmal als Heim- und einmal als Auswärtsspiel.
 
 Die Spieltage sollen auf die Sonntage zwischen, in der Datei definiertem, Beginn- und Ende- Datum verteilt werden. Feiertage und Ferienzeiten können unberücksichtigt bleiben.
 
 Stellen sie den Spielplan grafisch als Liste dar, jeweils mit Datum formatiert für die Benutzerregion sowie der Spielpaarung.
 
*/

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.season = [[SPSeason alloc] initWithJsonFileName:@"mannschaften"];
    if (self.season.errorDuringCreation) {
        UIAlertController *alertController = [UIAlertController
                                    alertControllerWithTitle:NSLocalizedString(@"SID_ERROR", nil)
                                    message:self.season.errorDuringCreation.localizedDescription
                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"SID_OK", nil)
                                   style:UIAlertActionStyleDefault
                                   handler:nil];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        if (self.season.leagueName && self.season.seasonName) {
            self.title = [NSString stringWithFormat:@"%@ (%@)", self.season.leagueName, self.season.seasonName];
        } else if (self.season.leagueName) {
            self.title = [NSString stringWithFormat:@"%@", self.season.leagueName];
        }
        
        self.matchesTableView.dataSource = self;
        self.matchesTableView.delegate = self;
    }
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [self.season getMatchStringForADay:indexPath.section andMatch:indexPath.row];
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.season getStringForMatchDate:section];
}

@end
