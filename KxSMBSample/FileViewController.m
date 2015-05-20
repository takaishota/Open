//
//  FileViewController.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/20..
//


#import "FileViewController.h"
// :: Other ::
#import "FileUtility.h"
#import "KxSMBProvider.h"
#import "UIImage+Utility.h"
#import "LoginStatusManager.h"
#import "TopViewController.h"
#import "TreeViewController.h"

@interface FileViewController () <UIGestureRecognizerDelegate>
@property (nonatomic) TopViewController *topViewController;
@end

@implementation FileViewController {
    UIProgressView  *_downloadProgress;
    UILabel         *_downloadLabel;
    NSString        *_filePath;
    NSFileHandle    *_fileHandle;
    long            _downloadedBytes;
    NSDate          *_timestamp;
    UIWebView       *_webView;
    BOOL            _treeViewIsHidden;
    BOOL            _isNavigationBarHidden;
    BOOL            _currentFileIsPdf;
}
const static CGFloat masterViewWidth = 320.0f;

#pragma mark - Lifecycle
- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    [self closeFiles];
}

- (void)loadView {
    self.view                 = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];

    [self downloadAction];

    NSString *fileName        = [[_smbFile.path componentsSeparatedByString:@"/"] lastObject];
    self.navigationItem.title = fileName;

    _downloadLabel            = [self setupDownloadLabel];
    _downloadProgress         = [self setupDownloadProgress];

    [self.view addSubview:_downloadLabel];
    [self.view addSubview:_downloadProgress];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    self.view.backgroundColor = FILE_BACKGROUND_COLOR;
    
    if ([self isLandscape]) {
        _treeViewIsHidden = NO;
    } else {
        _treeViewIsHidden = YES;
    }
    _isNavigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateLeftBarButtonItem];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    if ([LoginStatusManager sharedManager].isLaunchedApp) {
        self.topViewController = [TopViewController new];
        self.topViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:self.topViewController animated:YES completion:nil];
    }
    self.navigationController.hidesBarsOnSwipe = YES;
    self.navigationController.hidesBarsOnTap   = YES;
}

const static CGFloat masterViewWidth = 320.0f;

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGRect windowSize = [[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
    _webView.frame    = CGRectMake(0, _webView.frame.origin.y, windowSize.size.height - masterViewWidth, windowSize.size.width);
    }else {
    _webView.frame    = CGRectMake(0, _webView.frame.origin.y, windowSize.size.width, windowSize.size.height);
    }
}

#pragma mark - Private
- (BOOL)isLandscape {
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)updateLeftBarButtonItem {
    UIImage *btnImg                          = [[UIImage alloc] initWithTreeViewStatus:_treeViewIsHidden];
    UINavigationController *navController    = (UINavigationController*)self.parentViewController;

    UIViewController *lastrVc                = [navController.viewControllers lastObject];
    lastrVc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:btnImg
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                        action:@selector(resizeFileView)];
}

- (void)closeFiles {
    if (_fileHandle) {
        
        [_fileHandle closeFile];
        _fileHandle = nil;
    }
    
    [_smbFile close];
}

- (void)closeCurrentFile:(UIView*)view {
    [_webView removeFromSuperview];
    [[FileUtility sharedUtility] removeFileAtPath:_filePath];
    _webView   = nil;
    _filePath  = nil;
    [self.navigationItem setRightBarButtonItems:nil animated:YES];
    self.title = @"";
}

- (UILabel*)setupDownloadLabel {
    const float W                  = self.view.bounds.size.width;
    UILabel *downloadLabel         = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, W - 20, 40)];
    downloadLabel.font             = [UIFont systemFontOfSize:14];;
    downloadLabel.textColor        = [UIColor darkTextColor];
    downloadLabel.opaque           = NO;
    downloadLabel.backgroundColor  = [UIColor clearColor];
    downloadLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    downloadLabel.numberOfLines    = 2;
    
    return downloadLabel;
}

- (UIProgressView*)setupDownloadProgress {
    const float W                = self.view.bounds.size.width;
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _downloadProgress.frame      = CGRectMake(10, 190, W - 20, 30);
    _downloadProgress.hidden     = YES;
    
    return progressView;
}

- (void)downloadAction {
    if (!_fileHandle) {
        
        NSString *folder   = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                NSUserDomainMask,
                                                                YES) lastObject];
        NSString *filename = _smbFile.path.lastPathComponent;
        _filePath          = [folder stringByAppendingPathComponent:filename];

        NSFileManager *fm  = [[NSFileManager alloc] init];
        if ([fm fileExistsAtPath:_filePath])
            [fm removeItemAtPath:_filePath error:nil];
        [fm createFileAtPath:_filePath contents:nil attributes:nil];
        
        // ???:アプリ起動時にDocumentsフォルダではなくDocumentsファイルができてしまい、ファイルを保存できないので削除してからDocumentsフォルダを作成する
        //     なぜファイルができるかは不明。
        NSArray *paths             = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *dir              = [paths objectAtIndex:0];
        BOOL isDirectory;
        if(!([fm fileExistsAtPath:dir isDirectory:&isDirectory] && isDirectory)) {
            NSLog(@"Documentsフォルダが存在しません");
        BOOL resultRemoveFile      = [fm removeItemAtPath:dir error:nil];
        BOOL resultCreateDirectory = [fm createDirectoryAtPath:dir
                   withIntermediateDirectories:YES
                                    attributes:nil error:nil];
            if (!resultRemoveFile) {
                NSLog(@"Documentsファイルの削除に失敗しました");
            } else if (!resultCreateDirectory) {
                NSLog(@"Documentsフォルダの作成に失敗しました");
            }
        }
        
        NSError *error;
        _fileHandle = [NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:_filePath]
                                                        error:&error];
 
        if (_fileHandle) {
        
            _downloadLabel.text        = @"starting ..";

            _downloadedBytes           = 0;
            _downloadProgress.progress = 0;
            _downloadProgress.hidden   = NO;
            _timestamp                 = [NSDate date];
            
            [self download];
            
        } else {
            
            _downloadLabel.text = [NSString stringWithFormat:@"failed: %@", error.localizedDescription];
        }
        
    } else {
        _downloadLabel.text = @"cancelled";
        [self closeFiles];
    }
}

-(void)updateDownloadStatus:(id)result {
    if ([result isKindOfClass:[NSError class]]) {
         
        NSError *error           = result;

        _downloadLabel.text      = [NSString stringWithFormat:@"failed: %@", error.localizedDescription];
        _downloadProgress.hidden = YES;
       [self closeFiles];
        
    } else if ([result isKindOfClass:[NSData class]]) {
        
        NSData *data = result;
                
        if (data.length == 0) {
            
            [self closeFiles];
            
        } else {
            
            NSTimeInterval time        = -[_timestamp timeIntervalSinceNow];

            _downloadedBytes           += data.length;
            _downloadProgress.progress = (float)_downloadedBytes / (float)_smbFile.stat.size;
            
            CGFloat value;
            NSString *unit;
            
            if (_downloadedBytes < 1024) {
                
                value = _downloadedBytes;
                unit  = @"B";
                
            } else if (_downloadedBytes < 1048576) {
                
                value = _downloadedBytes / 1024.f;
                unit = @"KB";
                
            } else {
                
                value = _downloadedBytes / 1048576.f;
                unit = @"MB";
            }
            
            _downloadLabel.text = [NSString stringWithFormat:@"downloaded %.1f%@ (%.1f%%) %.2f%@s",
                                   value, unit,
                                   _downloadProgress.progress * 100.f,
                                   value / time, unit];
            if (_fileHandle) {
                
                [_fileHandle writeData:data];
                
                if(_downloadedBytes == _smbFile.stat.size) {
                    [self closeFiles];
                    
                    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeCurrentFile:)];
                    
                    // webViewを生成する
                    UIWebView *view = [self generateWebView];
                    [self.view addSubview:view];
                    _webView = view;
                    [_downloadLabel removeFromSuperview];
                    
                } else {
                    [self download];
                }
            }
        }
    } else {
        NSAssert(false, @"bugcheck");
    }
}

- (UIWebView*)generateWebView {
    UIWebView *webView       = [UIWebView new];
    webView.scalesPageToFit  = YES;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    webView.frame            = CGRectMake(0,
                               0,
                               self.view.frame.size.width,
                               self.view.frame.size.height);
    webView.contentMode      = UIViewContentModeScaleAspectFit;
    webView.userInteractionEnabled = YES;
    
    [webView addGestureRecognizer:[self getSingleTapGestureRecognizer]];
    [webView addGestureRecognizer:[self getScrollUpGestureRecognizer]];
    [webView addGestureRecognizer:[self getScrollDownGestureRecognizer]];
    
    if ([@[@"txt"] containsObject:[[_smbFile.path pathExtension] lowercaseString]]) {
        NSString *str = [[NSString alloc] initWithContentsOfFile:_filePath
                                                        encoding:NSUTF8StringEncoding
                                                           error:nil];
        [webView loadHTMLString:str baseURL:nil];
    } else {
        NSURLRequest *urlrequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:_filePath]];
        [webView loadRequest:urlrequest];
        
    }
    if ([@[@"pdf"] containsObject:[[_smbFile.path pathExtension] lowercaseString]]) {
        _currentFileIsPdf = YES;
    } else {
        _currentFileIsPdf = NO;
    }
    return webView;
}

- (void)didTapOnView {
    if (_currentFileIsPdf) return;
    if (_isNavigationBarHidden) {
        [self showNavigationToolBar];
    } else {
        [self hideNavigationToolBar];
    }
    _isNavigationBarHidden = !_isNavigationBarHidden;
}

- (void)didScrollUpView {
    if (_currentFileIsPdf) return;
    if (!_isNavigationBarHidden) {
        [self hideNavigationToolBar];
        _isNavigationBarHidden = YES;
    }
}

- (void)didScrollDownView {
    if (_currentFileIsPdf) return;
    if (_isNavigationBarHidden) {
        [self showNavigationToolBar];
        _isNavigationBarHidden = NO;
    }
}

- (void)download {
    __weak __typeof(self) weakSelf = self;
    [_smbFile readDataOfLength:32768
                         block:^(id result)
    {
        FileViewController *p = weakSelf;
        //if (p && p.isViewLoaded && p.view.window) {
        if (p) {
            [p updateDownloadStatus:result];
        }
    }];
}

- (void)resizeFileView {
    NSLog(@"self.view: %@",self.view);
    NSLog(@"treeViewIsHidden: %d",_treeViewIsHidden);


    if ([self isLandscape]) {
        [self updateLeftBarButtonItem];
    }
    // primaryViewを閉じる
    if (_treeViewIsHidden) {
        if ([self.delegate respondsToSelector:@selector(showTreeView)]) {
            [self.delegate showTreeView];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(hideTreeView)]) {
            [self.delegate hideTreeView];
    }
    
    }
    _treeViewIsHidden = !_treeViewIsHidden;
}

- (UITapGestureRecognizer*)getSingleTapGestureRecognizer {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnView)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    return singleTap;
}

- (UISwipeGestureRecognizer*)getScrollUpGestureRecognizer {
    UISwipeGestureRecognizer *scrollUpGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(didScrollUp)];
    scrollUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:scrollUpGesture];
    return scrollUpGesture;
}

- (UISwipeGestureRecognizer*)getScrollDownGestureRecognizer {
    UISwipeGestureRecognizer *scrollDownGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(didScrollDown)];
    scrollDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:scrollDownGesture];
    return scrollDownGesture;
}

- (void)showNavigationToolBar {
    UINavigationBar *navBar = self.navigationController.navigationBar;
    float animationDuration = 0.1;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    navBar.frame = CGRectMake(navBar.frame.origin.x,
                              -navBar.frame.size.height + 20,
                              navBar.frame.size.width,
                              navBar.frame.size.height);
    
    [UIView animateWithDuration:animationDuration animations:^{
        navBar.frame = CGRectMake(navBar.frame.origin.x,
                                  20,
                                  navBar.frame.size.width,
                                  navBar.frame.size.height);
    }];
    
    
//    UIToolbar *toolBar = self.navigationController.toolbar;
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    float height;
//    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
//        height = screenRect.size.height;
//    } else {
//        height  = screenRect.size.width;
//    }
//    
//    [self.navigationController setToolbarHidden:NO animated:NO];
//    toolBar.frame = CGRectMake(toolBar.frame.origin.x,
//                               height,
//                               toolBar.frame.size.width,
//                               toolBar.frame.size.height);
//    
//    [UIView animateWithDuration:animationDuration animations:^{
//        toolBar.frame = CGRectMake(toolBar.frame.origin.x,
//                                   height - toolBar.frame.size.height,
//                                   toolBar.frame.size.width,
//                                   toolBar.frame.size.height);
//    }];
}

- (void)hideNavigationToolBar {
    UINavigationBar *navBar = self.navigationController.navigationBar;
    float animationDuration = 0.1;
    
    [UIView animateWithDuration:animationDuration animations:^{
        navBar.frame = CGRectMake(navBar.frame.origin.x,
                                  -navBar.frame.size.height + 20,
                                  navBar.frame.size.width,
                                  navBar.frame.size.height);
    } completion:^(BOOL finished) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }];
    
    
//    UIToolbar *toolBar = self.navigationController.toolbar;
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    
//    [UIView animateWithDuration:animationDuration animations:^{
//        toolBar.frame = CGRectMake(toolBar.frame.origin.x,
//                                   screenRect.size.height,
//                                   toolBar.frame.size.width,
//                                   toolBar.frame.size.height);
//    } completion:^(BOOL finished) {
//        [self.navigationController setToolbarHidden:YES animated:NO];
//    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - NSObject
- (NSString *)description {
    return [NSString stringWithFormat:@"FileViewController description:\n%@ delegate: %@\nsmbFile: %@\n",[super description], self.delegate, self.smbFile];
}

@end