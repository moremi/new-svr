//
//  ViewController.m
//  new-svr
//
//  Created by Vlad on 05.07.16.
//  Copyright © 2016 Vlad. All rights reserved.
//

#import "ViewController.h"
#import "ITBonjourSession.h"
#import "ITBonjourPeersDetector.h"

@interface ViewController ()
@property (nonatomic) ITBonjourSession *session;
@property (nonatomic) ITBonjourPeersDetector *detector;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.session = [[ITBonjourSession alloc] initWithHostPeer:nil];
    self.detector = [[ITBonjourPeersDetector alloc] initWithServiceType:nil];
    // Do any additional setup after loading the view, typically from a nib.
}

@end
