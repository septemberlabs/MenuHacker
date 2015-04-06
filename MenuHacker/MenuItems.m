//
//  MenuItems.m
//  MenuHacker
//
//  Created by Will Smith on 3/28/15.
//  Copyright (c) 2015 Will Smith. All rights reserved.
//

#import "MenuItems.h"

@interface MenuItems ()
@property (strong, nonatomic) NSArray *menuItems;
@property (strong, nonatomic) UITableViewCell *phantomCell;
@property (strong, nonatomic) UITableViewCell *originallySelectedCell;
@property (strong, nonatomic) UITableViewCell *currentlySelectedCell;
@property (strong, nonatomic) NSString *addedMenuItem;
@end

@implementation MenuItems

@synthesize menuItems = _menuItems;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.menuItems = [NSArray arrayWithObjects:@"Watercress", @"Salad", @"zesty", @"Italian", @"dressing", @"rtcotta", @"salata", @"heart", @"palm", @"crispy", @"shaSot", nil];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
}

- (NSArray *)menuItems
{
    if (!_menuItems) {
        _menuItems = [NSArray array];
    }
    return _menuItems;
}

- (void)setMenuItems:(NSArray *)menuItems
{
    _menuItems = menuItems;
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"gesture recognizers: %@", self.tableView.gestureRecognizers);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.menuItems count];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MenuItemCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(liftMenuItem:)];
    [cell addGestureRecognizer:longPressRecognizer];
    
    NSString *menuItem = [self.menuItems objectAtIndex:indexPath.row];
    
    cell.textLabel.text = menuItem;
    return cell;
}

- (void)liftMenuItem:(UILongPressGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"registered long press: %ld", gestureRecognizer.state);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.originallySelectedCell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForRowAtPoint:[gestureRecognizer locationInView:self.tableView]]];
        self.phantomCell = [self phantomCellMake:self.originallySelectedCell];
        [self.tableView addSubview:self.phantomCell];
    }
    
    // while the cell is being panned
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        // movement is confined to the y-axis as is. if you want to liberate the view to move in 2 dimensions, use the below line instead.
        //self.phantomCell.center = CGPointMake([gestureRecognizer locationInView:self.tableView]);
        self.phantomCell.center = CGPointMake(self.phantomCell.center.x, [gestureRecognizer locationInView:self.tableView].y);
        
        // select the row under the user's finger
        UITableViewCell *hoveredOverCell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForRowAtPoint:[gestureRecognizer locationInView:self.tableView]]];
        // if the cell under the user's finger is different than last time, select the new cell and deselect the old one. otherwise don't do anything.
        if (hoveredOverCell != self.currentlySelectedCell) {
            self.currentlySelectedCell.selected = NO;
            hoveredOverCell.selected = YES;
            self.currentlySelectedCell = hoveredOverCell;
            
            NSIndexPath *originalIndexPath = [self.tableView indexPathForCell:self.originallySelectedCell];
            NSIndexPath *currentlySelectedIndexPath = [self.tableView indexPathForCell:self.currentlySelectedCell];
            NSString *detailText;
            
            // the original row was vertically higher in the table, so its text should go before the selected row's text.
            if (originalIndexPath.row < currentlySelectedIndexPath.row) {
                detailText = [NSString stringWithFormat:@"%@ %@", [self.menuItems objectAtIndex:originalIndexPath.row], [self.menuItems objectAtIndex:currentlySelectedIndexPath.row]];
            }
            // the original row was vertically lower in the table, so its text should go after the selected row's text.
            if (originalIndexPath.row > currentlySelectedIndexPath.row) {
                detailText = [NSString stringWithFormat:@"%@ %@", [self.menuItems objectAtIndex:currentlySelectedIndexPath.row], [self.menuItems objectAtIndex:originalIndexPath.row]];
            }
            
            self.phantomCell.detailTextLabel.text = detailText;
            self.addedMenuItem = detailText;
        }
        
    }
    
    // when the user lets go
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        // if self.currentlySelectedCell is nil it means we never entered the state UIGestureRecognizerStateChanged. (the user just long-pressed, then let go moving panning.) no clean-up is therefore necessary.
        // if self.currentlySelectedCell != self.originallySelectedCell, the cell under the user's finger is different than the originally selected cell.
        // if both are true, proceed with inserting a new row.
        if ((self.currentlySelectedCell != nil) &&
            (self.currentlySelectedCell != self.originallySelectedCell)) {
            
            // create a mutable array that's a copy of the existing data source, to allow for insertion of a row.
            NSMutableArray *newArray = [self.menuItems mutableCopy];
            
            NSIndexPath *originalIndexPath = [self.tableView indexPathForCell:self.originallySelectedCell];
            NSIndexPath *currentlySelectedIndexPath = [self.tableView indexPathForCell:self.currentlySelectedCell];
            NSIndexPath *indexPathToInsert;
            
            // the original item was vertically higher in the table, so the new item should go right after it.
            if (originalIndexPath.row < currentlySelectedIndexPath.row) {
                [newArray insertObject:self.addedMenuItem atIndex:currentlySelectedIndexPath.row];
                indexPathToInsert = [NSIndexPath indexPathForRow:currentlySelectedIndexPath.row inSection:0];
            }
            // the original item was vertically lower in the table, so the new item should take its slot, pushing all subsequent ones down.
            if (originalIndexPath.row > currentlySelectedIndexPath.row) {
                [newArray insertObject:self.addedMenuItem atIndex:(currentlySelectedIndexPath.row+1)];
                indexPathToInsert = [NSIndexPath indexPathForRow:(currentlySelectedIndexPath.row+1) inSection:0];
            }
            
            // overwrite the old data source using the mutable array with the newly-inserted row.
            self.menuItems = [NSArray arrayWithArray:newArray];
            
            NSArray *indexPathArray = [NSArray arrayWithObject:indexPathToInsert];
            [self.tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
            
            self.currentlySelectedCell.selected = NO;
        }

        // delete the phantom cell.
        [self.phantomCell removeFromSuperview];
        self.phantomCell = nil;
    }
}

- (UITableViewCell *)phantomCellMake:(UITableViewCell *)cellToMove
{
    UITableViewCell *phantomCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DOES_IT_MATTER"];
    phantomCell.frame = cellToMove.frame;
    phantomCell.autoresizingMask = cellToMove.autoresizingMask;
    phantomCell.backgroundColor = [UIColor redColor];
    phantomCell.alpha = 0.25;
    return phantomCell;
    
    /*
    UIView *v = [[UIView alloc] initWithFrame:cellToMove.frame];
    v.autoresizingMask = cellToMove.autoresizingMask;
    
    for (UIView *v1 in cellToMove.subviews) {
        UIView *v2 = [[[v1 class] alloc] initWithFrame:v1.frame];
        v2.autoresizingMask = v1.autoresizingMask;
        v2.backgroundColor = [UIColor redColor];
        [v addSubview:v2];
    }
    v.backgroundColor = [UIColor redColor];
    v.alpha = 0.25;
    return v;
     */
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSMutableArray *newArray = [self.menuItems mutableCopy];
        [newArray removeObjectAtIndex:indexPath.row];
        self.menuItems = [NSArray arrayWithArray:newArray];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    else {
        NSLog(@"Unhandled editing style! %d", (int)editingStyle);
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
