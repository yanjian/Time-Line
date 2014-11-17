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

#define RefTime @"refTime"

//导航的高度
#define naviHigth 64


#define  calendarDateCount [CalendarDateUtil getCurrentDay] + 2 *30

//google的apikey
#define GOOGLE_API_KEY @"AIzaSyAKtISyJ4m99OHW4r_aerSkNgMEQGYzPtM"

//事件本地通知的标记 (取消事件通知，添加通知用)
#define anyEventLocalNot_Flag @"anyEventLocalNot"

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

//https://accounts.google.com/o/oauth2/auth?scope=https://www.googleapis.com/auth/userinfo.profile+https://www.googleapis.com/auth/userinfo.email+https://www.googleapis.com/auth/calendar&redirect_uri=http://t2.oxozoom.com:8080/myCalendar/servlet/Oauth2callback&response_type=code&client_id=124861103249-11bp8t5epj45u5n91li89m4cknvajqrf.apps.googleusercontent.com&access_type=offline

//https://accounts.google.com/o/oauth2/auth?scope=https://www.googleapis.com/auth/userinfo.profile+https://www.googleapis.com/auth/userinfo.email+https://www.googleapis.com/auth/calendar&redirect_uri=http://t2.oxozoom.com:8080/myCalendar/servlet/Oauth2callback&response_type=code&client_id=124861103249-11bp8t5epj45u5n91li89m4cknvajqrf.apps.googleusercontent.com&approval_prompt=force&access_type=offline&include_granted_scopes=true

//oauth认证url
#define Google_Base       @"https://accounts.google.com/o/oauth2/auth"
#define Google_UserInfo   @"https://www.googleapis.com/auth/userinfo.profile"
#define Google_User_Email @"https://www.googleapis.com/auth/userinfo.email"
#define Google_Calendar   @"https://www.googleapis.com/auth/calendar"
#define Google_redirech   @"http://t2.oxozoom.com:8080/myCalendar/servlet/Oauth2callback"
#define Google_Auth_APPID @"124861103249-11bp8t5epj45u5n91li89m4cknvajqrf.apps.googleusercontent.com"

#define Google_OAuth_URL [NSString stringWithFormat:@"%@?scope=%@+%@+%@&redirect_uri=%@&response_type=code&client_id=%@&access_type=offline&approval_prompt=force&include_granted_scopes=true",Google_Base,Google_UserInfo,Google_User_Email,Google_Calendar,Google_redirech,Google_Auth_APPID]

//
typedef NS_ENUM(NSInteger, UserLoginType) {
    UserLoginTypeLocal=1,
    UserLoginTypeGoogle=2
};


typedef NS_ENUM(NSInteger, UserLoginStatus) {
    UserLoginStatus_NO=0,//表示没有登陆
    UserLoginStatus_YES=1
};


typedef NS_ENUM(NSInteger , AccountType){
    AccountTypeGoogle=0,
    AccountTypeLocal=1

};

//基本IP
//测试： http://t2.oxozoom.com:8080/myCalendar/servlet
//真实环境  http://w.oxozoom.com:8080/myCalendar/servlet
#define BASEURL_IP @"http://t2.oxozoom.com:8080/myCalendar/servlet"


//可配置IP
#define BASE_IP_CHANGE(serviceName) [NSString stringWithFormat:@"%@/%@",BASEURL_IP,serviceName]

//用户注册
#define LOGIN_REGISTER_URL [NSString stringWithFormat:@"%@/Register",BASEURL_IP]
#define LOGIN_REGISTER_URL_TAG 4


//用户登陆接口
#define LOGIN_USER [NSString stringWithFormat:@"%@/Login",BASEURL_IP]
#define LOGIN_USER_TAG 5

//google授权回调url
#define Google_Oauth2Callback_Url  [NSString stringWithFormat:@"%@/Oauth2callback",BASEURL_IP]


//取得google日历
#define Get_Google_GetCalendarList   [NSString stringWithFormat:@"%@/GetCalendarList",BASEURL_IP]
#define Get_Google_GetCalendarList_Tag 6


//取得google事件
#define Get_Google_GetCalendarEvent [NSString stringWithFormat:@"%@/GetCalendarEventList",BASEURL_IP]
#define Get_Google_GetCalendarEvent_Tag 7

//日历帐号绑定
#define Google_AccountBind [NSString stringWithFormat:@"%@/AccountBind",BASEURL_IP]
#define Google_AccountBind_Tag 8

//得到绑定列表 GetAccountBindList
#define Google_GetAccountBindList [NSString stringWithFormat:@"%@/GetAccountBindList",BASEURL_IP]
#define Google_GetAccountBindList_Tag 9

//本地日历处理  CalendarOperation
#define Local_CalendarOperation [NSString stringWithFormat:@"%@/CalendarOperation",BASEURL_IP]
#define Local_CalendarOperation_Tag 10

//本地事件处理  SingleEventOperation
#define Local_SingleEventOperation [NSString stringWithFormat:@"%@/SingleEventOperation",BASEURL_IP]
#define Local_SingleEventOperation_Tag 11
#define Local_SingleEventOperation_fetch_Tag 18

//登陆用户的信息  GetUserInfo
#define LoginUser_GetUserInfo [NSString stringWithFormat:@"%@/GetUserInfo",BASEURL_IP]
#define LoginUser_GetUserInfo_Tag 12

//得到绑定列表  GetAccountBindList
#define get_AccountBindList [NSString stringWithFormat:@"%@/GetAccountBindList",BASEURL_IP]
#define get_AccountBindList_Tag 13

//注销  Logoff
#define account_Logoff [NSString stringWithFormat:@"%@/Logoff",BASEURL_IP]
#define account_Logoff_Tag 14

//取消绑定  CancelAccountBind
#define account_CancelAccountBind [NSString stringWithFormat:@"%@/CancelAccountBind",BASEURL_IP]
#define account_CancelAccountBind_Tag 15

//更新或新增google数据  GoogleCalendarEventOperation
#define Google_CalendarEventOperation [NSString stringWithFormat:@"%@/GoogleCalendarEventOperation",BASEURL_IP]
#define Google_CalendarEventOperation_tag 16

// 删除google数据事件
#define Google_DeleteCalendarEvent [NSString stringWithFormat:@"%@/DeleteCalendarEvent",BASEURL_IP]
#define Google_DeleteCalendarEvent_tag 17










