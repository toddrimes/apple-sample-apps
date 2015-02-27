#import "IOSCapabilitiesController.h"   // Header
#import "RelayrControllers.h"           // HtH
#import <Relayr/Relayr.h>               // Relayr.framework

#define HtHSegueID_NoCapabilities   @"Segue_NoCapabilities"
#define HtHSegueID_Capabilities     @"Segue_Capabilities"
#define HtHSegueID_Reading          @"Segue_Reading"
#define HtHSegueID_Command          @"Segue_Command"

@interface IOSCapabilitiesController ()
@end

@implementation IOSCapabilitiesController
{
    NSArray* _readings;
    NSArray* _commands;
}

#pragma mark - Public API

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set iVars
    _readings = [self readingsOfDevice];
    _commands = [self commandsOfDevice];
    
    // Set tableview
    self.tableView.rowHeight = 65.0f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (UINavigationController <RelayrControllers>*)navigationController
{
    return (UINavigationController <RelayrControllers>*)super.navigationController;
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    NSUInteger const numSections = ((_readings.count) ? 1 : 0) + ((_commands.count) ? 1 : 0);
    if (!numSections)
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self performSegueWithIdentifier:HtHSegueID_NoCapabilities sender:self];
    }
    else
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self performSegueWithIdentifier:HtHSegueID_Capabilities sender:self];
    }
    return numSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self arrayForSection:section].count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"IOSCapabilitiesCell" forIndexPath:indexPath];
    id capability = [self arrayForSection:indexPath.section][indexPath.row];
    if ([capability isKindOfClass:[RelayrReading class]]) {
        cell.textLabel.text = ((RelayrReading*)capability).meaning;
    } else {
        cell.textLabel.text = ((RelayrCommand*)capability).meaning;
    }
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    id capability = [self arrayForSection:indexPath.section][indexPath.row];
    if ([capability isKindOfClass:[RelayrReading class]]) {
        [self performSegueWithIdentifier:HtHSegueID_Reading sender:self];
    } else if ([capability isKindOfClass:[RelayrCommand class]]) {
        [self performSegueWithIdentifier:HtHSegueID_Command sender:self];
    }
}

#pragma mark - Private functionality

- (NSArray*)readingsOfDevice
{
    if ([_selectedDevice isKindOfClass:[RelayrDevice class]]) { return ((RelayrDevice*)_selectedDevice).readings.allObjects; }
    if (![_selectedDevice isKindOfClass:[RelayrTransmitter class]]) { return nil; }
    
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for (RelayrDevice* device in ((RelayrTransmitter*)_selectedDevice).devices)
    {
        NSArray* readings = device.readings.allObjects;
        if (readings) { [result addObjectsFromArray:readings]; }
    }
    
    return (result.count) ? result.copy : nil;
}

- (NSArray*)commandsOfDevice
{
    if ([_selectedDevice isKindOfClass:[RelayrDevice class]]) { return ((RelayrDevice*)_selectedDevice).commands.allObjects; }
    if (![_selectedDevice isKindOfClass:[RelayrTransmitter class]]) { return nil; }
    
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for (RelayrDevice* device in ((RelayrTransmitter*)_selectedDevice).devices)
    {
        NSArray* commands = device.commands.allObjects;
        if (commands) { [result addObjectsFromArray:commands]; }
    }
    
    return (result) ? result.copy : nil;
}

- (NSArray*)arrayForSection:(NSUInteger)section
{
    return (!section && _readings) ? _readings : _commands;
}

@end