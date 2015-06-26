//
//  OPNFileViewController.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/20..
//


#import "OPNFileViewController.h"
// :: Other ::
#import "FileUtility.h"
#import "KxSMBProvider.h"
#import "UIImage+Utility.h"
#import "LoginStatusManager.h"
#import "TopViewController.h"
#import "TreeViewController.h"
#import "UIView+Utility.h"
#import "OPNFileDataController.h"
#import "SplitViewController.h"

@interface OPNFileViewController () <UIGestureRecognizerDelegate>
@property (nonatomic) TopViewController *topViewController;
@property UIDocumentInteractionController *docInteractionController;
@end

@implementation OPNFileViewController {
    UIProgressView  *_downloadProgress;
    UILabel         *_downloadLabel;
    NSString        *_filePath;
    NSFileHandle    *_fileHandle;
    long            _downloadedBytes;
    NSDate          *_timestamp;
    UIWebView       *_webView;
}

#pragma mark - Lifecycle

- (void)dealloc {
    [self closeFiles];
}

- (void)loadView {
    self.view                 = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];

    [self downloadAction];

    NSString *fileName        = [[self.smbFile.path componentsSeparatedByString:@"/"] lastObject];
    self.navigationItem.title = fileName;

    _downloadLabel            = [self setupDownloadLabel];
    _downloadProgress         = [self setupDownloadProgress];

    [self.view addSubview:_downloadLabel];
    [self.view addSubview:_downloadProgress];
    
    // 回転イベントのNotification登録
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    self.view.backgroundColor = FILE_BACKGROUND_COLOR;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    
    [self updateLeftBarButtonItem];
}

#pragma mark - Private
- (void)updateLeftBarButtonItem {
    UIImage *btnImage;
    // ポートレイトの場合
    if ([[OPNFileDataController sharedInstance] isPortrait]) {
        btnImage = [[UIImage alloc] initWithUIImage:@"right.png"];
    } else {
        // ランドスケープでtreeViewが非表示の場合
        if ([OPNFileDataController sharedInstance].treeViewIsHidden) {
            btnImage = [[UIImage alloc] initWithUIImage:@"right.png"];
        } else {
            // ランドスケープでtreeViewが表示されている場合
            btnImage = [[UIImage alloc] initWithUIImage:@"left.png"];
        }
    }
    
    UINavigationController *navController    = (UINavigationController*)self.parentViewController;
    
    UIViewController *lastrVc                = [navController.viewControllers lastObject];
    lastrVc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:btnImage
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(resizeFileView)];
    self.navigationController.toolbarHidden = NO;
}

#pragma mark - Rotate
- (void)orientationDidChange
{
    // ランドスケープ → ポートレイト
    if ([[OPNFileDataController sharedInstance] isPortrait]) {
        [OPNFileDataController sharedInstance].treeViewIsHidden = YES;
        self.navigationController.parentViewController.view.x = 0;
        self.navigationController.parentViewController.view.width = [[UIScreen mainScreen] bounds].size.width;
        _webView.height = [[UIScreen mainScreen] bounds].size.height;;
        
    // ポートレイト → ランドスケープ
    } else if ([[OPNFileDataController sharedInstance] isLandscape]){
        [OPNFileDataController sharedInstance].treeViewIsHidden = NO;
        self.view.height = [[UIScreen mainScreen] bounds].size.height;
        _webView.height = [[UIScreen mainScreen] bounds].size.height;
    }
    [self updateLeftBarButtonItem];
}

#pragma mark - Push Resize Button
- (void)resizeFileView {
    if ([OPNFileDataController sharedInstance].treeViewIsHidden) {
        if ([self.delegate respondsToSelector:@selector(showTreeView)]) {
            [self.delegate showTreeView];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(hideTreeView)]) {
            [self.delegate hideTreeView];
        }
    }
    [OPNFileDataController sharedInstance].treeViewIsHidden = ![OPNFileDataController sharedInstance].treeViewIsHidden;
    
    // ランドスケープの時だけリサイズボタンの画像を変更する
    if ([[OPNFileDataController sharedInstance] isLandscape]) {
        [self updateLeftBarButtonItem];
    }
}

#pragma mark - Push Close Button
- (void)closeCurrentFile:(UIView*)view {
    [_webView removeFromSuperview];
    [[FileUtility sharedUtility] removeFileAtPath:_filePath];
    _webView   = nil;
    _filePath  = nil;
    [self.navigationItem setRightBarButtonItems:nil animated:YES];
    self.title = @"";
}

#pragma mark - WebView Dowonload
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
    progressView.frame      = CGRectMake(10, 190, W / 2 - 20, 30);
    progressView.hidden     = YES;
    
    return progressView;
}

- (void)downloadAction {
    if (!_fileHandle) {
        
        NSString *folder   = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                NSUserDomainMask,
                                                                YES) lastObject];
        NSString *filename = self.smbFile.path.lastPathComponent;
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

- (void)download {
    __weak __typeof(self) weakSelf = self;
    [self.smbFile readDataOfLength:32768
                         block:^(id result)
     {
         OPNFileViewController *p = weakSelf;
         //if (p && p.isViewLoaded && p.view.window) {
         if (p) {
             [p updateDownloadStatus:result];
         }
     }];
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
            _downloadProgress.progress = (float)_downloadedBytes / (float)self.smbFile.stat.size;
            
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
            _downloadProgress.hidden = NO;
            
            if (_fileHandle) {
                
                [_fileHandle writeData:data];
                
                if(_downloadedBytes == self.smbFile.stat.size) {
                    [self closeFiles];
                    
                    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeCurrentFile:)];
                    
                    [self setToolbar];
                    
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

-(void) setToolbar {
    // アプリのドキュメントディレクトリの参照を取得
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirPath = [paths objectAtIndex:0];
    NSString *filepath = [NSString stringWithFormat:@"%@/%@", documentsDirPath, self.smbFile.path.lastPathComponent];
    
    self.docInteractionController = [UIDocumentInteractionController
                                     interactionControllerWithURL:[NSURL fileURLWithPath:filepath]];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(switchOfficialApp:)];
    
    // ボタン追加
    UIBarButtonItem *flexibleButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[flexibleButton, button];
}

#pragma mark - Popover ViewController Handler
- (void)switchOfficialApp:(UIBarButtonItem*)sender {
    BOOL isValid;
    isValid = [self.docInteractionController presentOptionsMenuFromBarButtonItem:sender animated:YES];
    
    if (!isValid) {
        [self showAlert:@"データを開けるアプリケーションが見つかりません。"];
    }
}

- (void)showAlert:(NSString*)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)closeFiles {
    if (_fileHandle) {
        
        [_fileHandle closeFile];
        _fileHandle = nil;
    }
    
    [self.smbFile close];
}

- (UIWebView*)generateWebView {
    UIWebView *webView       = [UIWebView new];
    webView.scalesPageToFit  = YES;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    webView.frame            = CGRectMake(0,
                               [UIApplication sharedApplication].statusBarFrame.size.height,
                               self.view.frame.size.width,
                               self.view.frame.size.height);
    webView.contentMode      = UIViewContentModeScaleAspectFit;
    webView.userInteractionEnabled = YES;
    
    [webView addGestureRecognizer:[self getSingleTapGestureRecognizer]];
    [webView addGestureRecognizer:[self getScrollUpGestureRecognizer]];
    [webView addGestureRecognizer:[self getScrollDownGestureRecognizer]];
    
    if ([@[@"txt"] containsObject:[[self.smbFile.path pathExtension] lowercaseString]]) {
        NSError *error = nil;
        
        // 文字エンコードの判定
        NSStringEncoding encoding = NSUTF8StringEncoding;
        NSString *str = [[NSString alloc] initWithContentsOfFile:_filePath
                                                        encoding:encoding
                                                           error:&error];
        // TODO:他の文字コードも対応する（文字コードの配列を持っておいて判定する）
        if (error) {
            // TODO: alertを表示する（その他のエラー）
            NSLog(@"instance, file system or encoding errors");
            error = nil;
            encoding = NSShiftJISStringEncoding;
            str = [[NSString alloc] initWithContentsOfFile:_filePath
                                                  encoding:encoding
                                                     error:&error];
        }
        if (error) {
            // TODO: alertを表示する（その他のエラー）
            NSLog(@"instance, file system or encoding errors");
            error = nil;
        }
        
        
        NSMutableString *stringConvertedLineBreak = [NSMutableString string];
        [str enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
            [stringConvertedLineBreak appendString:line];
            [stringConvertedLineBreak appendString:@"<br/>"];
        }];
        [webView loadHTMLString:stringConvertedLineBreak baseURL:nil];
        
    } else {
        NSURLRequest *urlrequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:_filePath]];
        [webView loadRequest:urlrequest];
    }
    if ([@[@"pdf"] containsObject:[[self.smbFile.path pathExtension] lowercaseString]]) {
        [OPNFileDataController sharedInstance].currentFileIsPdf = YES;
    } else {
        [OPNFileDataController sharedInstance].currentFileIsPdf = NO;
    }
    return webView;
}

#pragma mark - WebView Gesture Recognizer
- (void)didTapOnView {
    if ([OPNFileDataController sharedInstance].currentFileIsPdf) return;
    if ([OPNFileDataController sharedInstance].isNavigationBarHidden) {
        [self showNavigationToolBar];
    } else {
        [self hideNavigationToolBar];
    }
    [OPNFileDataController sharedInstance].isNavigationBarHidden = ![OPNFileDataController sharedInstance].isNavigationBarHidden;
}

- (void)didScrollUpView {
    if ([OPNFileDataController sharedInstance].currentFileIsPdf) return;
    if (![OPNFileDataController sharedInstance].isNavigationBarHidden) {
        [self hideNavigationToolBar];
        [OPNFileDataController sharedInstance].isNavigationBarHidden = YES;
    }
}

- (void)didScrollDownView {
    if ([OPNFileDataController sharedInstance].currentFileIsPdf) return;
    if ([OPNFileDataController sharedInstance].isNavigationBarHidden) {
        [self showNavigationToolBar];
        [OPNFileDataController sharedInstance].isNavigationBarHidden = NO;
    }
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
                              -navBar.frame.size.height + statusBarHeight,
                              navBar.frame.size.width,
                              navBar.frame.size.height);
    
    [UIView animateWithDuration:animationDuration animations:^{
        navBar.frame = CGRectMake(navBar.frame.origin.x,
                                  20,
                                  navBar.frame.size.width,
                                  navBar.frame.size.height);
    }];
}

- (void)hideNavigationToolBar {
    UINavigationBar *navBar = self.navigationController.navigationBar;
    float animationDuration = 0.1;
    
    [UIView animateWithDuration:animationDuration animations:^{
        navBar.frame = CGRectMake(navBar.frame.origin.x,
                                  -navBar.frame.size.height + statusBarHeight,
                                  navBar.frame.size.width,
                                  navBar.frame.size.height);
    } completion:^(BOOL finished) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - NSObject
- (NSString *)description {
    return [NSString stringWithFormat:@"OPNFileViewController description:\n%@ delegate: %@\nsmbFile: %@\n",[super description], self.delegate, self.smbFile];
}

@end