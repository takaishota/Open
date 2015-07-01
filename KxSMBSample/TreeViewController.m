//
//  TreeViewController.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/20.
//


#import "TreeViewController.h"
// :: Other ::
#import "AuthViewController.h"
#import "DXPopover.h"
#import "KxSMBProvider.h"
#import "LocalFileViewController.h"
#import "OPNSearchResultTableViewController.h"
#import "SettingsViewController.h"
#import "SplitViewController.h"
#import "UIImage+Utility.h"
#import "UIColor+CustomColors.h"
#import "UIView+Utility.h"

typedef NS_ENUM (NSUInteger, kSortType) {
    kSortTypeDate,
    kSortTypeFileExtension,
    kSortTypeName,
    kSortTypeFileSize
};

@interface TreeViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate , AuthViewControllerDelegate, OPNSearchResultTableViewControllerDelegate>
@property (nonatomic) NSMutableArray *smbItemSearchResult;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) UIView *overlayView;
@property (nonatomic) NSUInteger currentSortType;
@property (nonatomic) int reloadCount;
@property (nonatomic) UIGestureRecognizer *singleTapGestureRecognizer;
@property (nonatomic) OPNSearchResultTableViewController *resultsTableVc;

@end

@implementation TreeViewController {
    NSArray     *_items;
    BOOL        _needNewPath;
}

#pragma mark - LifeCycle
- (id)init
{
    self = [super init];
    if (self) {
        self.title   = @"";
        self.reloadCount = 0;
        _needNewPath = YES;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    if(NSClassFromString(@"UIRefreshControl")) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(reloadPath) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
    }
    self.navigationItem.rightBarButtonItem  = [self generateResizingBarButtonItemWithImage:@"refresh.png"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setTableViewStyle];
}

- (void)viewDidAppear:(BOOL)animated {
    self.navigationController.toolbarHidden = NO;
    [self setupToolBar];
    
    if (self.navigationController.childViewControllers.count == 2 && _needNewPath) {
        _needNewPath = NO;
        [self requestNewPath];
    }
}

#pragma mark - Custom Accessors
- (void) setPath:(NSString *)path
{
    _path = path;
    [self reloadPath];
}

#pragma mark - Private
- (void)setTableViewStyle {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 70.f;
}

- (UISearchBar*)generateSearchBar {
    // 検索バーを作成する
    self.searchBar = [UISearchBar new];
    self.searchBar.delegate = self;
    self.searchBar.frame = CGRectMake(0, 0, 320, 44.0f);
    self.searchBar.layer.position = CGPointMake(self.view.width/2, statusBarHeight);
    
    self.searchBar.showsCancelButton = NO;
    self.searchBar.showsSearchResultsButton = NO;
    self.searchBar.showsBookmarkButton = NO;
    self.searchBar.searchBarStyle = UISearchBarStyleDefault;
    
    self.searchBar.placeholder = @"検索";
    
    // カーソル、キャンセルボタンの色を設定する.
    self.searchBar.tintColor = [UIColor customRedColor];
    
    return self.searchBar;
}

- (void)setupToolBar {
    UIBarButtonItem *localFileListButton = [[UIBarButtonItem alloc] initWithTitle:@"ローカル" style:UIBarButtonItemStylePlain target:self action:@selector(appearLocalFileList)];
    UIImage *settingBtnImg = [[UIImage alloc] initWithUIImage:@"settings.png"];
    UIImage *sortBtnImg = [[UIImage alloc] initWithUIImage:@"sort.png"];
    
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:settingBtnImg
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(showSettingViewController)];
    UIBarButtonItem *sortButton = [[UIBarButtonItem alloc] initWithImage:sortBtnImg style:UIBarButtonItemStylePlain target:self action:@selector(showSortPopupviewController:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    self.toolbarItems = @[localFileListButton, flexibleSpace, sortButton, settingsButton];
}

- (UIBarButtonItem*)generateResizingBarButtonItemWithImage:(NSString*)fileName {
    UIImage *btnImg = [[UIImage alloc] initWithUIImage:fileName];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:btnImg
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(requestNewPath)];
    return barButtonItem;
}

- (void)showSortPopupviewController:(UIBarButtonItem*)sender {
    
    UIView *contentsView = [self generateSortPopupView];
    
    UIView *view = [sender valueForKey:@"view"];
    view.height = self.view.height - 45;
    
    DXPopover *popover = [DXPopover popover];
    [popover showAtView:view popoverPostion:DXPopoverPositionUp withContentView:contentsView inView:self.navigationController.view];
}

- (UIView*)generateSortPopupView {
    
    UIViewController *vc = [UIViewController new];
    UIView *view = vc.view;
    view.width = 140;
    view.height = 120;
    
    // sortTypeのボタン作成
    NSArray *sortType = @[@"日付", @"種類", @"名前", @"サイズ"];
    for (int i = 0; i < sortType.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [btn setTitle:sortType[i] forState:UIControlStateNormal];
        btn.tag = i;
        btn.frame = CGRectMake(20, (i * 25) + 10, 100, 20);
        [btn addTarget:self action:@selector(selectSortTypeBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [view addSubview:btn];
    }
    return vc.view;
}

- (void)selectSortTypeBtn:(UIButton*)sender {
    
    switch (sender.tag) {
        case 0:
            self.currentSortType = kSortTypeDate;
            break;
        case 1:
            self.currentSortType = kSortTypeFileExtension;
            break;
        case 2:
            self.currentSortType = kSortTypeName;
            break;
        case 3:
            self.currentSortType = kSortTypeFileSize;
            break;
        default:
            break;
    }
    
    [self updateTabelViewBySelectedSortType];
}

- (void)updateTabelViewBySelectedSortType {
    
    NSSortDescriptor* sortDesc = nil;
    switch (self.currentSortType) {
        case kSortTypeDate:
            // ソートの種類:日付
            sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"stat.lastModified" ascending:NO];
            _items = [_items sortedArrayUsingDescriptors:@[sortDesc]];
            break;
        case kSortTypeFileExtension:
            // ソートの種類:拡張子
            sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"path.pathExtension" ascending:YES];
            _items = [_items sortedArrayUsingDescriptors:@[sortDesc]];
            break;
        case kSortTypeName:
            // ソートの種類:なまえ
            sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"path.lastPathComponent" ascending:YES];
            _items = [_items sortedArrayUsingDescriptors:@[sortDesc]];
            break;
        case kSortTypeFileSize:
            // ソートの種類:ファイルサイズ
            sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"stat.size" ascending:NO];
            _items = [_items sortedArrayUsingDescriptors:@[sortDesc]];
            break;
        default:
            break;
    }
    
    [self.tableView reloadData];
}

- (void)reloadPath {
    NSString *path = _path;
    
    [self setupTitle:path];
    [self updateStatus:[NSString stringWithFormat: @"Fetching %@..", path]];
    
    _items = nil;
    
    NSString *urlShemeAddedPath = [self addURLSheme:path];
    
    // TODO:KxSMBProviderと関わるクラスをひとつにまとめたい
    KxSMBProvider *provider = [KxSMBProvider sharedSmbProvider];
    
    [provider fetchAtPath:urlShemeAddedPath
                    block:^(id result)
    {
        if ([result isKindOfClass:[NSError class]] && self.reloadCount > 0) {
            [self updateStatus:result];
            self.reloadCount = 0;
        } else {
            [self updateStatus:nil];
            
            if ([result isKindOfClass:[NSArray class]]) {
                _items = [[self excludeHiddenFile:result] copy];
                
            } else if ([result isKindOfClass:[KxSMBItem class]]) {
                _items = @[result];
            }
            
            [self.tableView reloadData];
            self.reloadCount++;
        }
    }];
}

- (void)setupTitle:(NSString*)path{
    if (path.length) {
        self.title = path.lastPathComponent;
    } else {
        self.title = @"エラー";
    }
}

- (NSString*)addURLSheme:(NSString*)path {
    NSString *urlShemeAddedPath = path;
    
    NSRange range = [path rangeOfString:@"smb://"];
    if (range.location == NSNotFound) {
     
        urlShemeAddedPath = [NSString stringWithFormat:@"smb://%@", path];
    }
    return urlShemeAddedPath;
}

- (void)showSettingViewController {
    SettingsViewController *vc = [SettingsViewController new];
    // TODO:iOS8から背景が透過しない
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

# pragma mark - pushed navigationbar button
- (void) requestNewPath {
    self.path = _path;
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
        // サーバ初回アクセス時（navigationController.childViewControllersが2）はreloadが完了した後
        // ディレクトリ展開時（navigationController.childViewControllersが3以上）は最初から
        // サーチバーを表示する
        if ((self.navigationController.childViewControllers.count == 2 && self.reloadCount > 0)
            || self.navigationController.childViewControllers.count > 2) {
            self.tableView.tableHeaderView = [self generateSearchBar];
        }
        [self.refreshControl endRefreshing];
    }
}

- (UILabel*)setupCellLabel:(NSString*)text textColor:(UIColor*)color {
    UIFont *font = [UIFont boldSystemFontOfSize:14];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }
    [self setupTreeViewCell:cell WithItem:_items[indexPath.row]];
    
    return cell;
}

- (void)setupTreeViewCell:(UITableViewCell*)cell WithItem:(KxSMBItem*)item {
    UIImage *image = nil;
    NSString *fileSize = @"";
    NSString *timeStamp = @"";
    if ([item isKindOfClass:[KxSMBItemTree class]]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        image = [UIImage imageNamed:@"folder.png"];
        cell.imageView.tintColor = [UIColor colorWithRed:0.94 green:0.86 blue:0.74 alpha:1];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        fileSize = [NSString stringWithFormat:@"%ld KB", item.stat.size / 1000];
        timeStamp = [NSString stringWithFormat:@"%@", item.stat.lastModified];
        image = [UIImage imageNamed:@"file.png"];
        cell.imageView.tintColor = [UIColor colorWithRed:0.93 green:0.94 blue:0.95 alpha:1];
    }
    if (timeStamp.length) {
        timeStamp = [timeStamp substringToIndex:16];
    }
    
    cell.textLabel.text = item.path.lastPathComponent;
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    
    cell.detailTextLabel.textColor = [UIColor customGrayColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@     %@", timeStamp, fileSize];
    cell.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    KxSMBItem *item = _items[indexPath.row];
    if ([item isKindOfClass:[KxSMBItemTree class]]) {
        if ([self.delegate respondsToSelector:@selector(pushMasterViewController:)]) {
                [self.delegate pushMasterViewController:item];
        }
    } else if ([item isKindOfClass:[KxSMBItemFile class]]) {
        if ([self.delegate respondsToSelector:@selector(pushDetailViewController:)]) {
            [self.delegate pushDetailViewController:item];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        KxSMBItem *item = _items[indexPath.row];
        [[KxSMBProvider sharedSmbProvider] removeAtPath:item.path block:^(id result) {
            
            if (![result isKindOfClass:[NSError class]]) {
                [self.tableView reloadData];
            }
        }];        
    }
}

#pragma mark - OPNSearchResultTableViewController Delegate
// 検索結果テーブルの選択時に SplitView Controllerのデリゲートメソッドを呼び出す
- (void)searchResultView:(OPNSearchResultTableViewController *)searchResultView didSelectItem:(KxSMBItem *)item {
    // オーバーレイを削除する
    [self.overlayView removeFromSuperview];
    self.overlayView = nil;
    
    // 検索フィールドのフォーカスを外す
    UITextField *textField = [self findTextFieldOfSearchBar:self.searchBar];
    [textField resignFirstResponder];
    
    if ([item isKindOfClass:[KxSMBItemTree class]]) {
        if ([self.delegate respondsToSelector:@selector(pushMasterViewController:)]) {
            [self.delegate pushMasterViewController:item];
        }
    } else if ([item isKindOfClass:[KxSMBItemFile class]]) {
        if ([self.delegate respondsToSelector:@selector(pushDetailViewController:)]) {
            [self.delegate pushDetailViewController:item];
        }
    }
}

#pragma mark - Search ItemName
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.tableView.scrollEnabled = YES;
    self.searchBar.showsCancelButton = NO;
    UITextField *textField = [self findTextFieldOfSearchBar:searchBar];
    textField.text = @"";
    [textField resignFirstResponder];
    [self.resultsTableVc.view removeFromSuperview];
    [self.overlayView removeFromSuperview];
    self.overlayView = nil;
}

- (UITextField *)findTextFieldOfSearchBar:(UIView *)searchBar
{
    for (UIView *view in searchBar.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            return (UITextField *) view;
        } else {
            UITextField *textField = [self findTextFieldOfSearchBar:view];
            if (textField) {
                return textField;
            }
        }
    }
    return nil;
}

- (void)updateFilteredContentForSmbItemName:(NSString *)smbItemName
{
    // 検索結果配列の初期化
    self.smbItemSearchResult = [@[] mutableCopy];
    
    //検索対象の文字列がない場合
    if ((smbItemName == nil) || [smbItemName length] == 0)
    {
        [self.smbItemSearchResult removeAllObjects];
        return;
    }

    for (KxSMBItem *item in _items) {
        NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
        NSString *itemName = [item.path lastPathComponent];
        NSRange itemNameRange = NSMakeRange(0, itemName.length);
        NSRange foundRange = [itemName rangeOfString:smbItemName options:searchOptions range:itemNameRange];
        if (foundRange.length > 0)
        {
            //文字列がマッチしていれば検索結果のためのNSMutableArrayに追加
            [self.smbItemSearchResult addObject:item];
        }
    }
    
    // 新たにテーブルビューを生成してオーバーレイビューの上に表示する
    if (self.smbItemSearchResult) {
        [self appearSearchResultTableView];
    }
}

- (void)appearSearchResultTableView {
    self.resultsTableVc = [OPNSearchResultTableViewController new];
    self.resultsTableVc.view.frame = CGRectMake(0, 44, 320, self.tableView.height);
    self.resultsTableVc.searchResults = self.smbItemSearchResult;
    self.resultsTableVc.delegate = self;
    
    [self.view addSubview:self.resultsTableVc.view];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
    
    // 検索フィールドに文字列がある場合はオーバレイを表示しない
    if (self.searchBar.text.length) return;
    
    // ツリービューの上からviewControllerをオーバーレイ表示する
    if (!self.overlayView) {
        self.overlayView = [self generateOverlayView];
        [self.view addSubview:self.overlayView];
    }
    
    self.tableView.scrollEnabled = NO;
}

- (UIView*)generateOverlayView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, self.tableView.height)];
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.4;
    [view addGestureRecognizer:[self getSingleTapGestureRecognizer]];
    return view;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length > 0 && !self.overlayView) {
        self.overlayView = [self generateOverlayView];
        [self.view addSubview:self.overlayView];
    }
    [self.resultsTableVc.view removeFromSuperview];
    [self updateFilteredContentForSmbItemName:searchText];
}

- (void)didTapOnView {
    [self searchBarCancelButtonClicked:self.searchBar];
}

#pragma mark - Gesture Recognizer
- (UITapGestureRecognizer*)getSingleTapGestureRecognizer {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnView)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    return singleTap;
}

#pragma mark - NSObject
- (NSString *)description
{
    return [NSString stringWithFormat:@"TreeViewController description:\n%@ delegate: %@\npath: %@\n",[super description], self.delegate, self.path];
}



@end
