//
//  HomeWebViewController.m
//  MyHome
//
//  Created by DHSoft on 16/8/31.
//  Copyright © 2016年 DHSoft. All rights reserved.
//

#import "HomeWebViewController.h"
#import <WebKit/WKWebView.h>

@interface HomeWebViewController ()

@end

@implementation HomeWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(leftBarButtonItemAct)];
    
    [self HomeWebView];
    
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor redColor];
    button.frame = CGRectMake(0, 0, 200, 200);
    [self.view addSubview:button];
    [button addTarget:self action:@selector(leftBarButtonItemAct) forControlEvents:UIControlEventTouchUpInside];
}

- (void)leftBarButtonItemAct {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)HomeWebView
{
    WKWebView *webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    [self.view addSubview:webView];
    
    
    NSURL *url = [NSURL URLWithString:self.urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [webView loadRequest:request];

    
    if(self.AppDelegateSele == -1){
          self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    }
    
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (NSString *)urlStr
{
    if(_urlStr == nil)
    {
        _urlStr = [NSString string];
    }
    return _urlStr;
}

@end
