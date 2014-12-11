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

#define cancelled @"cancelled" //google的事件状态
#define confirmed @"confirmed"  

typedef NS_ENUM(NSInteger, eventStatus) {
    eventStatus_confirmed=0,
    eventStatus_cancelled=1
};


#define  calendarDateCount [CalendarDateUtil getCurrentDay] + 2 *30

//google的apikey
#define GOOGLE_API_KEY @"AIzaSyAKtISyJ4m99OHW4r_aerSkNgMEQGYzPtM"

//事件本地通知的标记 (取消事件通知，添加通知用)
#define anyEventLocalNot_Flag @"anyEventLocalNot"


//基本IP
//测试： http://t2.oxozoom.com:8080/myCalendar
//真实环境  http://w.oxozoom.com:8080/myCalendar
#define BASEURL_IP @"http://t2.oxozoom.com:8080/myCalendar"

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


//oauth认证url
#define Google_Base       @"https://accounts.google.com/o/oauth2/auth"
#define Google_UserInfo   @"https://www.googleapis.com/auth/userinfo.profile"
#define Google_User_Email @"https://www.googleapis.com/auth/userinfo.email"
#define Google_Calendar   @"https://www.googleapis.com/auth/calendar"
#define Google_redirech   [NSString stringWithFormat:@"%@/servlet/Oauth2callback",BASEURL_IP]
//测试环境
#define Google_Auth_APPID @"124861103249-11bp8t5epj45u5n91li89m4cknvajqrf.apps.googleusercontent.com"

//真实环境
//#define Google_Auth_APPID @"535796093828-esa2fotq9tjdgf1cbs0lb0jm5q46uv57.apps.googleusercontent.com"

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




//可配置IP
#define BASE_IP_CHANGE(serviceName) [NSString stringWithFormat:@"%@/servlet/%@",BASEURL_IP,serviceName]

//用户注册
#define LOGIN_REGISTER_URL [NSString stringWithFormat:@"%@/servlet/Register",BASEURL_IP]
#define LOGIN_REGISTER_URL_TAG 4


//用户登陆接口
#define LOGIN_USER [NSString stringWithFormat:@"%@/servlet/Login",BASEURL_IP]
#define LOGIN_USER_TAG 5

//google授权回调url
#define Google_Oauth2Callback_Url  [NSString stringWithFormat:@"%@/servlet/Oauth2callback",BASEURL_IP]


//取得google日历
#define Get_Google_GetCalendarList   [NSString stringWithFormat:@"%@/servlet/GetCalendarList",BASEURL_IP]
#define Get_Google_GetCalendarList_Tag 6


//取得google事件
#define Get_Google_GetCalendarEvent [NSString stringWithFormat:@"%@/servlet/GetCalendarEventList",BASEURL_IP]
#define Get_Google_GetCalendarEvent_Tag 7

//日历帐号绑定
#define Google_AccountBind [NSString stringWithFormat:@"%@/servlet/AccountBind",BASEURL_IP]
#define Google_AccountBind_Tag 8

//得到绑定列表 GetAccountBindList
#define Google_GetAccountBindList [NSString stringWithFormat:@"%@/servlet/GetAccountBindList",BASEURL_IP]
#define Google_GetAccountBindList_Tag 9

//本地日历处理  CalendarOperation
#define Local_CalendarOperation [NSString stringWithFormat:@"%@/servlet/CalendarOperation",BASEURL_IP]
#define Local_CalendarOperation_Tag 10

//本地事件处理  SingleEventOperation
#define Local_SingleEventOperation [NSString stringWithFormat:@"%@/servlet/SingleEventOperation",BASEURL_IP]
#define Local_SingleEventOperation_Tag 11
#define Local_SingleEventOperation_fetch_Tag 18

//登陆用户的信息  GetUserInfo
#define LoginUser_GetUserInfo [NSString stringWithFormat:@"%@/servlet/GetUserInfo",BASEURL_IP]
#define LoginUser_GetUserInfo_Tag 12

//得到绑定列表  GetAccountBindList
#define get_AccountBindList [NSString stringWithFormat:@"%@/servlet/GetAccountBindList",BASEURL_IP]
#define get_AccountBindList_Tag 13

//注销  Logoff
#define account_Logoff [NSString stringWithFormat:@"%@/servlet/Logoff",BASEURL_IP]
#define account_Logoff_Tag 14

//取消绑定  CancelAccountBind
#define account_CancelAccountBind [NSString stringWithFormat:@"%@/servlet/CancelAccountBind",BASEURL_IP]
#define account_CancelAccountBind_Tag 15

//更新或新增google数据  GoogleCalendarEventOperation
#define Google_CalendarEventOperation [NSString stringWithFormat:@"%@/servlet/GoogleCalendarEventOperation",BASEURL_IP]
#define Google_CalendarEventOperation_tag 16

// 删除google数据事件
#define Google_DeleteCalendarEvent [NSString stringWithFormat:@"%@/servlet/DeleteCalendarEvent",BASEURL_IP]
#define Google_DeleteCalendarEvent_tag 17


// 删除google数据事件
#define Google_CalendarEventRepeat [NSString stringWithFormat:@"%@/servlet/GoogleCalendarEventRepeat",BASEURL_IP]
#define Google_CalendarEventRepeat_tag 19

//更新用户信息
#define UserInfo_UpdateUserInfo [NSString stringWithFormat:@"%@/servlet/updateUserInfo",BASEURL_IP]
#define UserInfo_UpdateUserInfo_tag 20

//更新用户头像
#define UserInfo_UploadImg [NSString stringWithFormat:@"%@/servlet/uploadImg",BASEURL_IP]
#define UserInfo_UploadImg_tag 21




//***************************************添加好友或组等（第二期）***************************************************//

//新增组
#define anyTime_AddFTeam [NSString stringWithFormat:@"%@/servlet/AddFTeam",BASEURL_IP]
#define anyTime_AddFTeam_tag 30

//取得所有组 GetFTlist
#define anyTime_GetFTlist [NSString stringWithFormat:@"%@/servlet/GetFTlist",BASEURL_IP]
#define anyTime_GetFTlist_tag 31


//更新组 FriendTeam
#define anyTime_FriendTeam [NSString stringWithFormat:@"%@/servlet/FriendTeam",BASEURL_IP]
#define anyTime_FriendTeam_tag 32

//删除组 DeleteFTeam
#define anyTime_DeleteFTeam [NSString stringWithFormat:@"%@/servlet/DeleteFTeam",BASEURL_IP]
#define anyTime_DeleteFTeam_tag 33


//查询用户（模糊）  FindUser（增加大小图，性别，昵称）
#define anyTime_FindUser [NSString stringWithFormat:@"%@/servlet/FindUser",BASEURL_IP]
#define anyTime_FindUser_tag 34


//得到用户所有即时消息 GetUserMessage
#define anyTime_GetUserMessage [NSString stringWithFormat:@"%@/servlet/GetUserMessage",BASEURL_IP]
#define anyTime_GetUserMessage_tag 35

//得到用户未读消息 GetUserMessage2

#define anyTime_GetUserMessage2 [NSString stringWithFormat:@"%@/servlet/GetUserMessage2",BASEURL_IP]
#define anyTime_GetUserMessage2_tag 36


//更新消息为己读 UpdateMessageStatus
#define anyTime_UpdateMessageStatus [NSString stringWithFormat:@"%@/servlet/UpdateMessageStatus",BASEURL_IP]
#define anyTime_UpdateMessageStatus_tag 37


// 更新消息为己接收 UpdateMessageReceiveStatus
#define anyTime_UpdateMessageReceiveStatus [NSString stringWithFormat:@"%@/servlet/UpdateMessageReceiveStatus",BASEURL_IP]
#define anyTime_UpdateMessageReceiveStatus_tag 38

//取得所有好友  GetFriendList(增加大小图，性别，昵称)
#define anyTime_GetFriendList [NSString stringWithFormat:@"%@/servlet/GetFriendList",BASEURL_IP]
#define anyTime_GetFriendList_tag 39

//加好友申请  AddFriend
#define anyTime_AddFriend [NSString stringWithFormat:@"%@/servlet/AddFriend",BASEURL_IP]
#define anyTime_AddFriend_tag 40










