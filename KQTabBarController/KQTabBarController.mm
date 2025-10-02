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
#import <atomic>

@interface KQTabBarController ()

@end

@implementation KQTabBarController
{
    UITabBar *alternateTabBar;
    NSLayoutConstraint *tabBarHeightConstraint;
    std::atomic<bool> recursive;
}

static void* observeContext = &observeContext;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context == observeContext) {
        UITabBar *tabbar = self.tabBar;
        if (alternateTabBar == object) {
            if ([keyPath isEqualToString:@"selectedItem"] && !recursive) {
                recursive = true;
                NSUInteger index = [alternateTabBar.items indexOfObject:alternateTabBar.selectedItem];
                id delegate = self.delegate;
                if (index != NSNotFound) {
                    if (![delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)] || [delegate tabBarController:self shouldSelectViewController:self.viewControllers[index]]) {
                        [self setSelectedIndex:index];
                    }
                    else {
                        UITabBarItem *item = tabbar.selectedItem;
                        alternateTabBar.selectedItem = item;
                    }
                }
                recursive = false;
            }
        }
        else if (tabbar == object) {
            if ([keyPath isEqualToString:@"selectedItem"] && !recursive) {
                recursive = true;
                alternateTabBar.selectedItem = tabbar.selectedItem;
                recursive = false;
            }
        }
    }
    else {
        if ([UITabBarController instancesRespondToSelector:@selector(observeValueForKeyPath:ofObject:change:context:)]) {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}

- (void)dealloc
{
    if (@available(iOS 26, *)) {
        if (alternateTabBar) {
            UITabBar *tabbar = self.tabBar;
            [tabbar removeObserver:self forKeyPath:@"selectedItem"];
            [alternateTabBar removeObserver:self forKeyPath:@"selectedItem"];
        }
    }
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
            if (@available(iOS 26, *)) {
                [tabBar addObserver:self forKeyPath:@"selectedItem" options:0 context:observeContext];
                [alternateTabBar addObserver:self forKeyPath:@"selectedItem" options:0 context:observeContext];
            }

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (@available(iOS 18.0, *)) {
        [self checkTabBar];

        __weak KQTabBarController *weakSelf = self;
        [self registerForTraitChanges:@[UITraitHorizontalSizeClass.class, UITraitVerticalSizeClass.class] withHandler:^(__kindof id<UITraitEnvironment>  _Nonnull traitEnvironment, UITraitCollection * _Nonnull previousCollection) {
            [weakSelf checkTabBar];
        }];
    }
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
