//
//  KQTabBarController.m
//  Microphone
//
//  Created by Kira Ryouta on 2025/04/03.
//
//
// These codes are licensed under CC0.
// https://creativecommons.org/publicdomain/zero/1.0/
//

#import "KQTabBarController.h"

@interface KQTabBarController ()

@end

@implementation KQTabBarController
{
    UITabBar *alternateTabBar;
    NSLayoutConstraint *tabBarHeightConstraint;
}

- (void)checkTabBar
{
    if (@available(iOS 18, *)) {
        UITraitCollection *traitCollection = self.traitCollection;
        if (traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular &&
            traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular && !alternateTabBar)
        {
            self.tabBarHidden = YES;
            UITabBar *tabBar = self.tabBar;
            tabBar.hidden = YES;
            alternateTabBar = [[UITabBar alloc] init];
            alternateTabBar.items = tabBar.items;
            alternateTabBar.selectedItem = tabBar.selectedItem;

            UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
            appearance.backgroundColor = [UIColor tertiarySystemBackgroundColor];
            alternateTabBar.standardAppearance = appearance;

            UIView *view = self.view;
            [view addSubview:alternateTabBar];

            alternateTabBar.translatesAutoresizingMaskIntoConstraints = NO;
            tabBarHeightConstraint = [alternateTabBar.heightAnchor constraintEqualToConstant:1.];

            [view addConstraints:@[
                [alternateTabBar.bottomAnchor constraintEqualToAnchor:view.bottomAnchor],
                [alternateTabBar.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
                [alternateTabBar.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
                tabBarHeightConstraint,
            ]];
        }
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    [self checkTabBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self checkTabBar];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    if (alternateTabBar) {
        alternateTabBar.items = self.tabBar.items;
        alternateTabBar.selectedItem = self.tabBar.selectedItem;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    if (alternateTabBar) {
        CGFloat height = alternateTabBar.intrinsicContentSize.height;
        tabBarHeightConstraint.constant = height;

        UIEdgeInsets insets = UIEdgeInsetsZero;
        insets.bottom = alternateTabBar.frame.size.height - self.view.safeAreaInsets.bottom;
        for (UIViewController *viewController in self.viewControllers) {
            viewController.additionalSafeAreaInsets = insets;
        }
    }
}

@end
