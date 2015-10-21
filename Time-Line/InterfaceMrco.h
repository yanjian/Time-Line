/*
   InterfaceMrco.h
   Go2

   Created by IF on 14-9-11.
   Copyright (c) 2014年 zhilifang. All rights reserved.
 */

#define GOOGLE_STATUS_OK      @"OK"       //OK 表示未出现错误，且至少返回了一个结果。
#define GOOGLE_STATUS_ZERO_RESULTS  @"ZERO_RESULTS"    //ZERO_RESULTS 表示搜索成功，但未返回任何结果。如果搜索中传递了一个偏远位置的 bounds，就可能会出现这种情况。
//OVER_QUERY_LIMIT 表示您超出了配额。
//REQUEST_DENIED 表示您的请求遭到拒绝，这通常是由于缺少 sensor 参数造成的。
//INVALID_REQUEST 通常表示缺少 input 参数。

#define kWidth 100
#define kHeight 40

//经度，纬度
#define LATITUDE  @"lat"
#define LONGITUDE @"lng"

#define RefTime @"refTime"

//导航的高度
#define naviHigth 64

#define cancelled @"cancelled" //google的事件状态
#define confirmed @"confirmed"



//===================================保存在NSUserDefaults的key的定义===============================================
#define CURRENTUSERINFO @"currentlyUserInfo" //从 NSUserDefaults 中取出保存的当前用户信息


//===============================================================================================================

typedef NS_ENUM (NSInteger, eventStatus) {
	eventStatus_confirmed = 0,
	eventStatus_cancelled = 1
};


typedef NS_ENUM(NSInteger, LoginOrLogoutType) {
    LoginOrLogoutType_SetupMainOpen = 0,//程序启动时，初始化登陆界面
    LoginOrLogoutType_ModelOpen = 1 //程序启动后，在用户点击退出时打开的登陆方式：模式打开
};

#define  calendarDateCount [CalendarDateUtil getCurrentDay] + 2 * 30

//google的apikey
#define GOOGLE_API_KEY @"AIzaSyAKtISyJ4m99OHW4r_aerSkNgMEQGYzPtM"

//事件本地通知的标记 (取消事件通知，添加通知用)
#define anyEventLocalNot_Flag @"anyEventLocalNot"


//基本IP
//测试： http://t2.oxozoom.com:8080/myCalendar
//真实环境  http://w.oxozoom.com:8080/myCalendar
//#define BASEURL_IP  http://t2.oxozoom.com:8080/Go2   // 最新
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


//https://accounts.google.com/o/oauth2/auth?scope=https://www.googleapis.com/auth/userinfo.profile+https://www.googleapis.com/auth/userinfo.email+https://www.googleapis.com/auth/calendar&redirect_uri=http://t2.oxozoom.com:8080/Go2/Oauth2callback&response_type=code&client_id=535796093828-i6df62gif0ntp4q9fmntpd0klovpragm.apps.googleusercontent.com&access_type=offline&include_granted_scopes=true&approval_prompt=force

//oauth认证url
#define Google_Base       @"https://accounts.google.com/o/oauth2/auth"
#define Google_UserInfo   @"https://www.googleapis.com/auth/userinfo.profile"
#define Google_User_Email @"https://www.googleapis.com/auth/userinfo.email"
#define Google_Calendar   @"https://www.googleapis.com/auth/calendar"
#define Google_redirech   [NSString stringWithFormat:@"%@/servlet/Oauth2callback",]
//测试环境
#define Google_Auth_APPID @"124861103249-11bp8t5epj45u5n91li89m4cknvajqrf.apps.googleusercontent.com"

//真实环境
//#define Google_Auth_APPID @"535796093828-esa2fotq9tjdgf1cbs0lb0jm5q46uv57.apps.googleusercontent.com"

#define Google_OAuth_URL [NSString stringWithFormat:@"%@?scope=%@+%@+%@&redirect_uri=%@&response_type=code&client_id=%@&access_type=offline&approval_prompt=force&include_granted_scopes=true", Google_Base, Google_UserInfo, Google_User_Email, Google_Calendar, Google_redirech, Google_Auth_APPID]

//
typedef NS_ENUM (NSInteger, UserLoginType) {
	UserLoginTypeLocal = 1,
	UserLoginTypeGoogle = 2
};


typedef NS_ENUM (NSInteger, UserLoginStatus) {
	UserLoginStatus_NO = 0,//表示没有登陆
	UserLoginStatus_YES = 1
};


typedef NS_ENUM (NSInteger, AccountType) {
	AccountTypeGoogle = 2,//0
	AccountTypeLocal = 1
};

//活动状态
typedef NS_ENUM (NSInteger, ActiveStatus) {
	ActiveStatus_upcoming       = 0,
	ActiveStatus_toBeConfirm    = 1,
	ActiveStatus_confirmed      = 2,
	ActiveStatus_past           = 3
};



typedef NS_ENUM(NSInteger, EventsAlertTime) {
    EventsAlertTime_Never       = 0,
    EventsAlertTime_AtTimeEvent = 1,
    EventsAlertTime_5MinBefore  = 2,
    EventsAlertTime_15MinBefore = 3,
    EventsAlertTime_30MinBefore = 4,
    EventsAlertTime_1HourBefore = 5,
    EventsAlertTime_2HourBefore = 6

};

typedef NS_ENUM(NSInteger, EventsAllDayAlert) {
    EventsAllDayAlert_Never  = 0,
    EventsAllDayAlert_5Hour  = 1,
    EventsAllDayAlert_7Hour  = 2,
    EventsAllDayAlert_8Hour  = 3,
    EventsAllDayAlert_9Hour  = 4,
    EventsAllDayAlert_10Hour = 5
    
};

typedef NS_ENUM(NSInteger, CalendarList_IsDefault) {//那个是默认日历
    CalendarList_IsDefault_No  = 0,
    CalendarList_IsDefault_Yes = 1
};

typedef NS_ENUM(NSInteger, CalendarList_IsNotification) {//那个日历事件数据是否通知
    CalendarList_IsNotification_No  = 0,
    CalendarList_IsNotification_Yes = 1
};

typedef NS_ENUM(NSInteger, CalendarList_IsVisible) {//那个日历事件数据是否显示
    CalendarList_IsVisible_No  = 0,
    CalendarList_IsVisible_Yes = 1
};

#define		DEFAULT_TAB							0


//==================================登陆openfire的用户名和密码（格式：anytime_xxx@ubuntu   密码： qq123456）=====

#define XMPP_ANYTIMENAME @"anytimeName"
#define XMPP_ANYTIMEPWD  @"anytimePWD"

#define XMPP_PWD @"qq123456"

//=========================================================================================================
#define  DeviceTokenKey @"DeviceToken"


//==============================================(本程序有关通知常量)==========================================

#define CHATGROUP_ACTIVENOTIFICTION @"chatGroupActiveNotifiction"//一个活动群聊信息通知
#define CHATGROUP_USERINFO @"chatGroupUserInfo" //活动群聊通知的附加信息

#define FRIENDS_OPTIONSNOTIFICTION @"friendOptionNotifiction"
#define FRIENDS_OPTIONSINFO        @"friendOptionInfo"

#define DELETEEVENTNOTI @"DeleteEventNotifictaion"
#define DELETEEVENTNOTI_INFO @"DeleteEventIdInfo"
//==========================================================================================================

//可配置IP
#define BASE_IP_CHANGE(serviceName) [NSString stringWithFormat : @"%@/servlet/%@", BASEURL_IP, serviceName]

//用户注册
#define LOGIN_REGISTER_URL [NSString stringWithFormat:@"%@/servlet/Register", BASEURL_IP]
#define LOGIN_REGISTER_URL_TAG 4


//用户登陆接口
#define LOGIN_USER [NSString stringWithFormat:@"%@/servlet/Login", BASEURL_IP]
#define LOGIN_USER_TAG 5

//google授权回调url
#define Google_Oauth2Callback_Url  [NSString stringWithFormat:@"%@/servlet/Oauth2callback", BASEURL_IP]


//取得google日历
#define Get_Google_GetCalendarList   [NSString stringWithFormat:@"%@/servlet/GetCalendarList", BASEURL_IP]
#define Get_Google_GetCalendarList_Tag 6


//取得google事件
#define Get_Google_GetCalendarEvent [NSString stringWithFormat:@"%@/servlet/GetCalendarEventList", BASEURL_IP]
#define Get_Google_GetCalendarEvent_Tag 7

//日历帐号绑定
#define Google_AccountBind [NSString stringWithFormat:@"%@/servlet/AccountBind", BASEURL_IP]
#define Google_AccountBind_Tag 8

//得到绑定列表 GetAccountBindList
#define Google_GetAccountBindList [NSString stringWithFormat:@"%@/servlet/GetAccountBindList", BASEURL_IP]
#define Google_GetAccountBindList_Tag 9

//本地日历处理  CalendarOperation
#define Local_CalendarOperation [NSString stringWithFormat:@"%@/servlet/CalendarOperation", BASEURL_IP]
#define Local_CalendarOperation_Tag 10

//本地事件处理  SingleEventOperation
#define Local_SingleEventOperation [NSString stringWithFormat:@"%@/servlet/SingleEventOperation", BASEURL_IP]
#define Local_SingleEventOperation_Tag 11
#define Local_SingleEventOperation_fetch_Tag 18

//登陆用户的信息  GetUserInfo
#define LoginUser_GetUserInfo [NSString stringWithFormat:@"%@/servlet/GetUserInfo", BASEURL_IP]
#define LoginUser_GetUserInfo_Tag 12

//得到绑定列表  GetAccountBindList
#define get_AccountBindList [NSString stringWithFormat:@"%@/servlet/GetAccountBindList", BASEURL_IP]
#define get_AccountBindList_Tag 13

//注销  Logoff
#define account_Logoff [NSString stringWithFormat:@"%@/servlet/Logoff", BASEURL_IP]
#define account_Logoff_Tag 14

//取消绑定  CancelAccountBind
#define account_CancelAccountBind [NSString stringWithFormat:@"%@/servlet/CancelAccountBind", BASEURL_IP]
#define account_CancelAccountBind_Tag 15

//更新或新增google数据  GoogleCalendarEventOperation
#define Google_CalendarEventOperation [NSString stringWithFormat:@"%@/servlet/GoogleCalendarEventOperation", BASEURL_IP]
#define Google_CalendarEventOperation_tag 161

// 删除google数据事件
#define Google_DeleteCalendarEvent [NSString stringWithFormat:@"%@/servlet/DeleteCalendarEvent", BASEURL_IP]
#define Google_DeleteCalendarEvent_tag 171


// 删除google数据事件
#define Google_CalendarEventRepeat [NSString stringWithFormat:@"%@/servlet/GoogleCalendarEventRepeat", BASEURL_IP]
#define Google_CalendarEventRepeat_tag 19


//***************************************添加好友或组等（第二期）***************************************************//

//更新用户信息
#define UserInfo_UpdateUserInfo [NSString stringWithFormat:@"%@/servlet/updateUserInfo", BASEURL_IP]
#define UserInfo_UpdateUserInfo_tag 20

//更新用户头像
#define UserInfo_UploadImg [NSString stringWithFormat:@"%@/servlet/uploadImg", BASEURL_IP]
#define UserInfo_UploadImg_tag 21

//新增组
#define anyTime_AddFTeam [NSString stringWithFormat:@"%@/servlet/AddFTeam", BASEURL_IP]
#define anyTime_AddFTeam_tag 30

//取得所有组 GetFTlist
#define anyTime_GetFTlist [NSString stringWithFormat:@"%@/servlet/GetFTlist", BASEURL_IP]
#define anyTime_GetFTlist_tag 31


//更新组 FriendTeam
#define anyTime_FriendTeam [NSString stringWithFormat:@"%@/servlet/FriendTeam", BASEURL_IP]
#define anyTime_FriendTeam_tag 32

//删除组 DeleteFTeam
#define anyTime_DeleteFTeam [NSString stringWithFormat:@"%@/servlet/DeleteFTeam", BASEURL_IP]
#define anyTime_DeleteFTeam_tag 33


//查询用户（模糊）  FindUser（增加大小图，性别，昵称）
#define anyTime_FindUser [NSString stringWithFormat:@"%@/servlet/FindUser", BASEURL_IP]
#define anyTime_FindUser_tag 34


//得到用户所有即时消息 GetUserMessage
#define anyTime_GetUserMessage [NSString stringWithFormat:@"%@/servlet/GetUserMessage", BASEURL_IP]
#define anyTime_GetUserMessage_tag 35

//得到用户未读消息 GetUserMessage2
#define anyTime_GetUserMessage2 [NSString stringWithFormat:@"%@/servlet/GetUserMessage2", BASEURL_IP]
#define anyTime_GetUserMessage2_tag 36


//更新消息为己读 UpdateMessageStatus
#define anyTime_UpdateMessageStatus [NSString stringWithFormat:@"%@/servlet/UpdateMessageStatus", BASEURL_IP]
#define anyTime_UpdateMessageStatus_tag 37


// 更新消息为己接收 UpdateMessageReceiveStatus
#define anyTime_UpdateMessageReceiveStatus [NSString stringWithFormat:@"%@/servlet/UpdateMessageReceiveStatus", BASEURL_IP]
#define anyTime_UpdateMessageReceiveStatus_tag 38

//取得所有好友  GetFriendList(增加大小图，性别，昵称)
#define anyTime_GetFriendList [NSString stringWithFormat:@"%@/servlet/GetFriendList", BASEURL_IP]
#define anyTime_GetFriendList_tag 39

//加好友申请  AddFriend
#define anyTime_AddFriend [NSString stringWithFormat:@"%@/servlet/AddFriend", BASEURL_IP]
#define anyTime_AddFriend_tag 40



//新增社交活动 AddEvents
#define anyTime_AddEvents [NSString stringWithFormat:@"%@/servlet/AddEvents", BASEURL_IP]
#define anyTime_AddEvents_tag 41

//上传社交活动图片 EventAddPhoto
#define anyTime_EventAddPhoto [NSString stringWithFormat:@"%@/servlet/EventAddPhoto", BASEURL_IP]
#define anyTime_EventAddPhoto_tag 42

//得到社交活动 Events
#define anyTime_Events [NSString stringWithFormat:@"%@/servlet/Events", BASEURL_IP]
#define anyTime_Events_tag 43


//更新参加活动状态 JoinEvent
#define anyTime_JoinEvent [NSString stringWithFormat:@"%@/servlet/JoinEvent", BASEURL_IP]
#define anyTime_JoinEvent_tag 44

//社交活动时间投票 VoteTimeForEvent
#define anyTime_VoteTimeForEvent [NSString stringWithFormat:@"%@/servlet/VoteTimeForEvent", BASEURL_IP]
#define anyTime_VoteTimeForEvent_tag 45

//投票社交活动中的问题投票 VoteEventOtherOption

#define anyTime_VoteEventOtherOption [NSString stringWithFormat:@"%@/servlet/VoteEventOtherOption", BASEURL_IP]
#define anyTime_VoteEventOtherOption_tag 46


//取消投票社交活动中的问题投票 VoteEventOtherOptionCancel
#define anyTime_VoteEventOtherOptionCancel [NSString stringWithFormat:@"%@/servlet/VoteEventOtherOptionCancel", BASEURL_IP]
#define anyTime_VoteEventOtherOptionCancel_tag 47

//添加投票时间  AddEventTime
#define anyTime_AddEventTime [NSString stringWithFormat:@"%@/servlet/AddEventTime", BASEURL_IP]
#define anyTime_AddEventTime_tag 48


//社交活动增加问题投票 AddEventVote
#define anyTime_AddEventVote [NSString stringWithFormat:@"%@/servlet/AddEventVote", BASEURL_IP]
#define anyTime_AddEventVote_tag 49


// 社交活动增加问题投票中的选项 AddEventVoteOption
#define anyTime_AddEventVoteOption [NSString stringWithFormat:@"%@/servlet/AddEventVoteOption", BASEURL_IP]
#define anyTime_AddEventVoteOption_tag 50

//更新社交活动 UpdateEvents
#define anyTime_UpdateEvents [NSString stringWithFormat:@"%@/servlet/UpdateEvents", BASEURL_IP]
#define anyTime_UpdateEvents_tag 51

//退出社交活动 QuitEvent
#define anyTime_QuitEvent [NSString stringWithFormat:@"%@/servlet/QuitEvent", BASEURL_IP]
#define anyTime_QuitEvent_tag 52

//删除社交活动 DelEvents
#define anyTime_DelEvents [NSString stringWithFormat:@"%@/servlet/DelEvents", BASEURL_IP]
#define anyTime_DelEvents_tag 53

//社交活动显示设置 ViewEvent
#define anyTime_ViewEvent [NSString stringWithFormat:@"%@/servlet/ViewEvent", BASEURL_IP]
#define anyTime_ViewEvent_tag 54

//更新好友备注   UpdateFriendNickName
#define anyTime_UpdateFriendNickName [NSString stringWithFormat:@"%@/servlet/UpdateFriendNickName", BASEURL_IP]
#define anyTime_UpdateFriendNickName_tag 54

//先取活動基本訊息, 點進才取活動詳細訊息 GetEventBasicInfo 跟（ tag 43 不同要等到详细信息加上eid 请求 ）
#define anyTime_GetEventBasicInfo [NSString stringWithFormat:@"%@/servlet/GetEventBasicInfo", BASEURL_IP]
#define anyTime_GetEventBasicInfo_tag 55

//处理好友请求  DisposeFriendRequest
#define anyTime_DisposeFriendRequest [NSString stringWithFormat:@"%@/servlet/DisposeFriendRequest", BASEURL_IP]
#define anyTime_DisposeFriendRequest_tag 56

//删除好友(双边删除) DeleteFriend
#define anyTime_DeleteFriend [NSString stringWithFormat:@"%@/servlet/DeleteFriend", BASEURL_IP]
#define anyTime_DeleteFriend_tag 57

//删除用户消息 DelMessage
#define anyTime_DelMessage [NSString stringWithFormat:@"%@/servlet/DelMessage", BASEURL_IP]
#define anyTime_DelMessage_tag 58

//得到所有己隐藏的活动------GetEventByNotification
#define anyTime_GetEventByNotification [NSString stringWithFormat:@"%@/servlet/GetEventByNotification", BASEURL_IP]
#define anyTime_GetEventByNotification_tag 59

// 社交活动通知设置 EventNotification
#define anyTime_EventNotification [NSString stringWithFormat:@"%@/servlet/EventNotification", BASEURL_IP]
#define anyTime_EventNotification_tag 60

//得到图片的真实路径  GetImgRealPath =====> type: 1,活动 2,用户  id=(eid或uid)
#define anyTime_GetImgRealPath [NSString stringWithFormat:@"%@/servlet/GetImgRealPath", BASEURL_IP]
#define anyTime_GetImgRealPath_tag 61


//UpdateDeviceToken 更新设备token
#define anyTime_UpdateDeviceToken [NSString stringWithFormat:@"%@/servlet/UpdateDeviceToken", BASEURL_IP]
#define anyTime_UpdateDeviceToken_tag 62

//多人活动群聊消息发送 SendMsg

#define anyTime_SendMsg [NSString stringWithFormat:@"%@/servlet/SendMsg", BASEURL_IP]
#define anyTime_SendMsg_tag 63


//更新好友分组 UpdateFTeam

#define anyTime_UpdateFTeam [NSString stringWithFormat:@"%@/servlet/UpdateFTeam", BASEURL_IP]
#define anyTime_UpdateFTeam_tag 64

//AddEventMember
#define anyTime_AddEventMember [NSString stringWithFormat:@"%@/servlet/AddEventMember", BASEURL_IP]
#define anyTime_AddEventMember_tag 65

//GetEventChatImg
#define anyTime_GetEventChatImg [NSString stringWithFormat:@"%@/servlet/GetEventChatImg", BASEURL_IP]
#define anyTime_GetEventChatImg_tag 66

//ConfirmEventTime
#define anyTime_ConfirmEventTime [NSString stringWithFormat:@"%@/servlet/ConfirmEventTime", BASEURL_IP]
#define anyTime_ConfirmEventTime_tag 67







// 最新接口Go2   如果url后面有其他参数加上 &     ________

#define BaseGo2Url_IP @"http://t2.oxozoom.com:8080/Go2"

// 登陆接口
#define Go2_UserLogin  [NSString stringWithFormat:@"%@/public?method=login&", BaseGo2Url_IP]
#define Go2_UserLogin_Tag  1

// 获取所有Go2日历(只包含本地日历列表（不包含google日历 ）)
#define Go2_GetCalendars  [NSString stringWithFormat:@"%@/user/privateEvent?method=getCalendars", BaseGo2Url_IP]
#define Go2_GetCalendars_Tag  2

//获取所有Go2事件
#define Go2_privateEvent  [NSString stringWithFormat:@"%@/user/privateEvent?method=query&", BaseGo2Url_IP]
#define Go2_privateEvent_Tag  3



//获取所有邀请信息  /user/friends

#define Go2_queryInviteesInfo  [NSString stringWithFormat:@"%@/user/friends?method=queryInviteesInfo&", BaseGo2Url_IP]
#define Go2_queryInviteesInfo_Tag  5

//用户图像更新
#define Go2_UploadServlet  [NSString stringWithFormat:@"%@/user/UploadServlet", BaseGo2Url_IP]
#define Go2_UploadServlet_Tag  6


//修改个人资料 /user
#define Go2_updateUser  [NSString stringWithFormat:@"%@/user?method=updateUser&", BaseGo2Url_IP]
#define Go2_updateUser_Tag  7




//https://accounts.google.com/o/oauth2/auth?scope=https://www.googleapis.com/auth/userinfo.profile+https://www.googleapis.com/auth/userinfo.email+https://www.googleapis.com/auth/calendar&redirect_uri=http://t2.oxozoom.com:8080/Go2/Oauth2callback&response_type=code&client_id=535796093828-i6df62gif0ntp4q9fmntpd0klovpragm.apps.googleusercontent.com&access_type=offline&include_granted_scopes=true&approval_prompt=force

//oauth认证url
#define Go2_Google_Base       @"https://accounts.google.com/o/oauth2/auth"
#define Go2_Google_UserInfo   @"https://www.googleapis.com/auth/userinfo.profile"
#define Go2_Google_User_Email @"https://www.googleapis.com/auth/userinfo.email"
#define Go2_Google_Calendar   @"https://www.googleapis.com/auth/calendar"
#define Go2_Google_redirech   [NSString stringWithFormat:@"%@/Oauth2callback",BaseGo2Url_IP]
#define Go2_Google_Auth_APPID @"535796093828-i6df62gif0ntp4q9fmntpd0klovpragm.apps.googleusercontent.com"

#define Go2_Google_OAuth_URL [NSString stringWithFormat:@"%@?scope=%@+%@+%@&redirect_uri=%@&response_type=code&client_id=%@&access_type=offline&include_granted_scopes=true&approval_prompt=force", Go2_Google_Base, Go2_Google_UserInfo, Go2_Google_User_Email, Go2_Google_Calendar, Go2_Google_redirech, Go2_Google_Auth_APPID]

//google授权回调url http://t2.oxozoom.com:8080/Go2/Oauth2callback
#define Go2_Google_Oauth2Callback_Url  [NSString stringWithFormat:@"%@/Oauth2callback", BaseGo2Url_IP]

//日历帐号绑定
#define Go2_Google_AccountBind [NSString stringWithFormat:@"%@/user/Google?method=bindAccount&", BaseGo2Url_IP]
#define Go2_Google_AccountBind_Tag 8

//取得google日历
#define Go2_Google_getCalendarList [NSString stringWithFormat:@"%@/user/Google?method=getCalendarList&", BaseGo2Url_IP]
#define Go2_Google_getCalendarList_Tag 9

//取得google事件
#define Go2_Google_getCalendarEvents [NSString stringWithFormat:@"%@/user/Google?method=getCalendarEvents&", BaseGo2Url_IP]
#define Go2_Google_getCalendarEvents_Tag 10

//新增google事件  --- 修改google事件 method=updateEvent
#define Go2_Google_Event [NSString stringWithFormat:@"%@/user/Google", BaseGo2Url_IP]
#define Go2_Google_Event_Tag 11
#define Go2_Google_Delete_Tag 12 //删除
#define Go2_Google_CalendarEventRepeat_tag 13

//google重复事件
#define Go2_Google_getGetRepeatEvent [NSString stringWithFormat:@"%@/user/Google?method=getGetRepeatEvent&", BaseGo2Url_IP]
#define Go2_Google_getGetRepeatEvent_Tag 14

#define Go2_Google_deleteEvent_Tag 15

//取消绑定 method=removeBind
#define Go2_Google_removeBind [NSString stringWithFormat:@"%@/user/Google?method=removeBind&", BaseGo2Url_IP]
#define Go2_Google_removeBind_Tag 16

//得到绑定列表
#define Go2_Google_getAccounts [NSString stringWithFormat:@"%@/user/Google?method=getAccounts&", BaseGo2Url_IP]
#define Go2_Google_getAccounts_Tag 17



//新增Go2事件    method=add    修改Go2事件   method=update
#define Go2_Local_privateEvent [NSString stringWithFormat:@"%@/user/privateEvent", BaseGo2Url_IP]
#define Go2_Local_privateEvent_Tag 18

//
#define Go2_Friends [NSString stringWithFormat:@"%@/user/friends", BaseGo2Url_IP]
#define Go2_Friends_Tag 19
#define Go2_Friends_queryUser_Tag 20 //获取所有好友
#define Go2_Friends_sendFriendInvitee_Tag 21 //发送好友请求
#define Go2_Friends_delete_Tag  22 //删除好友
#define Go2_Friends_queryInviteesInfo_Tag 23 //获取所有邀请信息
#define Go2_Friends_acceptFriend_Tag  24 //同意好友请求
#define Go2_UpdateFriendNickName_tag 25

// 获取所有社交活动 { mothed = getAllSocials }
#define Go2_socials  [NSString stringWithFormat:@"%@/user/Social", BaseGo2Url_IP]
#define Go2_getAllSocials_Tag  4 //得到所有活动
#define Go2_addSocials_Tag 26    //新增活动
#define Go2_socialsVoteTime_Tag 27
#define Go2_EventNotification_tag 28
#define Go2_getOneSocials_Tag 29
#define Go2_UpdateEvents_tag 30
#define Go2_AddEventMember_tag 31
#define Go2_JoinEvent_tag 32
#define Go2_ConfirmEventTime_tag 33
#define Go2_SendMsg_tag 34
#define Go2_GetEventChatImg_tag 35

//上传社交活动图片 type=(img：活动显示图片;chat:聊天图片)
#define Go2_UploadSocialFile  [NSString stringWithFormat:@"%@/user/UploadSocialFile", BaseGo2Url_IP]
#define Go2_UploadSocialFile_Tag 36


//获取个人信息 /user
#define Go2_getUserInfo  [NSString stringWithFormat:@"%@/user?method=getUserInfo&", BaseGo2Url_IP]
#define Go2_getUserInfo_Tag  37























































