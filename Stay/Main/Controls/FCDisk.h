//
//  FCDisk.h
//  fastclipcore
//
//  Created by ris on 2021/12/23.
//

/**
 This is a class support write/read with the disk
 */
#import <Foundation/Foundation.h>

@protocol FCArchiving
@required
// Return nil will not trigger - beginWriteData & endWriteData.
- (NSData *_Nullable)archiveData;
- (void)unarchiveData:(NSData *_Nullable)data;
- (dispatch_queue_t _Nonnull )dispatchQueue;

@optional
- (nullable NSObject *)logicalLockOnWirte;
- (void)beginWriteData;
- (void)endWriteData;
@end

NS_ASSUME_NONNULL_BEGIN
@interface FCDisk : NSObject<FCArchiving>{
    NSURL *_url; /* File/Directory url */
}
// Subclass must implement this method.
- (instancetype)initWithPath:(NSString *)path isDirectory:(BOOL)isDirectory;
// Create a new instance under the disk path.
- (instancetype)initUnder:(FCDisk *)disk
             relativePath:(NSString *)relativePath
              isDirectory:(BOOL)isDirectory;

// - readAtOffset & - readAtOffsetToEnd have lock to guarantee read sync from disk.
- (NSData *)readAtOffset:(NSUInteger)offset length:(NSUInteger)length;
- (NSData *)readAtOffsetToEnd:(NSUInteger)offset;

// Load disk data to memory.
- (void)loadSync:(BOOL)sync;
// Flush archive data to disk.
- (void)flush;
// Remove self from the disk.
- (void)remove;

// - initWithPath:isDirectory: & - initUnder:relativePath:isDirectory: always call onInit;
- (void)onInit;

// Indicate if you need init your object with the disk file.
+ (BOOL)unarchiveOnInit;
/* If the file is empty or have not been created yet, you can use implement
   this method to init your object.*/
- (void)initOnEmpty;
- (NSString *)queueName:(NSString *)name;

@property (readonly) NSURL *url;
@property (readonly) NSString *path;
@property (readonly) BOOL isDirectory;
@property (readonly) NSFileHandle *readFH;
@property (readonly) NSFileHandle *writeFH;
@property (readonly) BOOL isEmptyFile;

@property (nonatomic, copy) NSData *(^encrypt)(NSData *);
@property (nonatomic, copy) NSData *(^dencrypt)(NSData *);
@end

NS_ASSUME_NONNULL_END
