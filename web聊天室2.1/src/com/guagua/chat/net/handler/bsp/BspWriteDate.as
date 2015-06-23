package com.guagua.chat.net.handler.bsp 
{
	//import com.guagua.chat.model.RoomInfo;
	//import com.guagua.chat.model.UserInfo;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.net.handler.WriteBty;
	import com.guagua.chat.util.Operation;
	//import com.adobe.serialization.json.JSON;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * ...
	 * @author Wen
	 */
	public class BspWriteDate extends WriteBty
	{		
				
		public function BspWriteDate() 
		{
		}
		//登陆
		public function _6003():ByteArray{			
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			
			data.writeShort(6003);
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
		
		
		/*long		m_lSvrID;			//SVRid
		long		m_lSessionKey;		//会话密钥

		long        m_lRoomID;          //发生变化的房间，用户客户端校验
		INT64       m_i64UserID;        //要更新的用户ID
		INT64       m_iExtendValue;        //扩展信息*/
		//明星服务器心跳
		public function _3508():ByteArray {
			//trace("BSPHANDLE:1",3508)
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			
			data.writeShort(3508);
			data.writeInt(0);
			data.writeInt(RoomModel.getRoomModel().key);
			data.writeInt(room.m_szRoomId);
			
			var bty:ByteArray = new ByteArray();
			//用户id
			bty.length = 0;
			bty= Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			
			bty.length = 0;
			bty= Operation.getOperation().long2Bytes(0, true);
			data.writeBytes(bty, 0, 8);
			
			return getData(data);
		}
		
		
		
		 //由客户端到Bsp的转发请求包
		public function _6001(dstId:Number=0,type:Number=3):ByteArray{			
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			
			data.writeShort(6001);
			// 用户ID
			bty.length = 0;
			bty= Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			
			// LGS签发密钥
			for(var i:int=0;i<32;i++){
				data.writeByte(0);
			}
			// 转发类型
			data.writeByte(1);
			
			//用户信息请求包 STRU_USER_INFO_REQUSET
			var STRU_USER_INFO_REQUSET:ByteArray=new ByteArray();
			STRU_USER_INFO_REQUSET.endian=Endian.LITTLE_ENDIAN;
			//版本号 = 1
			STRU_USER_INFO_REQUSET.writeInt(1);
			//请求的用户ID  =ai64UserID
			bty.length = 0;
			bty= Operation.getOperation().long2Bytes(dstId==0?user.uid:dstId, true);
			STRU_USER_INFO_REQUSET.writeBytes(bty, 0, 8);
			//目标的ID  =0
			bty.length = 0;
			bty= Operation.getOperation().long2Bytes(dstId, true);
			STRU_USER_INFO_REQUSET.writeBytes(bty, 0, 8);
			//职业ID   = 1			
			STRU_USER_INFO_REQUSET.writeInt(1);			
			//请求的信息类型ENUM_USER_INFO_REQUEST   =ENUM_OWN_GIFT 3  
			STRU_USER_INFO_REQUSET.writeShort(type);
			
			//扩充参数1  =alUserLevel    计费 普通等级
			if (type == 3) {
				STRU_USER_INFO_REQUSET.writeInt(RoomModel.getRoomModel().myUserInfo.level);
			}else {
				STRU_USER_INFO_REQUSET.writeInt(0);	
			}
			
			//扩展参数2(可以为0） =ai64Param   VIP等级（国王）
			bty.length = 0;
			bty= Operation.getOperation().long2Bytes(user.m_i64EquipState, true);
			STRU_USER_INFO_REQUSET.writeBytes(bty, 0, 8);
			
			//数据长度
			data.writeInt(STRU_USER_INFO_REQUSET.length);
			data.writeBytes(STRU_USER_INFO_REQUSET, 0, STRU_USER_INFO_REQUSET.length);			
		
			//Log.out("请求花篮数",dstId==0?user.uid:dstId,type,"用户vip等级",user.byVipGrade)
			
			return getData(data);
		}
		
		public function _8000(type:uint=0):ByteArray {
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			
			data.writeShort(8000);
			
			// 用户ID
			bty.length = 0;
			bty= Operation.getOperation().long2Bytes(RoomModel.getRoomModel().myUserInfo.uid,true);
			data.writeBytes(bty, 0, 8);
			
			//请求类型
			data.writeShort(type);
			
			var date:Date=new Date(2011,1,10)
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(0, true);
			data.writeBytes(bty, 0, 8);
			
			data.writeInt(0);
			
			data.writeInt(RoomModel.getRoomModel().m_lOemID);
			//trace("bsp8000", user.uid, type, RoomModel.getRoomModel().m_lOemID);
			
			return getData(data);
		}
	}

}