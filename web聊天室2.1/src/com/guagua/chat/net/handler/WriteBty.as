package com.guagua.chat.net.handler
{

	import com.guagua.chat.model.RoomInfo;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.model.UserInfo;
	import com.guagua.chat.util.GuaguaCipher;
	import com.guagua.chat.util.RC6;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * 公司底层通信包结构
	 * @author weiwen
	 */
	public class WriteBty
	{
		protected var writePacket:ByteArray = new ByteArray();
		public var keyBty:ByteArray;
		public var eType:int = 0
		
		protected var user:UserInfo; 
		protected var room:RoomInfo;
		
		public function WriteBty()
		{
			writePacket.endian = Endian.LITTLE_ENDIAN;
			writePacket.length = 0;
			
			user = RoomModel.getRoomModel().myUserInfo;
			room = RoomModel.getRoomModel().myRoomInfo;
		}
		/**
		 *@param body:对应C++结构体 
		 */
		protected function getData(_body:ByteArray):ByteArray {
			_body.position=0;
			var body:ByteArray
			//加密
			if(eType==1){
				body=GuaguaCipher.getInstance().AesECBEncrypt(_body,keyBty);
			}else{
				body=_body;
			}
			
			//trace("WriteBty getData  ",eType);
			writePacket.length = 0;
			//包头
			writePacket.writeByte(3);
			writePacket.writeByte(2);
			writePacket.writeByte(1);
			
			//版本      1字节 
			writePacket.writeByte(1); 
			//时间
			writePacket.writeShort(34); 
			//加密类型  没加密0
			writePacket.writeByte(eType); 
			//加密后数据长 没加密0
			writePacket.writeShort(body.length); 
			//填充长度     2个字�? 0
			writePacket.writeShort(0); 
			
			writePacket.writeBytes(body, 0, body.length);
			
			//包尾
			writePacket.writeByte(6);
			writePacket.writeByte(5);
			writePacket.writeByte(4);
			return writePacket;
		}
		
	}
}