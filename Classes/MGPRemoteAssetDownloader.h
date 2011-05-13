//
//  MGPRemoteAssetDownloader.h
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/9/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MGPRemoteAssetDownloader : NSObject {
    
}

@property (nonatomic, copy) NSString *downloadPath;
@property (nonatomic, retain) NSURL *URL;
@property (nonatomic, retain) NSFileManager *fileManager;
@property (nonatomic, readonly, retain) NSFileHandle *writeHandle;

- (void) beginDownload;

@end
