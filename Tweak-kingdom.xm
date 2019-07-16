#import <substrate.h>
#import "writeData.h"

int flag=0;

int (*old_get_damage)();
int my_get_damage()
{
    if(flag==1)
    {
        return (old_get_damage()+1)*10;
    }
    else if(flag==2)
    { 
        return (old_get_damage()+1)/10;
    }
    else
    {
        return old_get_damage();
    }
}

void (*old_DamagedOnPlay)(bool, bool, void *,void *, void *, void *, void *, bool, bool,void *,char *,char *,void *,int,void *);
void my_DamagedOnPlay(bool is_real, bool is_system, void *dmgKind,void *target, void *hitData, void *damage_type, void *damage_element, bool apply_element_enhance, bool apply_bonus_physic,void *attacker,char *attacker_id,char *skill_id,void *status,int history_skill_index,void *onDeadHandler)
{
    if( (*(bool *)((char *)attacker+0x90))==1 )
    {
        flag=1;
    }
    else if((*(bool *)((char *)attacker+0x90))==0)
    {
        flag=2;
    }
    old_DamagedOnPlay(is_real, is_system, dmgKind,target,hitData, damage_type, damage_element, apply_element_enhance, apply_bonus_physic,attacker,attacker_id,skill_id,status,history_skill_index,onDeadHandler);
}

%ctor 
{ 
	@autoreleasepool 
	{ 
		unsigned long get_damage = _dyld_get_image_vmaddr_slide(0) + 0x1013C0894; 
		MSHookFunction((void *)get_damage, (void *)&my_get_damage, (void **)&old_get_damage);

		unsigned long DamagedOnPlay = _dyld_get_image_vmaddr_slide(0) + 0x1007EBEB0;
		MSHookFunction((void *)DamagedOnPlay, (void *)&my_DamagedOnPlay, (void **)&old_DamagedOnPlay); 
	} 
}