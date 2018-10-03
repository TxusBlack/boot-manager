//
//  QBOSDetectOperation.m
//  Boot Manager
//
//  Created by Jeremy Knope on 8/7/10.
//  Copyright (c) 2010 Ambrosia Software, Inc. All rights reserved.
//

#import "QBOSDetectOperation.h"
#import "QBVolume.h"

@implementation QBOSDetectOperation

+ (QBOSDetectOperation *)detectOperationWithVolume:(QBVolume *)aVolume
{
	return [[[self class] alloc] initWithVolume:aVolume];
}

- (id)initWithVolume:(QBVolume *)aVolume
{
	if((self = [super init]))
	{
		self.volume = aVolume;
	}
	return self;
}


- (void)main
{
	@autoreleasepool {
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		NSString *osName = nil;
		NSString *osVersion = nil;
        NSString *osBuild = nil;
        NSString *osBootLoader = nil;
		BOOL legacy = YES;
        
        NSLog(@"volumeName: '%s' devicePath: '%s' filesystem: '%s' volumePath: '%s'", (char *)[[self.volume.disk volumeName] UTF8String], (char *)[[self.volume.disk devicePath] UTF8String], (char *)[[self.volume.disk filesystem] UTF8String], (char *)[[self.volume.disk volumePath] UTF8String]);
        
		// I read this wasn't best but this is for a non-running system
		NSString *versionPath = [[[[self.volume.disk.volumePath stringByAppendingPathComponent:@"System"]
								   stringByAppendingPathComponent:@"Library"]
								  stringByAppendingPathComponent:@"CoreServices"]
								 stringByAppendingPathComponent:@"SystemVersion.plist"];
		NSString *serverVersionPath = [[[[self.volume.disk.volumePath stringByAppendingPathComponent:@"System"]
																   stringByAppendingPathComponent:@"Library"]
																  stringByAppendingPathComponent:@"CoreServices"]
																 stringByAppendingPathComponent:@"ServerVersion.plist"];
        NSString *winbugsPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"Windows"]
                                         stringByAppendingPathComponent:@"System32"];
        NSString *winbugsInstallationPath = [[[self.volume.disk.volumePath stringByAppendingPathComponent:@"efi"]
                                    stringByAppendingPathComponent:@"microsoft"] stringByAppendingPathComponent:@"boot"];
        NSString *winbugsLegacyInstallationPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"sources"]
                                                    stringByAppendingPathComponent:@"boot.wim"];
        NSString *fedoraEfiPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                    stringByAppendingPathComponent:@"fedora"];
        NSString *manjaroEfiPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                    stringByAppendingPathComponent:@"Manjaro"];
        NSString *ubuntuEfiPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                    stringByAppendingPathComponent:@"ubuntu"];
        NSString *ubuntuEliloEfiPath = [[[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                    stringByAppendingPathComponent:@"ubuntu"] stringByAppendingPathComponent:@"elilo.efi"];
        NSString *ubuntuGrubEfiPath = [[[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                        stringByAppendingPathComponent:@"ubuntu"] stringByAppendingPathComponent:@"grubx64.efi"];
        NSString *debianEfiPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                   stringByAppendingPathComponent:@"debian"];
        NSString *centosEfiPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                   stringByAppendingPathComponent:@"centos"];
        NSString *slackwareEfiPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                   stringByAppendingPathComponent:@"Slackware"];
        NSString *suseEfiPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                   stringByAppendingPathComponent:@"SuSE"];
        NSString *grubEfiPath = [[[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                   stringByAppendingPathComponent:@"BOOT"] stringByAppendingPathComponent:@"grubx64.efi"];
        NSString *eliloEfiPath = [[[self.volume.disk.volumePath stringByAppendingPathComponent:@"EFI"]
                                   stringByAppendingPathComponent:@"elilo"] stringByAppendingPathComponent:@"elilo.efi"];
        NSString *linuxLegacyDiscPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"isolinux"]
                                       stringByAppendingPathComponent:@"isolinux.bin"];
        NSString *nextloaderEfiPath = [[self.volume.disk.volumePath stringByAppendingPathComponent:@"loader"]
                                   stringByAppendingPathComponent:@"loader.efi"];
        
        BOOL isDir;
		if([fileManager fileExistsAtPath:winbugsPath isDirectory:&isDir])
		{
			if(isDir)
			{
                osName = @"Windows"; // Winbugs
				legacy = YES;
			}
		}
        else if([fileManager fileExistsAtPath:winbugsInstallationPath isDirectory:&isDir])
        {
            if(isDir)
            {
                osName = @"Windows"; // Winbugs Installation Disc
                legacy = YES;
            }
        }
        else if([fileManager fileExistsAtPath:winbugsLegacyInstallationPath])
        {
            osName = @"Windows"; // Winbugs Legacy Installation Disc
            legacy = YES;
        }
        else if([fileManager fileExistsAtPath:fedoraEfiPath isDirectory:&isDir])
        {
            if(isDir)
            {
                osName = @"Fedora"; // Linux Fedora
                legacy = NO;
            }
        }
        else if([fileManager fileExistsAtPath:manjaroEfiPath isDirectory:&isDir])
        {
            if(isDir)
            {
                osName = @"Manjaro"; // Linux Manjaro
                legacy = NO;
            }
        }
        else if([fileManager fileExistsAtPath:ubuntuEliloEfiPath])
        {
            osName = @"Ubuntu"; // Linux Ubuntu (ELILO)
            osBootLoader = @"/EFI/ubuntu/elilo.efi";
            legacy = NO;
        }
        else if([fileManager fileExistsAtPath:ubuntuGrubEfiPath])
        {
            osName = @"Ubuntu"; // Linux Ubuntu (GRUB)
            osBootLoader = @"/EFI/ubuntu/grubx64.efi";
            legacy = NO;
        }
        else if([fileManager fileExistsAtPath:ubuntuEfiPath isDirectory:&isDir])
        {
            if(isDir)
            {
                osName = @"Ubuntu"; // Linux Ubuntu
                legacy = NO;
            }
        }
        else if([fileManager fileExistsAtPath:debianEfiPath isDirectory:&isDir])
        {
            if(isDir)
            {
                osName = @"Debian"; // Linux Debian
                osBootLoader = @"/EFI/debian/grubx64.efi";
                legacy = NO;
            }
        }
        else if([fileManager fileExistsAtPath:centosEfiPath isDirectory:&isDir])
        {
            if(isDir)
            {
                osName = @"CentOS"; // Linux CentOS
                osBootLoader = @"/EFI/centos/shim.efi";
                legacy = NO;
            }
        }
        else if([fileManager fileExistsAtPath:slackwareEfiPath isDirectory:&isDir])
        {
            if(isDir)
            {
                osName = @"Slackware"; // Linux Slackware
                osBootLoader = @"/EFI/Slackware/elilo.efi";
                legacy = NO;
            }
        }
        else if([fileManager fileExistsAtPath:suseEfiPath isDirectory:&isDir])
        {
            if(isDir)
            {
                osName = @"Open Suse"; // Linux Open Suse
                osBootLoader = @"/EFI/SuSE/elilo.efi";
                legacy = NO;
            }
        }
        else if([fileManager fileExistsAtPath:grubEfiPath])
        {
            osName = @"Linux"; // Generic Linux (GRUB)
            osBootLoader = @"/EFI/BOOT/grubx64.efi";
            legacy = NO;
        }
        else if([fileManager fileExistsAtPath:eliloEfiPath])
        {
            osName = @"Linux"; // Generic Linux (ELILO)
            osBootLoader = @"/EFI/elilo/elilo.efi";
            legacy = NO;
        }
        else if([fileManager fileExistsAtPath:linuxLegacyDiscPath])
        {
            osName = @"Linux"; // Generic Linux Legacy Installation Disc
            legacy = YES;
        }
        else if([fileManager fileExistsAtPath:nextloaderEfiPath])
        {
            osName = @"Next Loader"; // Next Loader
            osBootLoader = @"/loader/loader.efi";
            legacy = NO;
        }
		else if([fileManager fileExistsAtPath:versionPath])
		{
			NSDictionary *version = [NSDictionary dictionaryWithContentsOfFile:versionPath];
			osName = @"macOS";
			osVersion = [version objectForKey:@"ProductUserVisibleVersion"];
			osBuild = [version objectForKey:@"ProductBuildVersion"];
			legacy = NO;
		}
		else if([fileManager fileExistsAtPath:serverVersionPath])
		{
			NSDictionary *version = [NSDictionary dictionaryWithContentsOfFile:versionPath];
			osName = @"macOS Server %@/%@";
			osVersion = [version objectForKey:@"ProductUserVisibleVersion"];
			osBuild = [version objectForKey:@"ProductBuildVersion"];
			legacy = NO;
		}
		else
		{
			osName = nil;
		}
		
		// update volume object
		self.volume.systemName = osName;
		self.volume.legacyOS = legacy;
		self.volume.systemVersion = osVersion;
        self.volume.systemBuildNumber = osBuild;
        self.volume.systemBootLoader = osBootLoader;

	}
	
    id <QBOSDetectOperationDelegate>delegate = self.delegate;
	
    dispatch_async(dispatch_get_main_queue(), ^{
        if([delegate respondsToSelector:@selector(detectOperation:finishedScanningVolume:)])
        {
            [delegate detectOperation:self finishedScanningVolume:self.volume];
        }
    });
}

@end
