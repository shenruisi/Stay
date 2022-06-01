//
//  FCDisk.m
//  fastclipcore
//
//  Created by ris on 2021/12/23.
//

#import "FCDisk.h"

#define FCDiskRename @".rename"
@interface FCDisk(){
    BOOL _isDirectory;
    BOOL _isEmptyFile;
    NSFileHandle *_readFH;
    NSFileHandle *_writeFH;
    NSString *_path;
}
@property (nonatomic, strong) NSURL *renameURL;
@property (nonatomic, strong) NSObject *readFHLock;
@end
@implementation FCDisk

- (instancetype)initWithPath:(NSString *)path isDirectory:(BOOL)isDirectory{
    if (self = [super init]){
        [self onInit];
        _path = path;
        _url = [NSURL fileURLWithPath:path];
        _isDirectory = isDirectory;
        _isEmptyFile = YES;
        
        //Create the directory first.
        NSString *directoryPath = _isDirectory ? _path : [_path stringByDeletingLastPathComponent];
        if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]){
            [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
        
        //Create file.
        if (!_isDirectory){
            if (![[NSFileManager defaultManager] fileExistsAtPath:_path]){
                [[NSFileManager defaultManager] createFileAtPath:_path contents:nil attributes:nil];
            }
            
            [self readFH];
            NSData *oneByte = [self.readFH readDataOfLength:1];
            _isEmptyFile = oneByte.length == 0;
            [self.readFH seekToFileOffset:0];
            if ([[self class] unarchiveOnInit]){
                if (!_isEmptyFile) [self _doLoad];
                else [self initOnEmpty];
            }
        }
    }

    return self;
}

- (instancetype)initUnder:(FCDisk *)disk
             relativePath:(NSString *)relativePath
              isDirectory:(BOOL)isDirectory{
    BOOL diskIsDirectory;
    [[NSFileManager defaultManager] fileExistsAtPath:[disk path] isDirectory:&diskIsDirectory];
    NSString *path = diskIsDirectory ? [[disk path] stringByAppendingPathComponent:relativePath] :
    [[[disk path] stringByDeletingLastPathComponent] stringByAppendingPathComponent:relativePath];
    return [self initWithPath:path isDirectory:isDirectory];
}

- (void)onInit{}

- (void)_doLoad{
    NSData *loadData = [self readAtOffsetToEnd:0];
    if (self.dencrypt != nil){
        loadData = self.dencrypt(loadData);
    }
    [self unarchiveData:loadData];
}

- (void)loadSync:(BOOL)sync{
    dispatch_semaphore_t sem;
    if (sync){
        sem = dispatch_semaphore_create(0);
    }
    dispatch_async(self.dispatchQueue, ^{
        [self _doLoad];
        if (sync){
            dispatch_semaphore_signal(sem);
        }
    });
    if (sync){
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
}


- (void)_doFlush{
    NSData *flushData = [self archiveData];
    if (nil == flushData) return;
    if (self.encrypt != nil){
        flushData = self.encrypt(flushData);
    }
    [self write:flushData];
}

- (void)flush{
    dispatch_async(self.dispatchQueue, ^{
        
        NSObject *lock = [self logicalLockOnWirte];
        
        if (lock){
            @synchronized (lock) {
                [self beginWriteData];
                [self _doFlush];
                [self endWriteData];
            }
        }
        else{
            [self beginWriteData];
            [self _doFlush];
            [self endWriteData];
        }
        
        
    });
}

- (NSData *)readAtOffset:(NSUInteger)offset length:(NSUInteger)length{
    NSData *readData = nil;
    @synchronized (self.readFHLock) {
        [self.readFH seekToFileOffset:offset];
        readData = [self.readFH readDataOfLength:length];
    }
    
    return readData;
}

- (NSData *)readAtOffsetToEnd:(NSUInteger)offset{
    NSData *readData = nil;
    @synchronized (self.readFHLock) {
        [self.readFH seekToFileOffset:offset];
        readData = [self.readFH readDataToEndOfFile];
    }
    
    return readData;
}

- (void)remove{
    [[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
}

- (BOOL)readOnInit{ return YES; }
- (NSURL *)url{ return _url; }
- (NSString *)path{ return _path; }

- (NSURL *)renameURL{
    if (nil == _renameURL){
        NSURL *copyURL = [_url copy];
        NSString *newLastComponent = [NSString stringWithFormat:@"%@.rename",[copyURL lastPathComponent]];
        _renameURL = [[copyURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:newLastComponent];
    }
    return _renameURL;
}

- (NSObject *)readFHLock{
    if (nil == _readFHLock){
        _readFHLock = [[NSObject alloc] init];
    }
    return _readFHLock;
}

- (BOOL)isDirectory{
    return _isDirectory;
}

- (BOOL)isEmptyFile{
    return _isEmptyFile;
}

- (NSFileHandle *)readFH{
    if (nil == _readFH && _url != nil){
        _readFH = [NSFileHandle fileHandleForReadingFromURL:_url error:nil];
    }

    return _readFH;
}

- (NSFileHandle *)writeFH{
    if (nil == _writeFH && self.renameURL != nil){
        @synchronized (self.renameURL) {
            [[NSFileManager defaultManager] removeItemAtPath:[self.renameURL path] error:nil];
            [[NSFileManager defaultManager] createFileAtPath:[self.renameURL path]
                                                    contents:nil
                                                  attributes:nil];
            _writeFH = [NSFileHandle fileHandleForWritingToURL:self.renameURL error:nil];
        }
    }

    return _writeFH;
}


- (void)write:(NSData *)data{
    [self.writeFH truncateFileAtOffset:0];
    [self.writeFH writeData:data error:nil];
    [self.writeFH synchronizeFile];
    [self.writeFH closeFile];
    _writeFH = nil;
    _isEmptyFile = NO;
    @synchronized (self.readFHLock) {
        [_readFH closeFile];
        _readFH = nil;
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:[_url path] error:&error];
        @synchronized (self.renameURL) {
            [[NSFileManager defaultManager] moveItemAtURL:self.renameURL toURL:_url error:&error];
        }
        [self readFH];
    }
}


- (NSString *)queueName:(NSString *)name{
    return [NSString stringWithFormat:@"com.fastclip.index.%@.%@",name,[[NSUUID UUID] UUIDString]];
}

/*
 Virtual methods*/
- (void)initOnEmpty{}

- (NSData * _Nullable)archiveData {
    return nil;
}

- (dispatch_queue_t _Nonnull)dispatchQueue {
    return dispatch_get_main_queue();
}

- (void)unarchiveData:(NSData * _Nullable)data {}

+ (BOOL)unarchiveOnInit{
    return YES;
}

- (NSObject *)logicalLockOnWirte{ return nil; }
- (void)beginWriteData{};
- (void)endWriteData{};

@end
