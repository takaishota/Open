//
//  SettingsViewController.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/15.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = INFOCUS_UNDERLINE_COLOR;
}

- (void)viewDidAppear:(BOOL)animated {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 60, 10)];
    
    [btn setTitle:@"閉じる" forState:UIControlStateNormal];
    [btn setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    [self.view addSubview:btn];
    
    [btn addTarget:self action:@selector(dismissSettingsView) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissSettingsView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
