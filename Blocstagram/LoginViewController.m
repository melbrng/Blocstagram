//
//  LoginViewController.m
//  Blocstagram
//
//  Created by Melissa Boring on 10/26/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "LoginViewController.h"
#import "DataSource.h"

@interface LoginViewController ()<UIWebViewDelegate>

@property (nonatomic, weak) UIWebView *webView;

@end

@implementation LoginViewController

NSString *const LoginViewControllerDidGetAccessTokenNotification = @"LoginViewControllerDidGetAccessTokenNotification";

- (NSString *)redirectURI
{
    return @"http://melbo.co";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    
    [self.view addSubview:webView];
    self.webView = webView;
    
    self.title = NSLocalizedString(@"Login", @"Login");

    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Home"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(backAction:)];
    self.navigationItem.rightBarButtonItem = homeButton;

    [self loadHomePage];
}

-(void)loadHomePage
{
    NSString *urlString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&scope=likes+comments+relationships&redirect_uri=%@&response_type=token", [DataSource instagramClientID], [self redirectURI]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (url)
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [self.webView loadRequest:request];
    }
}

-(void)backAction:(UIBarButtonItem *)sender{
    
    [self loadHomePage];
    
}

- (void) viewWillLayoutSubviews
{
    self.webView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
    
}

- (void) dealloc
{
    // Removing this line can cause a flickering effect when you relaunch the app after logging in, as the web view is briefly displayed, automatically authenticates with cookies, returns the access token, and dismisses the login view, sometimes in less than a second.
    [self clearInstagramCookies];
    
    self.webView.delegate = nil;
}

/**
 Clears Instagram cookies. This prevents caching the credentials in the cookie jar.
 */
- (void) clearInstagramCookies
{
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
    {
        NSRange domainRange = [cookie.domain rangeOfString:@"instagram.com"];
        
        if(domainRange.location != NSNotFound)
        {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = request.URL.absoluteString;
    
    if ([urlString hasPrefix:[self redirectURI]])
    {
        // This contains our auth token
        NSRange rangeOfAccessTokenParameter = [urlString rangeOfString:@"access_token="];
        NSUInteger indexOfTokenStarting = rangeOfAccessTokenParameter.location + rangeOfAccessTokenParameter.length;
        NSString *accessToken = [urlString substringFromIndex:indexOfTokenStarting];
        [[NSNotificationCenter defaultCenter] postNotificationName:LoginViewControllerDidGetAccessTokenNotification object:accessToken];
        
        return NO;
    }
    
    return YES;
}





@end
