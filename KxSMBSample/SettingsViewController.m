//
//  SettingsViewController.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/15.
//

#import "SettingsViewController.h"

@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) NSArray *settingsItems;
@property (nonatomic) UITableView *tableView;
@end

@implementation SettingsViewController
#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _settingsItems = @[@"前回のログインアカウントを使用する", @"アプリ終了時にローカルファイルを削除する",@"クラウドサーバの利用を許可する"];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self.view addSubview:[self generateTableView]];
    [self.view addSubview:[self generateCloseButton]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private
static NSString *const COMMON_SETTING_KEY = @"SettingsKey";
- (UITableViewCell*)setupCellContents:(UITableViewCell*)cell AtRow:(NSInteger)row {
    cell.textLabel.text = self.settingsItems[row];
    cell.textLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:12];
    UISwitch *sw        = [[UISwitch alloc] initWithFrame:CGRectZero];
    sw.onTintColor      = TOP_BACKGROUND_COLOR;
    sw.tag              = row;
    sw.on = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-%ld",COMMON_SETTING_KEY, (long)row]] boolValue];
    [sw addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView  = sw;
    return cell;
}

- (void)switchValueChanged:(UISwitch*)sender {
    NSUserDefaults *uf = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@-%ld",COMMON_SETTING_KEY, (long)sender.tag];
    [uf setBool:sender.on forKey:key];
}

- (void)dismissSettingsView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UITableView*)generateTableView {
    UITableView *tableView    = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           self.view.frame.size.width,
                                                                           self.view.frame.size.height)
                                                          style:UITableViewStylePlain];
    tableView.dataSource      = self;
    tableView.delegate        = self;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.scrollEnabled   = NO;
    tableView.allowsSelection = NO;
    return tableView;
}

static const CGFloat headerHeight = 60;
- (UIButton*)generateCloseButton {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(6, 0, 60, headerHeight)];
    [button setTitle:@"閉じる" forState:UIControlStateNormal];
    [button setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dismissSettingsView) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - Table View Data Source
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.settingsItems count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell           = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellIdentifier];
    }
    cell = [self setupCellContents:cell AtRow:indexPath.row];
    return cell;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label        = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, headerHeight)];
    label.text            = @"環境設定";
    label.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:16];
    label.textAlignment   = NSTextAlignmentCenter;
    label.backgroundColor = INFOCUS_UNDERLINE_COLOR;
    return label;
}
@end
