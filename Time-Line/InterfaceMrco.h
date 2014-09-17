/* 
  InterfaceMrco.h
  Time-Line

  Created by IF on 14-9-11.
  Copyright (c) 2014年 zhilifang. All rights reserved.
*/

#define GOOGLE_STATUS_OK      @"OK"       //OK 表示未出现错误，且至少返回了一个结果。
#define GOOGLE_STATUS_ZERO_RESULTS  @"ZERO_RESULTS"    //ZERO_RESULTS 表示搜索成功，但未返回任何结果。如果搜索中传递了一个偏远位置的 bounds，就可能会出现这种情况。
//OVER_QUERY_LIMIT 表示您超出了配额。
//REQUEST_DENIED 表示您的请求遭到拒绝，这通常是由于缺少 sensor 参数造成的。
//INVALID_REQUEST 通常表示缺少 input 参数。

//经度，纬度
#define LATITUDE  @"lat"
#define LONGITUDE @"lng"


//google的apikey
#define GOOGLE_API_KEY @"AIzaSyAKtISyJ4m99OHW4r_aerSkNgMEQGYzPtM"

//googel搜索地址自动补全
#define GOOGLE_ADDRESS_REQUEST_SEARCH  @"https://maps.googleapis.com/maps/api/place/autocomplete/json"
#define GOOGLE_ADDRESS_REQUEST_SEARCH_TAG  1


//请求google给予坐标
//https://maps.googleapis.com/maps/api/place/details/json?reference=reference&sensor=true&key=MAP_API_KEY

#define GOOGLE_ADDRESS_LOCATION @"https://maps.googleapis.com/maps/api/place/details/json"
#define GOOGLE_ADDRESS_LOCATION_TAG 2

//根据地图坐标获得一个地图图片
//  http://maps.googleapis.com/maps/api/staticmap?center=40.714728,-73.998672&zoom=12&size=400x400&sensor=false
#define GOOGLE_ADDRESS_PIC @"http://maps.googleapis.com/maps/api/staticmap"
#define GOOGLE_ADDRESS_PIC_TAG 3