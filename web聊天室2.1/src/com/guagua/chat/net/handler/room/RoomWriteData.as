package com.guagua.chat.net.handler.room 
{
	//import com.guagua.chat.model.RoomInfo;
	//import com.guagua.chat.model.UserInfo;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.net.handler.WriteBty;
	import com.guagua.chat.util.Operation;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	/**
	 * ...roomProxy c++结构体组包
	 * @author Wen
	 */
	public class RoomWriteData extends WriteBty
	{
		
		public function RoomWriteData() 
		{
		
		}
		
		
		//登陆 roomProxy 包
		public function _1039():ByteArray {
			//trace("---------------------------------1039");
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			
			//类型
			data.writeShort(1039);
			//long m_lRoomID;       //房间ID
			data.writeInt(room.m_szRoomId);
			//WORD m_wClientVer;      //客户段版本 
			data.writeShort(RoomModel.getRoomModel().m_wClientVer);
			//TCHAR m_szRoomPwd[DEF_ROOM_PWD_LEN + 1]; //房间的密码  32+1
			//data.writeShort(room.m_szRoomPwd);
			bty.length=0;
			bty.writeMultiByte(room.m_szRoomPwd, "GB2312");
			////trace("RoomWriteData _1039",room.m_szRoomPwd);
			data.writeShort(bty.length);
			data.writeBytes(bty, 0, bty.length); 
			//char m_szUserPwd[DEF_MD5_PWD_LEN + 1]; //用户密码  8位 32+1
			var meckbty:ByteArray =Operation.getOperation().meck32Bit(user.mesk);
			data.writeBytes(meckbty, 0, meckbty.length);//外网meck
			//data.writeUTFBytes("4D2EE2ADF46FBB147A65A99BCB040B63");//内网meck
			
			bty.length=0;
			
			//提示信息现用途为填充机器码，机器码是一个INT64的数值 flash无法提取mac值，绑定用户id chang by idzeir 20130624
			
			/*if(user.uid>10000000000){
				bty.writeMultiByte("", "GB2312");
			}else{
				bty.writeMultiByte("我来了啊", "GB2312");
			}*/
			
			bty = Operation.getOperation().long2Bytes(user.uid, true);
			
			//**************
			
			////trace(_local2.length);
			data.writeShort(bty.length);
			//char m_szTipMsg[DEF_MAX_DESCRIBE_LEN + 1]; //提示信息
			data.writeBytes(bty, 0, bty.length);  
			//readAry.writeUTFBytes("eteteter");
			//STRU_CHAT_USER_INFO m_struUserInfo;
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(user.uid, true);
			//trace("mask:",bty.length,bty.bytesAvailable);
			data.writeBytes(bty, 0, 8);
			bty.length = 0;
			bty.writeMultiByte(user.name, "GB2312");
			data.writeShort(bty.length);
			data.writeBytes(bty, 0, bty.length);
			data.writeShort(user.m_wPhotoNum);
			data.writeByte(user.m_byUserRule);
			data.writeInt(Operation.getOperation().userStateBit(user.m_Media));
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(user.m_i64EquipState, true);
			data.writeBytes(bty, 0, 8);
			data.writeShort(user.m_wTuyaImage);
				//BYTE m_byIspType;      //网络类型
			data.writeByte(RoomModel.getRoomModel().m_byIspType);
				//BYTE m_byNatType;      //NAT类型
			data.writeByte(RoomModel.getRoomModel().m_byNatType);
				//long m_lOemID;     //各产品ID 定义参考enum_All_OemID
			/*if(eType){
				data.writeInt(0);
			}else{
				data.writeInt(RoomModel.getRoomModel().m_lOemID);//data.writeInt(7);
			}*/	
			
			//娱乐oemid7，网页游客在客户端不显示
			data.writeInt(RoomModel.getRoomModel().m_lOemID);//data.writeInt(7);
			
			
			Log.out("oemid",eType,RoomModel.getRoomModel().m_lOemID,user.isLongUser)
			bty.length = 0;
			return getData(data);
		}		
		
		/*struct	STRU_CL_CAS_LOGINOUT_ID
		{
			long	m_lRoomID;				//房间ID
			INT64	m_i64UserID;			//来源用户ID
			long    m_nSessionKey;          //会话密钥

		public:	
			DECLEAR_STD_PACK_SERIALIZE();	
		};*/
		//退出房间通知包
		public function _1018():ByteArray
		{
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			var bty:ByteArray = new ByteArray();
			
			data.writeShort(1018);
			data.writeInt(room.m_szRoomId);
			
			bty= Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			bty.clear();
			
			data.writeInt(RoomModel.getRoomModel().key);
			return getData(data);
		}
		
		//登陆WBS包
		public function _8003():ByteArray{
			//trace("---------------------------------8003");
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			
			//类型
			data.writeShort(8003);
			////trace(8003);
			//用户ID
			bty = Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			bty.length = 0;
			//long m_lRoomID;       //房间ID
			data.writeInt(room.m_szRoomId);
			//WORD m_wClientVer;      //客户段版�?
			data.writeShort(RoomModel.getRoomModel().m_wClientVer);
			
			bty.writeMultiByte(user.name, "GB2312");
			data.writeShort(bty.length);
			data.writeBytes(bty, 0, bty.length);
			
			bty.length = 0;
			return getData(data);
		}
		//存活
		public function _1035():ByteArray {
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			////trace(RoomModel.getRoomModel().myRoomInfo.loginServerType);
			if (RoomModel.getRoomModel().myRoomInfo.loginServerType=="roomProx") {//登陆roomProx
				//类型
				data.writeShort(1035);
				//long m_lRoomID;       //房间ID
				data.writeInt(room.m_szRoomId);
				//来源用户ID
				var _bty:ByteArray = Operation.getOperation().long2Bytes(user.uid, true);
				data.writeBytes(_bty, 0, 8);
				//会话密钥
				data.writeInt(RoomModel.getRoomModel().key);
			}else {
				data.writeShort(8002);
				data.writeInt(room.m_szRoomId);//roomid
				data.writeInt(RoomModel.getRoomModel().key);
			}
			return getData(data);
		}
		
		/**
		 *服务器信息请求包**********************************************************************************************
		 * 登陆成功后请求
		 * STRU_CL_CAS_SERVER_INFO_RQ
		 *  #define DEF_CHAT_USER_LIST_RQ		0  //用户列表
		   #define DEF_MEDIA_CONFIG_INFO_RQ	1  //多媒体配置参数
		   #define DEF_ROOM_PROPERTY_RQ		2  //房间属性
		   #define DEF_ROOM_GIFT_PRICE_RQ		3  //礼物价格列表
		   #define DEF_ROOM_EQUIP_PRICE_RQ		4  //道具（装备）价格列表
		   #define DEF_PRIVMIC_MEDIA_CONFIG_RQ 5  //私麦的媒体配置参数
		   #define DEF_CMS_INFO_LIST_RQ		6  //可用cms地址列表请求
		   #define DEF_CHAT_USER_COMEIN_RQ     7   // 请求房间内用户的进场特效
		   #define DEF_USER_ACTION_RQ
		   STRU_CL_CAS_SERVER_INFO_RQ

		   PACK_CL_CAS_SERVER_INFO_RQ=1003
		 *************************************************************************************************************/
		public function _1003(type:int):ByteArray {
			//trace("RoomWriteData  _1003",type);
			var cmd:int = 1003;
			//if (!user.isLongUser) cmd = 8006;
			if(room.loginServerType!="roomProx")cmd = 8006;
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			
			//类型
			data.writeShort(cmd);
			//long m_lRoomID;       //房间ID
			data.writeInt(room.m_szRoomId);
			//来源用户ID
			bty = Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			//会话密钥
			data.writeInt(RoomModel.getRoomModel().key);
			//请求的数据类型
			data.writeShort(type);
			//备用参数
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(232323, true);
			data.writeBytes(bty, 0, 8);
			bty.length = 0;			
			return getData(data);
		}
		
		/**
		 *发送聊天
		 **/
		public function _1007(DstUserID:Number = 0, fontColor:int = 0, fontSize:int = 11, effects:int = 1, fontName:String = "宋", mes:String = "大家好",Private:int=0):ByteArray {
			////trace("发送聊天信息");
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			//类型
			data.writeShort(1007);
			//long m_lRoomID;       //房间ID
			data.writeInt(room.m_szRoomId);
			//来源用户ID
			bty = Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			//会话密钥
			data.writeInt(RoomModel.getRoomModel().key);
			//目的用户ID: 0为大家,>0时转发到用户，<0时转发到家族中（判断m_bIsPrivate，ture为全部家族，false为转发到 0-m_i64DstUserID家族中 ）
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(DstUserID, true);
			data.writeBytes(bty, 0, 8);
			////公共信息标识 0:公聊
			data.writeByte(Private);
			//信息大小/////////////////////////////
			bty.length = 0;
			bty.endian = Endian.LITTLE_ENDIAN;
			bty.writeShort(0);
			bty.writeInt(fontColor); //字体颜色
			bty.writeShort(fontSize); //字体大小
			bty.writeInt(effects); //斜体 7  1：正常
			//byt.writeShort(2); //长度
			bty.writeShort(Operation.getOperation().String_Byt_Length(fontName)); //长度
			bty.writeMultiByte(fontName, "GB2312");
			bty.writeShort(Operation.getOperation().String_Byt_Length(mes)); //长度
			bty.writeMultiByte(mes, "GB2312");
			data.writeShort(bty.length);
			data.writeBytes(bty, 0, bty.length);			
			return getData(data);
		}

		/**
		 * 送礼物
		 * //用户赠送礼物请求  C结构体
		   struct STRU_CL_CAS_PRESENT_GOODS_RQ
		   {
		   long		m_lRoomID;			 //房间id
		   INT64		m_i64UserID;		 //当前发言人ID
		   long		m_nSessionKey;       //会话密钥
		   INT64		m_i64RecvUserID;	 //接收用户ID
		   BYTE        m_bIsPrivate;		 //是否悄悄的
		   long        m_lGoodsID;          //商品ID
		   long        m_lBaseGoodsID;      //商品基本分类ID
		   long        m_lGoodsCount;       //数量
		   public:
		   DECLEAR_STD_PACK_SERIALIZE();
		   };
		 **/
		public function _1045(RecvUserID:int = 0, m_lGoodsID:int = 1605, m_lBaseGoodsID:int = 7412, m_lGoodsCount:int = 1):ByteArray {
			////trace("送礼物");
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			//类型
			data.writeShort(1045);
			//long m_lRoomID;       //房间ID
			data.writeInt(room.m_szRoomId);
			//来源用户ID
			bty = Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			//会话密钥
			data.writeInt(RoomModel.getRoomModel().key);
			//接收用户ID 0:为大家
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(RecvUserID, true);
			data.writeBytes(bty, 0, 8);
			//是否悄悄
			data.writeByte(0);
			//商品ID
			data.writeInt(m_lGoodsID);
			//商品分类ID
			data.writeInt(m_lBaseGoodsID);
			//商品数量
			data.writeInt(m_lGoodsCount);
			Log.out("送礼物：",user.uid,RecvUserID)
			return getData(data);
		}
		
		
		//enum_Act_Text_Chat,             //文本聊天(m_lOtherParam:1:公聊，0：私聊)
		//enum_Act_VideoPhoneCall,		//邀请语音对话(m_lOtherParam:视频大小)
		//enum_Act_Record_Wave_RQ,        //录音请求(m_lOtherParam:1开始,0停止)
		//enum_Act_Record_Video_RQ,       //录像请求(m_lOtherParam:1开始,0停止)
		//enum_Act_Capture_BMP_RQ,        //抓图请求
		//enum_Act_SendFlower,            //献花,喝彩
		//enum_Act_PresentGift,           //赠送礼物
		//enum_Act_StopVideoPhone,		//停止视频对聊
		//enum_Act_RejectText = 11,		//拒绝文本聊天(m_lOtherParam:0表示取消，1：表示禁止)
		//enum_Act_RejectAudio,			//拒绝语音(m_lOtherParam:0表示取消，1：表示禁止)	
		//enum_Act_PrivyPhoneCall,		//私密视频对话(m_lOtherParam:视频大小)
		//enum_Act_ClearTuya,				//清除涂鸦
		//enum_Act_LookPrivVideo,			//看私人视频（私麦）（m_lOtherParam：0表示取消，1：表示申请）
		//enum_Act_KickPrivVideoLooker,	//踢出私人视频（私麦）观众（m_lOtherParam：无定义）
		//enum_Act_User_Get_Job_Gift,		//获取献花
		//enum_Act_Send_Star_Gift,18		//粉丝献花
		//enum_Act_Fans_Star,				//粉明星
		/**
		 * 对其他用户操作
		 *@param RecvUserID:操作的用户ID  默认:0大家
		 *@param type:操作类型 参考上面注释
		 *@param lOtherParam:其他参数
		*/
		public function _1029(RecvUserID:int=0,type:int=5,lOtherParam:int=4):ByteArray {
			//trace("对其他用户操作");
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			//类型
			data.writeShort(1029);
			//long m_lRoomID;       //房间ID
			data.writeInt(room.m_szRoomId);
			//来源用户ID
			bty = Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			//会话密钥
			data.writeInt(RoomModel.getRoomModel().key);
			//接收用户ID 0:为大家
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(RecvUserID, true);
			data.writeBytes(bty, 0, 8)
			//操作类型
			data.writeByte(type);
		   //其他参数
			data.writeInt(lOtherParam);
			
			return getData(data);
		}
		/**
		 * 管理用户请求
		 * @return
		 */
		
		public function _1010(adminId:int, RecvUserID:int, type:int, mes:String,time:Number=0):ByteArray {
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			//类型
			data.writeShort(1010);
			//long m_lRoomID;       //房间ID
			data.writeInt(room.m_szRoomId);
			//管理员id
			bty = Operation.getOperation().long2Bytes(adminId, true);
			data.writeBytes(bty, 0, 8);
			//会话密钥
			data.writeInt(RoomModel.getRoomModel().key);
			
			//处理类型：任命临时管理员；免除临时管理员；禁止用户发言；临时踢出用户；限时踢出用户；
			data.writeByte(type);
			//被处理ID
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(RecvUserID, true);
			data.writeBytes(bty, 0, 8);
			//时间
		    data.writeInt(time);
			
			bty.length = 0;
		    bty.writeShort(Operation.getOperation().String_Byt_Length(mes)); //长度
		    bty.writeMultiByte(mes, "GB2312");
			data.writeBytes(bty, 0, bty.length);
			return getData(data);
		}
		/** 
		    enum_RoomManage_GetBlackUserList = 0,	//索取黑名单列表
			enum_RoomManage_CancelBlackUser = 1,	//取消黑名单
			enum_RoomManage_GetBlackIPList = 2,		//索取黑IP列表
			enum_RoomManage_CancelBlackIP = 3,		//取消黑IP
			enum_RoomManage_RoomNotify = 4,			//房间广播
			enum_RoomManage_ModifyState = 5,		//修改房间状态
			enum_RoomManage_PlugNotify = 6,			//插件提示
			enum_RoomManage_ChargeNotify = 7,		//收费信息提示	m_lOtherParam:tip停留时间(s) 0:默认 -1:一直存在直到用户关闭
			enum_RoomManage_RebroaderList = 8,		//通知转播员列表（只有9000这个号码有这个权限）
			enum_RoomManage_ChatRoomGameNotify = 9,	//房间游戏提示 m_lOtherParam:tip停留时间(s) 0:默认 -1:一直存在直到用户关闭
			enum_RoomManage_NotifyAnser	= 10,		//提示应答
		**/
		
		
		/**
		 *房间管理 1032
		 *@param type :处理类型
		 *@param dsUid:处理的Uid
		 *@param mParam : 其他参数
		 *@param tchar:描述
		 */
		public function _1032(type:Number,dsUid:Number,mParam:Number,tchar:*):ByteArray{
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			//类型
			data.writeShort(1032);
			//房间id
			data.writeInt(room.m_szRoomId);
			//INT64		m_i64ManagerId;			//管理员ID
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			//long		m_nSessionKey;          //会话密钥
			data.writeInt(RoomModel.getRoomModel().key);
			//BYTE		m_byOptType;			//处理类型
			data.writeInt(type);
			//INT64		m_i64DstUserId;			//被处理用户ID
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(dsUid, true);
			data.writeBytes(bty, 0, 8);
			//DWORD     	m_lOtherParam;			//其他参数
			data.writeShort(mParam);
			//TCHAR		m_szDescribe[DEF_MAX_DESCRIBE_LEN + 1];	////当前操作的描述(踢人的话，就是踢人原因)
			if(mParam==4){
				bty.length = 0;
				bty.writeShort(Operation.getOperation().String_Byt_Length(tchar)); //长度
				bty.writeMultiByte(tchar, "GB2312");
				data.writeBytes(bty, 0, bty.length);
			}	
			return getData(data);
		}
		
		/**
		 *发送小喇叭 1048
		 *@param mes:喇叭消息
		 *@param m_byBugleType :喇叭类型 0小喇叭 默认0
		 *@param m_byBackPic:背景图片id 默认0
		 *@param m_byScope:范围 默认0
		 *@param m_byRepeatTimes:重复次数
		 *@param m_szFontName:字体
		 *@param m_byFontSize:大小
		 *@param m_dwFontColor:字体颜色 
		 */
		public function _1048(mes:String,m_byBugleType:Number,m_byBackPic:Number,m_byScope:Number,m_byRepeatTimes:Number,m_szFontName:String,m_byFontSize:Number,m_dwFontColor:Number):ByteArray {
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			//类型
			data.writeShort(1048);
			//data.writeShort(1168);
			//房间id	
			data.writeInt(room.m_szRoomId);
			//当前发言人ID
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			//会话密钥
			data.writeInt(RoomModel.getRoomModel().key);
			//类型
			data.writeByte(m_byBugleType);
			//背景图片
			data.writeByte(m_byBackPic);
			//范围
			data.writeByte(m_byScope);
			//重复次数
			data.writeByte(m_byRepeatTimes);
			//字体名称
			data.writeShort(Operation.getOperation().String_Byt_Length(m_szFontName)); //长度
			data.writeMultiByte(m_szFontName, "GB2312");
			//字体大小
			data.writeByte(m_byFontSize);
			//字体颜色
			data.writeInt(m_dwFontColor);
			//消息文字
			data.writeShort(Operation.getOperation().String_Byt_Length(mes)); //长度
			data.writeMultiByte(mes, "GB2312");
			
			//trace("我发了->>",mes,room.m_szRoomId,user.uid,RoomModel.getRoomModel().key)
			//data.writeInt(0);
			return getData(data);
		}
		
		/**
		struct  STRU_CL_CAS_SEND_BUGLE_RQ_V2
		{
			long	  m_lRoomID;	    //房间id	
			INT64    m_i64UserID;    //用户id
			long     m_lSessionKey;  //会话密钥
			BYTE     m_byBugleType; //类型 0表示个人喇叭 1表示系统喇叭
			BYTE     m_byBackPic;     //背景图片
			BYTE     m_byScope;       //范围 0 表示全站 1表示 区喇叭
			BYTE     m_byRepeatTimes;        //重复次数
			char    m_szFontName[56+1];      //字体名称
			BYTE     m_byFontSize;           //字体大小
			DWORD    m_dwFontColor;         //字体颜色
			char    m_szMsgText[255+1];    //消息文字
			BYTE     m_byBusinessType;       //业务类型
			INT64    m_i64OtherData;        //其他参数备用

		*/
		public function _1153(mes:String,m_byBugleType:Number,m_byBackPic:Number,m_byScope:Number,m_byRepeatTimes:Number,m_szFontName:String,m_byFontSize:Number,m_dwFontColor:Number):ByteArray {
			
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			//类型
			data.writeShort(1153);
			//data.writeShort(1168);
			//房间id	
			data.writeInt(room.m_szRoomId);
			//当前发言人ID
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			//会话密钥
			data.writeInt(RoomModel.getRoomModel().key);
			//类型
			data.writeByte(m_byBugleType);
			//背景图片
			data.writeByte(m_byBackPic);
			//范围
			data.writeByte(m_byScope);
			//重复次数
			data.writeByte(m_byRepeatTimes);
			//字体名称
			data.writeShort(Operation.getOperation().String_Byt_Length(m_szFontName)); //长度
			data.writeMultiByte(m_szFontName, "GB2312");
			//字体大小
			data.writeByte(m_byFontSize);
			//字体颜色
			data.writeInt(m_dwFontColor);
			//消息文字
			data.writeShort(Operation.getOperation().String_Byt_Length(mes)); //长度
			data.writeMultiByte(mes, "GB2312");
			
			//trace("我发了->>",mes,room.m_szRoomId,user.uid,RoomModel.getRoomModel().key)
			data.writeInt(0);
			data.writeInt(0);
			return getData(data);
		}
		
		/**
		 *公共资源请求1027
		 * @param m_byOptType:4排麦
		 * @param m_lOtherParam:1.申请资源 0:放弃资源
		 */
		public function _1027(m_byOptType:int=4,m_lOtherParam:int=1):ByteArray{
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			//类型
			data.writeShort(1027);
			//房间id	
			data.writeInt(room.m_szRoomId);
			//当前发言人ID
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			//会话密钥
			data.writeInt(RoomModel.getRoomModel().key);
			//操作类型（排麦 放麦 是否接收语音 是否视频） 4
			data.writeByte(m_byOptType);
			//辅助参数( 见ENUM_USER_OPERATE_TYPE 定义 ) 1,0
			data.writeInt(m_lOtherParam);
			if (m_byOptType == 4) {
				Log.out("_1027:","JS 调用上麦")
			}
			
			return getData(data);
		}
		
		/**
		 *1026  发言用户的流ID通知
		 * @param mic :麦系号
		 * @param m_lAudioChannelID:语音流ID
		 * @param m_lVideoChannelID:视频流id
		 * @param m_byMicType:麦类型
		 */
		public function _1026(mic:int,m_lAudioChannelID:Number,m_lVideoChannelID:Number,m_byMicType:int):ByteArray{
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			//类型
			data.writeShort(1026);
			//房间id	
			data.writeInt(room.m_szRoomId);
			//当前发言人ID
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			//会话密钥
			data.writeInt(RoomModel.getRoomModel().key);
			//麦序号
			data.writeShort(mic);
			//语音流ID
			data.writeInt(m_lAudioChannelID);
			//视频流id
			data.writeInt(m_lVideoChannelID);
			//麦类型
			data.writeByte(m_byMicType);
			
			return getData(data);
		}
		
		/**
		 * 全站广播请求 1051
		    long	m_lRoomID;		 //房间id	
			INT64   m_i64UserID;    //当前发言人ID
			long	m_nSessionKey;       //会话密钥
			BYTE    m_byScope;			//范围
			TCHAR    m_szFontName[56+1];	//字体名称
			BYTE    m_byFontSize;		//字体大小
			DWORD   m_dwFontColor;		//字体颜色
			TCHAR    m_strMsgText[255+1];  //消息文字
			BYTE	m_byNotifyType;	// 公告类型
		 */
		public function _1051(m_byScope:Number,fontName:String,fSize:Number,fColor:Number,mes:String,m_byNotifyType:Number):ByteArray {
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			//类型
			data.writeShort(1051);
			//房间id	
			data.writeInt(room.m_szRoomId);
			//当前发言人ID
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			//会话密钥
			data.writeInt(RoomModel.getRoomModel().key);
			//范围
			data.writeByte(m_byScope);
			//字体名称
			data.writeShort(Operation.getOperation().String_Byt_Length(fontName)); //长度
			data.writeMultiByte(fontName, "GB2312");
			//字体大小
			data.writeByte(fSize);
			//字体颜色
			data.writeInt(fColor);
			//消息文字
			data.writeShort(Operation.getOperation().String_Byt_Length(mes)); //长度
			data.writeMultiByte(mes, "GB2312");
			//公告类型
			data.writeByte(m_byNotifyType);
			
			return getData(data);
		}
		
		/**
		 * 从WRS得到视频帧数   返回1009
		 */
		
		public function GetWRsFrame():ByteArray {
			////trace("请求视频帧");
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			
			//类型
			data.writeShort(8008);
			//long m_lRoomID;       //房间ID
			data.writeInt(room.m_szRoomId);
			//来源用户ID
			bty = Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			bty.length = 0;
			return getData(data);
		}
		
		/**
		 * 用户资料变化请求
		 * enum_User_Property_Nick = 0,              //用户昵称
		 enum_User_Property_Phono = 1,             //用户头像
		 enum_User_Property_State = 2,             //房间状态
		 enum_User_Property_Rule = 3,              //用户权限
		 enum_User_Property_Equip = 4,             //装备情况
		 enum_User_Property_Tuya = 5, 
		 * @param type 类型 
		 * @param str 值            
		 */
		public function _1054(type:int,str:String):ByteArray{
			//trace(1054);
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();	
			//类型
			data.writeShort(1054);
			//用户id;
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			//房间
			data.writeInt(room.m_szRoomId);	
			//会话密钥
			data.writeInt(RoomModel.getRoomModel().key);
			
			data.writeByte(1);
			
			
			//属性类型(详见:enum_User_Property_Type)
			data.writeShort(type);
			//字体名称
			data.writeShort(Operation.getOperation().String_Byt_Length(str)); //长度
			data.writeMultiByte(str, "GB2312");
			
			return getData(data);
		}
		
		/***************************************************************************
		 * 明星系列
		 ***************************************************************************/
		/**
		 *明星信息请求包 
		 *  long		     m_lSvrID;			//SVRid
			long		     m_lSessionKey;		//会话密钥
			BYTE             m_byType;          //请求消息的类型，参考enum_star_system_type
			INT64            m_i64UserID;       //请求的用户ID
			long             m_lRoomID;         //用户来自的房间ID（供CAS根据房间ID做纠正）
			long             m_lJobID;           //请求的职业ID
			INT64            m_iExtend64Value;  //扩展值
			
			类型定义
			         1    //用户相关信息请求包
					 2    //明星信息应答
					 3    //是否是明星粉丝查询应答
					 4    //职业信息查询
					 5    //用户拥有可送礼物个数应答
					 6    //用户粉明星应答
		 */
		public function _3503(m_lSvrID:Number,m_byType:Number,m_lJobID:Number,m_iExtend64Value:Number):ByteArray {
			////trace(3503,m_lSvrID,m_byType,m_lJobID,m_iExtend64Value)
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			
			//类型
			data.writeShort(3503);
			//SVRid
			data.writeInt(m_lSvrID);
			//会话密钥
			data.writeInt(RoomModel.getRoomModel().key);
			//请求消息的类型
			data.writeByte(m_byType);
			//请求的用户ID
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			//用户来自的房间ID
			data.writeInt(room.m_szRoomId); 
			//请求的职业ID
			data.writeInt(m_lJobID); 
			//扩展值
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(m_iExtend64Value, true);
			data.writeBytes(bty, 0, 8);
			return getData(data);
		}
		/**
		 * 更新明星信息请求包
			long		m_lSvrID;			//SVRid
			long		m_lSessionKey;		//会话密钥
			long        m_lVersion;         //版本信息
			long        m_lRoomID;          //用户明星物品信息变化的房间
			INT64       m_i64UserID;        //要更新的用户ID
			INT64       m_iStarID;          //送的明星的ID
			long        m_lUserLevel;       //等级情况（用户积分等级填此参数，红黄VIP贵族写下面参数，用物品ID）
			INT64       m_lUserEquip;       //用户的等级情况（用来判断用户的花的最高上线）
			BYTE        m_byUpdateType;     //要更新的类型（参见ENMU_UPDATE_USER_TYPE）
			long        m_lJobID;           //更新职业类型
			long        m_lCount;           //更新的数量（增值）
		*/
		public function _3505(m_lSvrID:Number,m_iStarID:Number,m_lUserLevel:Number,m_byUpdateType:Number,m_lJobID:Number,m_lCount:Number):ByteArray {
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			
			//类型
			data.writeShort(3505);
			//SVRid
			data.writeInt(m_lSvrID);
			//会话密钥
			data.writeInt(RoomModel.getRoomModel().key);
			//版本信息
			data.writeShort(RoomModel.getRoomModel().m_wClientVer);
			//用户明星物品信息变化的房间
			data.writeInt(room.m_szRoomId); 
			//要更新的用户ID
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			
			//送的明星的ID
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(m_iStarID, true);
			data.writeBytes(bty, 0, 8);
			//等级情况
			data.writeInt(m_lUserLevel);
			
			//用户的等级情况
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(user.m_i64EquipState, true);
			data.writeBytes(bty, 0, 8);
			//要更新的类型
			data.writeByte(m_byUpdateType);
			//更新职业类型
			data.writeInt(m_lJobID);
			//更新的数量（增值）
			data.writeInt(m_lCount);
			
			return getData(data);
		}
		
	}

}