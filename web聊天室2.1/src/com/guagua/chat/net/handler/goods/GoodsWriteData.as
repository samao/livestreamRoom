package com.guagua.chat.net.handler.goods
{
	//import com.guagua.chat.model.RoomInfo;
	//import com.guagua.chat.model.UserInfo;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.net.handler.WriteBty;
	import com.guagua.chat.util.Operation;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * ...
	 * @author Wen
	 */
	public class GoodsWriteData extends WriteBty
	{
		
		public function GoodsWriteData()
		{
			
		}
		//登陆
		public function _62():ByteArray{
			//trace("GoodsWriteData:");
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			//类型
			data.writeShort(62);
			// 用户ID
			bty.length = 0;
			bty= Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			//客户段版本 
			data.writeInt(RoomModel.getRoomModel().m_wClientVer);
			//各产品ID 定义参考enum_All_OemID
			data.writeInt(RoomModel.getRoomModel().m_lOemID);
			
			data.writeInt(0);
			data.writeInt(0);
			
			return getData(data);
		}
		//请求用户装备包
		public function _51():ByteArray {
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			//类型
			data.writeShort(51);
			// 用户ID
			bty.length = 0;
			bty= Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			//m_szUserKey
			for(var i:int=0;i<32;i++){
				//data.writeByte(0);
			}
			var meckbty:ByteArray =Operation.getOperation().meck32Bit(user.mesk);
			data.writeBytes(meckbty, 0, meckbty.length);//外网meck
			
			////数据类型
			data.writeShort(6);
			//其他参数(暂为时间)
			bty.length = 0;
			bty= Operation.getOperation().long2Bytes(Math.floor(Math.random()*10000), true);
			data.writeBytes(bty, 0, 8);
			//其他参数2
			data.writeInt(2);
			//客户端版本号
			data.writeShort(RoomModel.getRoomModel().m_wClientVer);
			//产品分类
			data.writeInt(RoomModel.getRoomModel().m_lOemID);
			Log.out("计费51：请求用户装备",user.uid,user.mesk);
			return getData(data);
		}
	}
}