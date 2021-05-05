#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "IRHCError.h"
#import "IRHCLog.h"
#import "IRHCMacro.h"
#import "IRHCRange.h"
#import "IRHCData+Internal.h"
#import "IRHCDataCacheItem.h"
#import "IRHCDataCacheItemZone.h"
#import "IRHCDataCallback.h"
#import "IRHCDataFileSource.h"
#import "IRHCDataLoader.h"
#import "IRHCDataNetworkSource.h"
#import "IRHCDataReader.h"
#import "IRHCDataRequest.h"
#import "IRHCDataResponse.h"
#import "IRHCDataSource.h"
#import "IRHCDataSourceManager.h"
#import "IRHCDataStorage.h"
#import "IRHCDataUnit.h"
#import "IRHCDataUnitItem.h"
#import "IRHCDataUnitPool.h"
#import "IRHCDataUnitQueue.h"
#import "IRHCDownload.h"
#import "IRHCHTTPConnection.h"
#import "IRHCHTTPHeader.h"
#import "IRHCHTTPResponse.h"
#import "IRHCHTTPServer.h"
#import "IRHCPathTool.h"
#import "IRHCURLTool.h"
#import "IRHTTPCache.h"

FOUNDATION_EXPORT double IRHTTPCacheVersionNumber;
FOUNDATION_EXPORT const unsigned char IRHTTPCacheVersionString[];

