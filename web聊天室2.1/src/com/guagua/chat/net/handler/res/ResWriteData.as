package com.guagua.chat.net.handler.res 
{
	import com.guagua.chat.model.RoomModel;
	//import com.guagua.chat.model.RoomInfo;
	//import com.guagua.chat.model.UserInfo;
	import com.guagua.chat.net.handler.WriteBty;
	import com.guagua.chat.util.Operation;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * ...
	 * @author idzeir
	 */
	public class ResWriteData extends WriteBty 
	{
		
		
		public function ResWriteData() 
		{
		}
		
		/*
		 资源请求包
		 struct STRU_CL_RES_RES_RQ
		 {	
				INT64		m_i64UserID;		///< 用户ID
				WORD        m_wDataType;        //数据类型	
				INT64       m_nOtherParam;		//其他参数(暂为资源信息最后修改时间)
				long		m_lOtherParam2;		//其他参数2(暂为文件类型)
				long		m_lOemID;	
		 }
		 * */
		
		public function _8000(type:uint=0):ByteArray {
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.length = 0;
			var bty:ByteArray = new ByteArray();
			
			data.writeShort(8000);
			
			// 用户ID
			bty.length = 0;
			bty= Operation.getOperation().long2Bytes(user.uid,true);
			data.writeBytes(bty, 0, 8);
			
			//请求类型
			data.writeShort(type);
			
			var date:Date=new Date(2011,12,30)
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(date.time, true);
			data.writeBytes(bty, 0, 8);
			
			data.writeInt(0);
			
			data.writeInt(RoomModel.getRoomModel().m_lOemID);
			//trace("bsp8000", user.uid, type, RoomModel.getRoomModel().m_lOemID);
			
			return getData(data);
		}
	}

}