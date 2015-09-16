//
//  t_Singleton.h
//  Template
//
//  Created by yj on 14-9-24.
//  Copyright (c) 2014年 cdeledu. All rights reserved.
//
//
//  单例类 Header 文件定义: AS_SINGLETON( className )
//        Body   文件定义: DEF_SINGLETON( className )
//
//  调用方式为: [className sharedInstance] xxx
//
////////////////////////////////////////////////////////

#ifndef __Template__z_Singleton__
#define __Template__z_Singleton__

#undef	AS_SINGLETON
#define AS_SINGLETON( __class ) \
+ (__class *)sharedInstance;

#undef	DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
+ (__class *)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
return __singleton__; \
}


#endif /* defined(__Template__z_Singleton__) */
