#import <substrate.h>
#import "writeData.h"

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#include <stdio.h>
#include <sys/sysctl.h>
#include <sys/stat.h>
#include <objc/runtime.h>

 
int (*old_get_damage)();
int my_get_damage()
{
    return old_get_damage();
}

int (*old_DamagedOnPlay)(bool,void *);
int my_DamagedOnPlay(bool a,void *kind)
{
	//if( (*(int *)((char *)kind+0x90))==1 )
    return old_DamagedOnPlay(a,kind);
}


static FILE * (*orig_fopen) ( const char * filename, const char * mode );
FILE * new_fopen ( const char * filename, const char * mode ) {
    if (strcmp(filename, "/bin/bash") == 0) {
        return NULL;
    }
    return orig_fopen(filename, mode);
}

%ctor {
@autoreleasepool
{
	//unsigned long get_damage = _dyld_get_image_vmaddr_slide(0) + 0x1013C0894;
	//MSHookFunction((void *)get_damage, (void *)&my_get_damage, (void **)&old_get_damage);
	
	//unsigned long DamagedOnPlay = _dyld_get_image_vmaddr_slide(0) + 0x1013D0894;
	//MSHookFunction((void *)DamagedOnPlay, (void *)&my_DamagedOnPlay, (void **)&old_DamagedOnPlay);
        %init;
        MSHookFunction((void *)fopen, (void *)new_fopen, (void **)&orig_fopen);
	
	//writeData(0x94828,0x071081E0); //Win a Battle
}
}

