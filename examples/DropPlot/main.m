//
//  main.m
//  DropPlot
//
//  Created by Brad Larson on 6/9/2009.
//  Copyright SonoPlot, Inc. 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    return NSApplicationMain(argc, (const char **)argv);
}

// From here to end of file added by Injection Plugin //

#ifdef DEBUG
static char _inMainFilePath[] = __FILE__;
static const char *_inIPAddresses[] = {"127.0.0.1", "192.168.137.199", "192.168.1.105", NULL};

#define INJECTION_ENABLED
#import "/Applications/Injection Plugin.app/Contents/Resources/BundleInjection.h"
#endif
