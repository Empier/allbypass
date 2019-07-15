#import <substrate.h>
#import "writeData.h"
#include <dlfcn.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#include <stdio.h>
#include <sys/sysctl.h>
#include <sys/stat.h>
#include <objc/runtime.h>


static uint32_t (*orig_dyld_image_count)();
uint32_t new_dyld_image_count()
{
  NSLog(@"KMSKMS dyld_image_count!!");
  uint32_t realCount = orig_dyld_image_count();
  return realCount;

}

static const char * (*orig_dyld_get_image_name)(int image_index);
const char *new_dyld_get_image_name(int image_index)
{
  char *result=NULL;
  result = (char *)orig_dyld_get_image_name(image_index);
  NSArray<NSString*>* blacklisted = @[
    @"MobileSubstrate",
    @"substrate",
    @"Substrate",
    @"librocketbootstrap",
    @"libcolorpicker",
    @"substitute",
    @"Library/Frameworks",
    @"Library/Caches",
    @"bfdecrypt.dylib",
    @"allbypass.dylib",
    @"HideJB.dylib",
    @"Flex.dylib",
    @"DLGMemorInjected.dylib",
  ];
  for(NSString* bannedProc in blacklisted)
  {
    if([[NSString stringWithUTF8String:result] containsString:bannedProc])
    {
        //NSLog(@"KMSKMS2 %s",result);
        result = (char *)orig_dyld_get_image_name(0);
        break;
    }
  }
  //NSLog(@"KMSKMS--> %x %s",image_index,result); 
  return (char *)result;
}

static FILE * (*orig_fopen) ( const char * filename, const char * mode );
FILE* new_fopen(const char *a1, const char *a2)
{
  const char *v2; // x19
  const char *v3; // x20
  FILE* result; // x0
  NSLog(@"KMSKMSKMSKMSKMSKMSKMSKMSKMSKMSKMSKMS fopen");
  v2 = a2;
  v3 = a1;
  if ( !strcmp(a1, "/Applications/Cydia.app")
    || !strcmp(v3, "/Library/MobileSubstrate/MobileSubstrate.dylib")
    || !strcmp(v3, "/bin/bash")
    || !strcmp(v3, "/usr/sbin/sshd")
    || !strcmp(v3, "/etc/apt")
    || !strcmp(v3, "/usr/bin/ssh") )
  {
    NSLog(@"KMSKMS2 fopen: %s",v3);
    result = 0LL;
  }
  else
  {
    NSLog(@"KMSKMS fopen: %s",v3);
    result = orig_fopen(v3, v2);
  }
  return result;
}

static bool(*orig_dlopen_preflight)(const char* path);
bool new_dlopen_preflight (const char* path)
{
   NSLog(@"KMSKMS new_dlopen_preflight");
//    if (disableJBDectection())
 //   {
  //      return 0;
   // }

    bool ret = orig_dlopen_preflight(path);
    return ret;
}
static int(*orig_lstat)(const char* path,struct stat *buf);
int new_lstat(const char *path,struct stat *buf)
{
    NSLog(@"KMSKMS lstat = %s",path);
    if(strcmp(path,"/Applications") == 0){
        return -1;
    }
    return orig_lstat(path,buf);
}

%hook UIApplication
- (BOOL)canOpenURL:(NSURL *)url {
    return [[url absoluteString] isEqualToString:@"cydia://"] ? NO : %orig;
}
%end

%ctor {
@autoreleasepool
{
        %init;
	NSLog(@"GOOD KMSKMS!!");
        MSHookFunction((void *)fopen, (void *)new_fopen, (void **)&orig_fopen);
        MSHookFunction((void *)_dyld_get_image_name,(void *)new_dyld_get_image_name,(void **)&orig_dyld_get_image_name);
        MSHookFunction((void *)_dyld_image_count,(void *)new_dyld_image_count,(void **)&orig_dyld_image_count);
        MSHookFunction((void *)dlopen_preflight,(void *)new_dlopen_preflight,(void **)&orig_dlopen_preflight);
        MSHookFunction((void *)lstat,(void *)new_lstat,(void **)&orig_lstat);
        NSLog(@"KMSKMS END!");

	
}
}

