#import "ViewController.h"

#include <sys/utsname.h>
#include <sys/sysctl.h>
#include <sys/syscall.h>
#include <mach/mach.h>

#include "../ExpYolla/ExpKpru.h"
#include "../ExpYolla/offsets.h"
#include "../RootUnit/noncereboot.h"
#import "../ExpYolla/multi_path/sploit.h"

#import "jelbrekLib.h"
#import "libjb.h"
#import "payload.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *outPutWindow;
@property (weak, nonatomic) IBOutlet UIButton *runButton;
@property (weak, nonatomic) IBOutlet UIButton *openFileManager;

@end

@implementation ViewController
#define LOG(what, ...) [self log:[NSString stringWithFormat:@what"\n", ##__VA_ARGS__]];\
printf("\t"what"\n", ##__VA_ARGS__)

#define in_bundle(obj) strdup([[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@obj] UTF8String])

#define failIf(condition, message, ...) if (condition) {\
LOG(message);\
goto end;\
}
#define maxVersion(v)  ([[[UIDevice currentDevice] systemVersion] compare:@v options:NSNumericSearch] != NSOrderedDescending)


#define fileExists(file) [[NSFileManager defaultManager] fileExistsAtPath:@(file)]
#define removeFile(file) if (fileExists(file)) {\
[[NSFileManager defaultManager]  removeItemAtPath:@file error:&error]; \
if (error) { \
LOG("[-] Error: removing file %s (%s)", file, [[error localizedDescription] UTF8String]); \
error = NULL; \
}\
}

#define copyFile(copyFrom, copyTo) [[NSFileManager defaultManager] copyItemAtPath:@(copyFrom) toPath:@(copyTo) error:&error]; \
if (error) { \
LOG("[-] Error copying item %s to path %s (%s)", copyFrom, copyTo, [[error localizedDescription] UTF8String]); \
error = NULL; \
}

#define moveFile(copyFrom, moveTo) [[NSFileManager defaultManager] moveItemAtPath:@(copyFrom) toPath:@(moveTo) error:&error]; \
if (error) {\
LOG("[-] Error moviing item %s to path %s (%s)", copyFrom, moveTo, [[error localizedDescription] UTF8String]); \
error = NULL; \
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (isRootNow()) {
        _outPutWindow.text = readOutPutString();
        [_runButton setEnabled:NO];
        
        return;
    }
    // Do any additional setup after loading the view, typically from a nib.
    if (offsets_init() != 0) {
        _outPutWindow.text = @"Offset Hatası.\n";
    }
    struct utsname u = {};
    uname(&u);
//    struct    utsname {
//        char    sysname[_SYS_NAMELEN];    /* [XSI] Name of OS */
//        char    nodename[_SYS_NAMELEN];    /* [XSI] Name of this network node */
//        char    release[_SYS_NAMELEN];    /* [XSI] Release level */
//        char    version[_SYS_NAMELEN];    /* [XSI] Version level */
//        char    machine[_SYS_NAMELEN];    /* [XSI] Hardware type */
//    };
    NSString *deviceInfo = [[NSString alloc] initWithFormat:@"\n          %s\n          %s  %s", u.version, u.nodename, u.machine];
    _outPutWindow.text = [[_outPutWindow text] stringByAppendingString: deviceInfo];
    setUserLandHome([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,    NSUserDomainMask, YES)objectAtIndex:0]);
//    [NSFileManager defaultManager]
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [_outPutWindow resignFirstResponder];
    }
}

- (IBAction)postExploit:(id)sender {
    
    _outPutWindow.text = [[_outPutWindow text] stringByAppendingString: @"\n\n---\nExploit Başlıyor...\nvoucher_swap Methodu Kullanılıyor."];
    [_runButton setEnabled:NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        // Exploit here.
        mach_port_t taskforpidzero = MACH_PORT_NULL;
        uint64_t sb = 0;
        BOOL debug = NO;
        NSError *error = NULL;
        NSArray *plists;
        
        kern_return_t kErr = host_get_special_port(mach_host_self(), 0, 4, &taskforpidzero);
        if (kErr != KERN_SUCCESS && !MACH_PORT_VALID(taskforpidzero)) {
            taskforpidzero = grab_this_tfp0();
        }
        
        if (MACH_PORT_VALID(taskforpidzero)) {
            NSString * output = [[NSString alloc] initWithFormat:@"\ntfp0 Bulundu :0x%x", taskforpidzero];
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_outPutWindow.text = [[self->_outPutWindow text] stringByAppendingString:output];
                self->_outPutWindow.text = [[self->_outPutWindow text] stringByAppendingString: @"\nRoot Deneniyor."];
                setOutPutString(self->_outPutWindow.text);
            });
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
                if (start_noncereboot(taskforpidzero) == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self->_outPutWindow.text = [[self->_outPutWindow text] stringByAppendingString: @"\nRoot Başarılı Bitirliyor : UID 0.\nRootlandı."];
                        
                        //Tweak Ayarları...
                        if (!fileExists("/var/containers/Bundle/iosbinpack64")) {
                        FILE *g = fopen("/var/mobile/SoftwareUpdate/restore.log", "w");
                        self->_outPutWindow.text = [[self->_outPutWindow text] stringByAppendingString: @"\nSandBox'tan Kaçıldı."];
                        fclose(g);
                        chdir("/var/containers/Bundle/");
                    self->_outPutWindow.text = [[self->_outPutWindow text] stringByAppendingString: @"\nBundle Oluşturuldu."];
                        FILE *bootstrap = fopen((char*)in_bundle("tars/iosbinpack.tar"), "r");
                        
                        self->_outPutWindow.text = [[self->_outPutWindow text] stringByAppendingString: @"\niOSBinPack.tar Atıldı..."];
                        fclose(bootstrap);
                        FILE *tweaks = fopen((char*)in_bundle("tars/tweaksupport.tar"), "r");
                        
                        self->_outPutWindow.text = [[self->_outPutWindow text] stringByAppendingString: @"\nTweakSupport.tar Atıldı..."];
                        fclose(tweaks);
                        fileExists("/var/containers/Bundle/tweaksupport") || !fileExists("/var/containers/Bundle/iosbinpack64");
                        self->_outPutWindow.text = [[self->_outPutWindow text] stringByAppendingString: @"\nSymLink Olusturuluyor..."];
                        self->_outPutWindow.text = [[self->_outPutWindow text] stringByAppendingString: @"\nBasarılı..."];
                            
                        }
                        //Tweak Ayarları Tamam
                        [self->_openFileManager setHidden:NO];
                        setOutPutString(self->_outPutWindow.text);
                        rootCheckOrCheckIn();
                        
                    });
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self->_outPutWindow.text = [[self->_outPutWindow text] stringByAppendingString: @"\nBir Şeyler Hatalı."];
                        setOutPutString(self->_outPutWindow.text);
                    });
                }

            });
        }
        if (!MACH_PORT_VALID(taskforpidzero)) {
            self->_outPutWindow.text = [[self->_outPutWindow text] stringByAppendingString: @"\nRoot Edilemedi\nTekrar Dene."];
            sleep(1);
            return;
        }

    });
}

@end

@interface FileManagerViewController () <UITableViewDelegate,UITableViewDataSource> {
    
    NSString *currentPath;
    NSString *copyFilePath;
    NSString *copyFileName;
    NSArray *currentFileList;
}

@property (weak, nonatomic) IBOutlet FileListTableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *URLText;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;


@end


@implementation FileManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentPath = @"/";
    currentFileList = catchContentUnderPath(@"/");
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [_URLText resignFirstResponder];
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"Tablo görünümünde uzun uzun basın");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"satırdaki tablo görünümünde uzun basın %ld", indexPath.row);
        NSString *thisFileName = currentFileList[indexPath.row];
        NSString *thisFilePath;
        if ([currentPath isEqualToString:@"/"]) {
            thisFilePath = [[NSString alloc] initWithFormat:@"%@%@", currentPath, currentFileList[indexPath.row]];
        }else{
            thisFilePath = [[NSString alloc] initWithFormat:@"%@/%@", currentPath, currentFileList[indexPath.row]];
        }
        
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Komutunuz Nedir?"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* copyAction = [UIAlertAction actionWithTitle:@"Kopyala" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  self->_errorLabel.text = @"Dosyaya Dokundunuz.";
                                                                  self->copyFileName = thisFileName;
                                                                  self->copyFilePath = thisFilePath;
                                                              }];
        UIAlertAction* renameAction = [UIAlertAction actionWithTitle:@"Yeniden Adlandır" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Adı?"
                                                                                                                                           message: nil
                                                                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                                                                 [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                                                                     textField.placeholder = @"name";
                                                                     textField.textColor = [UIColor blueColor];
                                                                     textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                                                                     textField.borderStyle = UITextBorderStyleRoundedRect;
                                                                 }];
                                                                 [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                                     NSArray * textfields = alertController.textFields;
                                                                     UITextField * namefield = textfields[0];
                                                                     if ([namefield.text isEqualToString:@""]) {
                                                                         return;
                                                                     }
                                                                     NSString *destFilePath = [[dropLastContentOfSplash(thisFilePath) stringByAppendingString:@"/"] stringByAppendingString:thisFileName];
                                                                     NSError *errrrr;
                                                                     [[NSFileManager defaultManager] moveItemAtPath:thisFilePath toPath:destFilePath error:&errrrr];
                                                                     if (errrrr != nil) {
                                                                         printf("Birkaç hata!\n");
                                                                         NSLog(@"%@", errrrr);
                                                                         self->_errorLabel.text = @"Yeniden adlandırılamadı!";
                                                                     }
                                                                 }]];
                                                                 [alertController addAction:[UIAlertAction actionWithTitle:@"Iptal" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {NSLog(@"Ipral Edildi");}]];
                                                                 [self presentViewController:alertController animated:YES completion:nil];
                                                             }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Iptal" style:UIAlertActionStyleDefault
                                                             handler:nil];
        
        [alert addAction:copyAction];
        [alert addAction:renameAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        NSLog(@"gestureRecognizer.state = %ld", gestureRecognizer.state);
    }
}
- (IBAction)goBack:(id)sender {
    if ([currentPath  isEqual: @"/"]) {
        _URLText.text = currentPath;
        return;
    }
    currentPath = dropLastContentOfSplash(currentPath);
    currentFileList = catchContentUnderPath(currentPath);
    _tableView.reloadData;
    _URLText.text = currentPath;
}

- (IBAction)refreshList:(id)sender {
    if (![[NSFileManager defaultManager] fileExistsAtPath:_URLText.text]) {
        _errorLabel.text = @"Dosya yok.";
        return;
    }
    currentPath = _URLText.text;
    if (isThisDirectory(currentPath)) {
        currentFileList = catchContentUnderPath(currentPath);
        _tableView.reloadData;
    }else{
        currentPath = dropLastContentOfSplash(currentPath);
        currentFileList = catchContentUnderPath(currentPath);
        _tableView.reloadData;
    }
}

- (IBAction)wentToHome:(id)sender {
    currentPath = dropLastContentOfSplash(readUserlandHome());
    currentFileList = catchContentUnderPath(currentPath);
    _tableView.reloadData;
    _URLText.text = currentPath;
}

- (IBAction)pasteFile:(id)sender {
    if ([copyFileName isEqualToString:@""] || copyFileName == nil) {
        _errorLabel.text = @"Hiçbir şey kopyalanamadı!";
        return;
    }
    NSString *dest;
    if ([currentPath isEqualToString:@"/"]) {
        dest = [[NSString alloc] initWithFormat:@"%@%@", currentPath, copyFileName];
    }else{
        dest = [[NSString alloc] initWithFormat:@"%@/%@", currentPath, copyFileName];
    }
    while ([[NSFileManager defaultManager] fileExistsAtPath:dest]) {
        dest = [dest stringByAppendingString:@".copy"];
    }
    NSError *err;
    [[NSFileManager defaultManager] copyItemAtPath:copyFilePath toPath:dest error:&err];
    if (err != nil) {
        NSLog(@"Dosya Kopyalama Başarısız!");
        _errorLabel.text = @"Kopyalanabilir.";
    }
    currentFileList = catchContentUnderPath(currentPath);
    _tableView.reloadData;
}

- (IBAction)createFolder:(id)sender {
    _errorLabel.text = @"Önceki Hata: nil";
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Name?"
                                                                              message: @"Input the folder's name or cancel."
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"name";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        if ([namefield.text isEqualToString:@""]) {
            return;
        }
        NSLog(@"Dosyayı Şuraya Oluştur:%@",namefield.text);
        NSError *err;
        NSString *fullPath;
        if ([currentPath isEqualToString:@"/"]) {
            fullPath = [[NSString alloc] initWithFormat:@"%@%@", self->currentPath, namefield.text];
        }else{
            fullPath = [[NSString alloc] initWithFormat:@"%@/%@", self->currentPath, namefield.text];
        }
        [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:NO attributes:nil error:&err];
        if (err != nil) {
            NSLog(@"%@", err);
            self->_errorLabel.text = @"Dosya Oluşturulamadı.";
        }
        self->currentFileList = catchContentUnderPath(self->currentPath);
        self->_tableView.reloadData;
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Iptal" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {NSLog(@"Iptal Edildi");}]];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    cell.textLabel.text = [@"  " stringByAppendingString: currentFileList[indexPath.row]];
    NSString *fullPathForThisFile;
    if ([currentPath isEqualToString:@"/"]){
        fullPathForThisFile = [[NSString alloc] initWithFormat:@"%@%@", currentPath, currentFileList[indexPath.row]];
    }else{
        fullPathForThisFile = [[NSString alloc] initWithFormat:@"%@/%@", currentPath, currentFileList[indexPath.row]];
    }
    if (isThisDirectory(fullPathForThisFile)) {
        int itemCount = countItemInThePath(fullPathForThisFile);
        NSString *details = [[NSString alloc] initWithFormat:@"%d nesne(ler)", itemCount];
        cell.detailTextLabel.text = details;
        cell.imageView.image = [UIImage imageNamed:@"folder"];
    }else{
        cell.detailTextLabel.text = @"";
        cell.imageView.image = [UIImage imageNamed:@"file"];
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return currentFileList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *fullPathForThisFile;
    
    NSError *err;
    NSDictionary *attr=[NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedLong:0777U] forKey:NSFilePosixPermissions];
    [[NSFileManager defaultManager] setAttributes:attr ofItemAtPath:fullPathForThisFile error:&err];
    NSLog(@"%@", err);
    
    if ([currentPath  isEqual: @"/"]) {
        fullPathForThisFile = [[NSString alloc] initWithFormat:@"%@%@", currentPath, currentFileList[indexPath.row]];
    }else{
        fullPathForThisFile = [[NSString alloc] initWithFormat:@"%@/%@", currentPath, currentFileList[indexPath.row]];
    }
    if (isThisDirectory(fullPathForThisFile)) {
        currentPath = fullPathForThisFile;
        currentFileList = catchContentUnderPath(currentPath);
        tableView.reloadData;
        _URLText.text = currentPath;
    }else{
        NSString *filePath = [readUserlandHome() stringByAppendingPathComponent:currentFileList[indexPath.row]];
        if (isRootNow()) {
            self->_errorLabel.text = @"Dosyayı Paylaşamazsınız.\nAncak şuraya kopyaladım /var/mobile/Media/.";
            NSString *destPath = [@"/var/mobile/Media/" stringByAppendingPathComponent:currentFileList[indexPath.row]];
            [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:destPath error:&err];
            NSLog(@"%@", err);
            if (err != nil) {
                _errorLabel.text = @"/var/mobile/Media/ Kopyalama Hatası";
                NSURL *fileUrl = [NSURL fileURLWithPath:fullPathForThisFile];
                NSData *fileData = [NSData dataWithContentsOfURL:fileUrl];
                NSURL *url2 = [[NSURL alloc] initWithString:destPath];
                [fileData writeToURL:url2 atomically:YES];
                NSString *fileDataString = [[NSString alloc] initWithContentsOfFile:fullPathForThisFile encoding:NSUTF8StringEncoding error:nil];
                NSLog(@"%@", fileDataString);
            }
            NSDictionary *attr=[NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedLong:0777U] forKey:NSFilePosixPermissions];
            [[NSFileManager defaultManager] setAttributes:attr ofItemAtPath:destPath error:&err];
            NSLog(@"%@", err);
        }else{
            // Let's copy file to our doc direct.
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            [[NSFileManager defaultManager] copyItemAtPath:fullPathForThisFile toPath:filePath error:nil];
            NSDictionary *attr=[NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedLong:0777U] forKey:NSFilePosixPermissions];
            [[NSFileManager defaultManager] setAttributes:attr ofItemAtPath:filePath error:&err];
            NSLog(@"%@", err);
            
            NSURL *fileUrl     = [NSURL fileURLWithPath:filePath isDirectory:NO];
            NSArray *activityItems = @[fileUrl];
            UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            //if iPhone
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                [self presentViewController:activityController animated:YES completion:nil];
            }
            //if iPad
            else {
                // Change Rect to position Popover
                UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityController];
                [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
        }
        
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    _errorLabel.text = @"Last error: nil";
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *fullPathForThisFile;
        if ([currentPath  isEqual: @"/"]) {
            fullPathForThisFile = [[NSString alloc] initWithFormat:@"%@%@", currentPath, currentFileList[indexPath.row]];
        }else{
            fullPathForThisFile = [[NSString alloc] initWithFormat:@"%@/%@", currentPath, currentFileList[indexPath.row]];
        }
        NSString *msg = [[NSString alloc] initWithFormat:@"Silinen dosyaya gidiyorsunuz: %@", currentFileList[indexPath.row]];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Emin Misiniz?"
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* doAction = [UIAlertAction actionWithTitle:@"SIL!" style:UIAlertActionStyleCancel
                                                           handler:^(UIAlertAction * action) {
                                                               NSError *err;
                                                               [[NSFileManager defaultManager] removeItemAtPath:fullPathForThisFile error:&err];
                                                               if (err != nil) {
                                                                   NSLog(@"%@", err);
                                                                   self->_errorLabel.text = @"Silinemedi.";
                                                               }
                                                               self->currentFileList = catchContentUnderPath(self->currentPath);
                                                               tableView.reloadData;
                                                           }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Iptal" style:UIAlertActionStyleDefault
                                                             handler:nil];
        [alert addAction:doAction];
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end

