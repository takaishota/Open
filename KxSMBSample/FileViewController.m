//
//  FileViewController.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/20..
//


#import "FileViewController.h"
#import "TreeViewController.h"
#import "FileUtility.h"
#import "KxSMBProvider.h"

@interface FileViewController ()
@property (strong, nonatomic) UIPopoverController *menuPopoverController;
@property (nonatomic) CGFloat navigationBarHeight;
@property (nonatomic) BOOL isHidden;
@end

@implementation FileViewController {
    
    UIProgressView  *_downloadProgress;
    UILabel         *_downloadLabel;
    NSString        *_filePath;
    NSFileHandle    *_fileHandle;
    long            _downloadedBytes;
    NSDate          *_timestamp;
    UIWebView       *_webView;
}

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
    }
    return self;
}

- (void) dealloc
{
    [self closeFiles];
}

- (void) loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self downloadAction];
    
    NSString *fileName = [[_smbFile.path componentsSeparatedByString:@"/"] lastObject];
    self.navigationItem.title = fileName;
    
    const float W = self.view.bounds.size.width;
    
    _downloadLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, W - 20, 40)];
    _downloadLabel.font = [UIFont systemFontOfSize:14];;
    _downloadLabel.textColor = [UIColor darkTextColor];
    _downloadLabel.opaque = NO;
    _downloadLabel.backgroundColor = [UIColor clearColor];
    _downloadLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _downloadLabel.numberOfLines = 2;
    
    _downloadProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _downloadProgress.frame = CGRectMake(10, 190, W - 20, 30);
    _downloadProgress.hidden = YES;

    [self.view addSubview:_downloadLabel];
    [self.view addSubview:_downloadProgress];    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    self.isHidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    // ランドスケープ時のみ
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        [self setupDrawBackButton];
    }
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];    
    //[self closeFiles];
}

- (void) setupDrawBackButton {
    UIImage *rawImg = [UIImage imageNamed:@"left.png"];
    UIImage *resizeImg;
    CGFloat width = 28;
    CGFloat height = 28;
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [rawImg drawInRect:CGRectMake(0, 0, width, height)];
    resizeImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:resizeImg style:UIBarButtonItemStylePlain target:self action:@selector(drawBackTree)];
}

- (void) closeFiles
{
    if (_fileHandle) {
        
        [_fileHandle closeFile];
        _fileHandle = nil;
    }
    
    [_smbFile close];
}

- (void) drawBackTree {
    NSLog(@"draw back button");
    [self drawAnimationPopOverController];
}

- (void) downloadAction
{
    if (!_fileHandle) {
        
        NSString *folder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                NSUserDomainMask,
                                                                YES) lastObject];
        NSString *filename = _smbFile.path.lastPathComponent;
        _filePath = [folder stringByAppendingPathComponent:filename];
        
        NSFileManager *fm = [[NSFileManager alloc] init];
        if ([fm fileExistsAtPath:_filePath])
            [fm removeItemAtPath:_filePath error:nil];
        [fm createFileAtPath:_filePath contents:nil attributes:nil];
        
        // ???:アプリ起動時にDocumentsフォルダではなくDocumentsファイルができてしまい、ファイルを保存できないので削除してからDocumentsフォルダを作成する
        //     なぜファイルができるかは不明。
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *dir = [paths objectAtIndex:0];
        BOOL isDirectory;
        if(!([fm fileExistsAtPath:dir isDirectory:&isDirectory] && isDirectory)) {
            NSLog(@"Documentsフォルダが存在しません");
            BOOL resultRemoveFile = [fm removeItemAtPath:dir error:nil];
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
        
            _downloadLabel.text = @"starting ..";
            
            _downloadedBytes = 0;
            _downloadProgress.progress = 0;
            _downloadProgress.hidden = NO;
            _timestamp = [NSDate date];
            
            [self download];
            
        } else {
            
            _downloadLabel.text = [NSString stringWithFormat:@"failed: %@", error.localizedDescription];
        }
        
    } else {
        _downloadLabel.text = @"cancelled";
        [self closeFiles];
    }
}

- (void)closeCurrentFile:(UIView*)view {
    [_webView removeFromSuperview];
    [[FileUtility sharedUtility] removeFileAtPath:_filePath];
    _webView = nil;
    _filePath = nil;
    [self.navigationItem setRightBarButtonItems:nil animated:YES];
    self.title = @"";
}

-(void) updateDownloadStatus: (id) result
{
    if ([result isKindOfClass:[NSError class]]) {
         
        NSError *error = result;
        
        _downloadLabel.text = [NSString stringWithFormat:@"failed: %@", error.localizedDescription];
        _downloadProgress.hidden = YES;        
       [self closeFiles];
        
    } else if ([result isKindOfClass:[NSData class]]) {
        
        NSData *data = result;
                
        if (data.length == 0) {
            
            [self closeFiles];
            
        } else {
            
            NSTimeInterval time = -[_timestamp timeIntervalSinceNow];
            
            _downloadedBytes += data.length;
            _downloadProgress.progress = (float)_downloadedBytes / (float)_smbFile.stat.size;
            
            CGFloat value;
            NSString *unit;
            
            if (_downloadedBytes < 1024) {
                
                value = _downloadedBytes;
                unit = @"B";
                
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
                    // ファイルクローズボタンを生成する
                    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(closeCurrentFile:)];
                    
                    // 画像ファイルの場合、ImageViewに表示する
                    if([@[@"png",@"jpg",@"gif"] containsObject:[[_smbFile.path pathExtension] lowercaseString]]) {
                        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:_filePath]];
                        imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                        imageView.contentMode = UIViewContentModeScaleAspectFit;
                        [self.view addSubview:imageView];
                    } else {
                        UIWebView *webView = [[UIWebView alloc] init];
                        // TODO:画面回転時の対応
                        webView.frame = CGRectMake(0,
                                                   0,
                                                   self.view.frame.size.width,
                                                   self.view.frame.size.height);
                        webView.contentMode = UIViewContentModeScaleAspectFit;
                        NSURL *path = [NSURL fileURLWithPath:_filePath];
                        NSURLRequest *urlrequest = [NSURLRequest requestWithURL:path];
                        [webView loadRequest:urlrequest];
                        [self.view addSubview:webView];
                        _webView = webView;
                        [_downloadLabel removeFromSuperview];
                    }
                } else {
                    [self download];
                }
            }
        }
    } else {
        
        NSAssert(false, @"bugcheck");        
    }
}

- (void) download
{    
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

#pragma mark - split view delegate
// 縦向きになるときに呼ばれる
- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    // UIBarButtonItemのタイトルを設定し、自分のNavigationItemの左ボタンに設定する
    [self.navigationItem setLeftBarButtonItems:nil animated:YES];
    self.navigationItem.leftBarButtonItem = nil;
    self.menuPopoverController = nil;
    barButtonItem.title = @"Menu";
    self.navigationItem.leftBarButtonItem = barButtonItem;
    [self.navigationItem setLeftBarButtonItems:@[barButtonItem] animated:YES];
    self.menuPopoverController = pc;
    
}

// 横向きになるときに呼ばれる
- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // メニューボタンを削除、drawボタンを設定
    [self.navigationItem setLeftBarButtonItems:nil animated:YES];
    self.navigationItem.leftBarButtonItem = nil;
    self.menuPopoverController = nil;
    [self setupDrawBackButton];
}

// マスタビューが出てくるときに呼ばれる
- (void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController {
    
    // ランドスケープ時のみ
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        [self drawAnimationPopOverController];
    }
    
}

- (BOOL) splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return NO;
    }else {
        return YES;
    }
    
}

- (void)drawAnimationPopOverController {
    NSLog(@"--------button");
//    CGFloat xOffset = 0;
//    CGFloat statusBarHeight = 20.0f;
//    
//    if (self.isHidden) {
//        xOffset  = 320.0f;
//        self.isHidden = NO;
//    } else {
//        xOffset  = 0;
//        self.isHidden = YES;
//    }
//    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
//        self.view.frame = CGRectMake(xOffset, self.view.frame.origin.y, self.view.frame.size.width - xOffset, self.view.frame.size.height);
//        self.navigationController.navigationBar.frame = CGRectMake(xOffset,
//                                                                   0,
//                                                                   self.navigationController.navigationBar.frame.size.width - xOffset,
//                                                                   self.navigationBarHeight + statusBarHeight);
//    } completion:^ (BOOL finished){
//        // 完了時のコールバック
//        NSLog(@"finish Animation");
//    }];
//
}

@end
