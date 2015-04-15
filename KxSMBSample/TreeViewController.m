//
//  TreeViewController.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/20.
//


#import "TreeViewController.h"
// :: Other ::
#import "AuthViewController.h"
#import "FileViewController.h"
#import "KxSMBProvider.h"
#import "LeftBarButtonImage.h"
#import "LocalFileViewController.h"
#import "SettingsViewController.h"

@interface TreeViewController () <UITableViewDataSource, UITableViewDelegate, AuthViewControllerDelegate, FileViewControllerDelegate>
@end

@implementation TreeViewController {
    
    BOOL        _isHeadVC;
    NSArray     *_items;
    BOOL        _loading;
    BOOL        _needNewPath;
    UITextField *_newPathField;
}

- (void) setPath:(NSString *)path
{
    _path = path;
    [self reloadPath];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.title   = @"";
        _needNewPath = YES;
        _isHeadVC    = NO;
    }
    return self;
}

- (id)initAsHeadViewController {
    if((self = [self init])) {
        _isHeadVC = YES;
    }
    return self;
}

- (void)loadView
{

    [super loadView];
    
    self.navigationController.toolbarHidden = NO;
    
    if(NSClassFromString(@"UIRefreshControl")) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(reloadPath) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
    }
    
    if(_isHeadVC) {
        self.navigationItem.leftBarButtonItem  = [self generateCustomLeftBarButtonItem:@"refresh.png"];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                              target:self
                                                                                              action:@selector(addAuthView)];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupToolBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.navigationController.childViewControllers.count == 1 && _needNewPath) {
        _needNewPath = NO;
        [self requestNewPath];
    }
}

- (void) reloadPath
{
    NSString *path;
    if (_path.length) {
        path = _path;
        self.title = path.lastPathComponent;
    } else {
        
        path = @"smb://";
        self.title = @"smb://";
    }
    
    _items = nil;
    [self.tableView reloadData];
    [self updateStatus:[NSString stringWithFormat: @"Fetching %@..", path]];
    
    KxSMBProvider *provider = [KxSMBProvider sharedSmbProvider];
    [provider fetchAtPath:path
                    block:^(id result)
    {
        if ([result isKindOfClass:[NSError class]]) {
            
            [self updateStatus:result];
            
        } else {
        
            [self updateStatus:nil];
            
            if ([result isKindOfClass:[NSArray class]]) {
                _items = [[self excludeHiddenFile:result] copy];
            } else if ([result isKindOfClass:[KxSMBItem class]]) {
                
                _items = @[result];
            }
            
            [self.tableView reloadData];
        }
    }];
}

# pragma mark - pushed navigationbar button
- (void) requestNewPath {
    
    if(_newPathField == nil) {
        _newPathField                        = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 30)];
        _newPathField.borderStyle            = UITextBorderStyleRoundedRect;
        _newPathField.placeholder            = @"smb://";
        _newPathField.keyboardType           = UIKeyboardTypeURL;
        _newPathField.autocorrectionType     = UITextAutocorrectionTypeNo;
        _newPathField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _newPathField.text                   = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastServer"];
    }
    
    NSString *appendedPath = [NSString stringWithFormat:@"smb://%@%@",
                              _newPathField.text,
                              [[NSUserDefaults standardUserDefaults] objectForKey:@"RemoteDirectory"]];
    self.path = appendedPath;
    [[NSUserDefaults standardUserDefaults] setObject:_newPathField.text forKey:@"LastServer"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_newPathField becomeFirstResponder];
}
- (void) addAuthView {
    AuthViewController *vc = [[AuthViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    vc.delegate = self;
}

- (void) updateStatus: (id) status
{
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    
    if ([status isKindOfClass:[NSString class]]) {
    
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        CGSize sz = activityIndicator.frame.size;        
        const float H = font.lineHeight + sz.height + 10;
        const float W = self.tableView.frame.size.width;
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W, H)];
        
        UILabel *label = [self setupCellLabel:status textColor:[UIColor grayColor]];
        
        [v addSubview:label];
        
        if(![self.refreshControl isRefreshing])
            [self.refreshControl beginRefreshing];
        
        self.tableView.tableHeaderView = v;
        
    } else if ([status isKindOfClass:[NSError class]]) {
        
        UILabel *label = [self setupCellLabel:((NSError *)status).localizedDescription
                                    textColor:[UIColor redColor]];
        
        self.tableView.tableHeaderView = label;
        
        [self.refreshControl endRefreshing];
        
    } else {
        
        self.tableView.tableHeaderView = nil;
        
        [self.refreshControl endRefreshing];
    }
}

- (UILabel*)setupCellLabel:(NSString*)text textColor:(UIColor*)color {
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    const float W = self.tableView.frame.size.width;
    
    UILabel *label         = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, W, font.lineHeight)];
    label.text             = text;
    label.font             = font;
    label.textColor        = color;
    label.textAlignment    = NSTextAlignmentCenter;
    label.opaque           = NO;
    label.backgroundColor  = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    return label;
}

- (void)appearLocalFileList {
    [self.navigationController pushViewController:[LocalFileViewController alloc] animated:YES];
    
    return;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellIdentifier];
    }
    
    KxSMBItem *item = _items[indexPath.row];
    cell.textLabel.text = item.path.lastPathComponent;
    
    UIImage *image = nil;
    if ([item isKindOfClass:[KxSMBItemTree class]]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text =  @"";
        image = [UIImage imageNamed:@"folder.png"];
    } else {
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld KB", item.stat.size / 1000];
        image = [UIImage imageNamed:@"file.png"];
    }
    cell.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    KxSMBItem *item = _items[indexPath.row];
    if ([item isKindOfClass:[KxSMBItemTree class]]) {
        
        TreeViewController *vc = [[TreeViewController alloc] init];
        vc.path = item.path;
        [self.navigationController pushViewController:vc animated:YES];
        
    } else if ([item isKindOfClass:[KxSMBItemFile class]]) {
        
        FileViewController *vc = [[FileViewController alloc] init];
        vc.delegate = self;
        vc.smbFile = (KxSMBItemFile *)item;
        // fileViewのnavigationViewにpushする
        [self.fileViewNavigationController pushViewController:vc animated:YES];
        
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        KxSMBItem *item = _items[indexPath.row];
        [[KxSMBProvider sharedSmbProvider] removeAtPath:item.path block:^(id result) {
            
            NSLog(@"completed:%@", result);
            if (![result isKindOfClass:[NSError class]]) {
                [self reloadPath];
            }
        }];        
    }
}

#pragma mark - Auth View Controller Delegate
- (void) couldAuthViewController:(AuthViewController *)controller done:(BOOL)done
{
    if ([self.delegate respondsToSelector:@selector(authViewCloseHandler:)]) {
        [self.delegate authViewCloseHandler:controller];
    }
}
#pragma mark - File View Controller Delegate
- (void) hideTreeView:(BOOL)isHidden {
    
    CGFloat xOffset = 0;

    if (isHidden) {
        xOffset  = 320.0f;
    } else {
        xOffset  = 0;
    }
    isHidden = !isHidden;
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.parentViewController.view.frame = CGRectMake(-xOffset, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        self.navigationController.navigationBar.frame = CGRectMake(-xOffset,
                                                                   0,
                                                                   self.navigationController.navigationBar.frame.size.width,
                                                                   60);
    } completion:^ (BOOL finished){
        // 完了時のコールバック
        NSLog(@"finish Animation");
    }];
    
    
}

#pragma mark - Private
- (void) setupToolBar {
    UIBarButtonItem *localFileListButton = [[UIBarButtonItem alloc] initWithTitle:@"ローカル" style:UIBarButtonItemStylePlain target:self action:@selector(appearLocalFileList)];
    UIImage *btnImg = [[LeftBarButtonImage alloc] initWithUIImage:@"settings.png"];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:btnImg
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(showSettingViewController)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    self.toolbarItems = @[localFileListButton, flexibleSpace, settingsButton];
}

- (UIBarButtonItem*)generateCustomLeftBarButtonItem:(NSString*)fileName {
    UIImage *btnImg = [[LeftBarButtonImage alloc] initWithUIImage:fileName];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:btnImg
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(requestNewPath)];
    return leftBarButtonItem;
}

- (void) showSettingViewController {
    SettingsViewController *vc = [SettingsViewController new];
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:vc animated:YES completion:nil];
}
- (NSArray*)excludeHiddenFile:(NSArray*)array {
    // 隠しファイルを除外する
    NSMutableArray *filteredResult = [NSMutableArray array];
    for (KxSMBItem *item in array) {
        NSString *itemPathTmp = item.path;
        NSString *fileName = (NSString*)[[itemPathTmp componentsSeparatedByString:@"/"] lastObject];
        
        if(![fileName hasPrefix:@"."]) {
            [filteredResult addObject:item];
        }
    }
    return filteredResult;
}



@end
