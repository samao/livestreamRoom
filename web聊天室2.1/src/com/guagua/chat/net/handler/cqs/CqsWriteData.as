package com.guagua.chat.net.handler.cqs
{
	//import com.guagua.chat.model.RoomInfo;
	//import com.guagua.chat.model.UserInfo;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.net.handler.WriteBty;
	import com.guagua.chat.util.Operation;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	public class CqsWriteData extends WriteBty
	{
		
		public function CqsWriteData() 
		{
			
		}
		
		/**
		 * 登录
		 * @author idzeir modify:20130701
		 * */
		public function _4001():ByteArray{					
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			
			data.writeShort(4001);
			//uid
			bty.length = 0;
			bty= Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			bty.length = 0;
			
			//key
			data.writeInt(RoomModel.getRoomModel().key);
			//lCategoryID=  0
			data.writeInt(0);
			//m_byVer=2;
			data.writeByte(2);
			//m_lOemID
			data.writeInt(0);
			//m_dwOther
			data.writeShort(0);
			
			return getData(data);
		}
		
		/**
		 *INT64	m_i64UserID;						//用户id
		  long    m_lSessionKey;                      //会话密钥
	      BYTE	m_byVer;							//请求版本，应答包的版本不同
	      long	m_lOemID;							//OEM ID
	      DWORD	m_dwOther;							//其他参数
		  */
		public function _4026():ByteArray {
			
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			
			data.writeShort(4026);
			//用户id
			bty.length = 0;
			bty= Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			bty.length = 0;
			
			data.writeInt(RoomModel.getRoomModel().key);
			data.writeByte(0);
			data.writeInt(7);
			data.writeInt(0);
		
			return getData(data);	
		}
		/**
		 *  e_cl_Cqs_Ask_Last_Gift			= 0,		//最后的一个礼物
			e_cl_Cqs_Ask_Bugle_Gift			= 1,		//请求新小喇叭和超级礼物，此类型当前已不使用，2009-11-26
			e_cl_Cqs_Ask_RoomAddr			= 2,		//请求房间地址	
			e_cl_Cqs_Ask_New_Notify			= 4,		//请求新房间通告
			e_cl_Cqs_Ask_Plug_Info			= 5,		//请求插件信息
			e_cl_Cqs_Ask_Last_Bugle			= 6,		//请求最后一个小喇叭
			e_cl_Cqs_Ask_Plug_List			= 7,		//请求插件列表，新增
			e_cl_Cqs_Ask_Plug_Info_V2		= 8,		//请求插件信息，第二版，增加文件MD5
			e_cl_Cqs_Ask_RoomAddr_V2		= 9,		//请求房间地址，第二版	
			e_cl_Cqs_Ask_World_Gift         = 10,       //请求世界礼物
			e_cl_Cqs_Ask_AutoRoomAddr       = 11,       //请求自动进入的房间地址,歌舞版本3.0
			e_cl_Cqs_Ask_New_Bugle			=12,		//小喇叭项目，新的请求类型2011.12.28
		 */
			
		//信息请求
		/*struct 	STRU_CL_CQS_INFO_ASK_RQ
		{
			INT64	m_i64UserID;						//用户id
			long    m_lSessionKey;                      //会话密钥
			long	m_lRoomID;							//所在房间
			WORD    m_wAskDataType;						//请求的数据类型	
			INT64   m_dwOtherPara;                      //其他参数

			long	m_lOemID;							//OEM ID
			DWORD	m_dwOther;							//其他参数  4个字节    lastid每次递增

			//客户端汇报到各机房的情况
			WORD	m_wCount;				//个数
			STRU_REPORT_INFO m_oPingInfo[5];	

		public:
			STRU_CL_CQS_INFO_ASK_RQ();
			DECLEAR_STD_PACK_SERIALIZE();
		};*/
		public function _4008(type:int=0,m_dwOther:Number=0,lastid:Number=0):ByteArray{
			//trace("_4008:",m_dwOther);			
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			
			data.writeShort(4008);
			
			//用户id
			bty.length = 0;
			bty= Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			
			//key 
			data.writeInt(0);
			//房间ID
			data.writeInt(room.m_szRoomId);
			//请求的数据类型
			data.writeShort(type);
			
			//其他参数
			bty.length = 0;
			bty= Operation.getOperation().long2Bytes(m_dwOther, true);
			data.writeBytes(bty, 0, 8);
			
			//产品类型
			if(type==12){//礼物填0 拿主战礼物
				//data.writeInt(0);
				data.writeInt(RoomModel.getRoomModel().m_lOemID);
			}else{
				data.writeInt(7);
			}
			//trace("CqsWriteData:__",type)
			//其他参数 上次请求的id，防止重复播放跑道
			data.writeInt(m_dwOther);
			
			//汇报客户端个数
			data.writeShort(1);
			//IDC ID
			data.writeInt(0);
			//客户端Ping值
			data.writeShort(10);
			//扩展数据
			data.writeShort(0);
		
			return getData(data);	
		}
		
	}
}