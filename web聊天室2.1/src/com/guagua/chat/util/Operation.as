package com.guagua.chat.util 
{
	//import com.guagua.chat.model.ResNode;
	//import com.guagua.chat.model.ResTree;
	//import com.guagua.chat.model.RoomModel;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
    import flash.media.Camera;
	/**
	 * ...
	 * @author Wen
	 */
	public class Operation
	{
		private static var instance:Operation;
		public function Operation() 
		{
			
		}
		
		public static function getOperation():Operation {
			if (instance==null) {
				instance = new Operation();
			}
			return instance;
		}
		
		public  function long2Bytes(value:Number,byteSwap:Boolean):ByteArray{
			var _bytes:ByteArray = new ByteArray();
			var index:int = 0;
			var _mask:Number;
			var _shift:int;
			//		int _signShift;
			var nbrOfBits:int = 64;
			var _bitIndex:int = 0;
			var _offset:int = 0;
			var startBit:int = _offset << 3;
			_shift = (!byteSwap) ? 64 - _bitIndex + startBit : _bitIndex - startBit
				- nbrOfBits;
			_mask = (nbrOfBits == 64) ? 0xFFFFFFFFFFFFFFFF
				: ((1 << nbrOfBits) - 1) << _shift;
			//		_signShift = 64 - _shift - nbrOfBits;
			if (_mask == 0xFFFFFFFFFFFFFFFF) { // Non bit-field.
				//            getByteBuffer().putLong(position(), value);
				_bytes[index] =  value;
				_bytes[++index] =  (value >> 8);
				_bytes[++index] =  (value >> 16);
				_bytes[++index] =  (value >> 24);
				//由于AS3中位操作只有32�?所以大�?2位以上的操作用除�?(左移用乘�?
				_bytes[++index] =  value/0x100000000;//value>>32;
				_bytes[++index] =  value/0x10000000000;//value>>40;
				_bytes[++index] =  value/0x1000000000000;///value >> 48;
				_bytes[++index] =  value/0x100000000000000;//value >> 56;
			} else { // Bit-field.
				value <<= _shift;
				value &= _mask;
				//            long orMask = getByteBuffer().getLong(position()) & (~_mask);
				var orMask:Number = (_bytes[index] & 0xff)
					+ ((_bytes[++index] & 0xff) << 8)
					+ ((_bytes[++index] & 0xff) << 16)
					+ ((_bytes[++index] & 0xff) *0x1000000)
					+ ((_bytes[++index] & 0xff) *0x100000000/*<< 32*/)
					+ ((_bytes[++index] & 0xff) *0x10000000000/*<< 40*/)
					+ ((_bytes[++index] & 0xff) *0x1000000000000/*<< 48*/)
					+ (( _bytes[++index]) *0x100000000000000/*<< 56*/);
				//            getByteBuffer().putLong(position(), orMask | value);
				value = orMask | value;
				_bytes[index] =  value;
				_bytes[++index] =  (value >> 8);
				_bytes[++index] =  (value >> 16);
				_bytes[++index] =  (value >> 24);
				_bytes[++index] =  value/0x100000000;//value >> 32;
				_bytes[++index] =  value/0x10000000000;//value >> 40;
				_bytes[++index] =  value/0x1000000000000;//value >> 48;
				_bytes[++index] =  value/0x100000000000000;//value >> 56;
			}
			return _bytes;
		}
		
		public function readLong(body:ByteArray):Number {
			var p:int = body.position;
			var _bytes:ByteArray = new ByteArray();
			var value:Number = 0;
			for (var i:uint = 0; i < 8; i++)
				_bytes[i] = body[p + i];
			value = bytes2Long(_bytes, true);
			body.position=body.position+8;
			
			return value;
		}
		
		public function readGB2312String(body:ByteArray,value:Boolean=false):String {
			//var _strlen:uint = body.readShort();
			var _strlen:uint = body.readUnsignedShort();
			if (value) trace("消息长度：", _strlen);
			if (_strlen == 0) return "";
			return (body.readMultiByte(_strlen, "GB2312"));
		}
		
		public function readASCIIString(body:ByteArray):String {
			var _strlen:uint = body.readShort();
			if (_strlen == 0) return "";
			return (body.readMultiByte(_strlen, "US-ASCII"));
		}
		public  function bytes2Long(_bytes:ByteArray, byteSwap:Boolean):Number {
			var index:int = 0;
			var _mask:Number;
			var _shift:int;
			var _signShift:int;
			var nbrOfBits:int = 64;
			var _bitIndex:int = 0;
			var _offset:int = 0;
			var startBit:int = _offset << 3;
			_shift = (!byteSwap) ? 64 - _bitIndex + startBit : _bitIndex - startBit - nbrOfBits;
			_mask = (nbrOfBits == 64) ? 0xFFFFFFFFFFFFFFFF : ((1 << nbrOfBits) - 1) << _shift;
			_signShift = 64 - _shift - nbrOfBits;
			if (_mask == 0xFFFFFFFFFFFFFFFF){ // Non bit-field.
				//            return getByteBuffer().getLong(p0osition());
				
				return (_bytes[index] & 0xff) + ((_bytes[++index] & 0xff) * 0x100) + ((_bytes[++index] & 0xff) * 0x10000) + ((_bytes[++index] & 0xff) * 0x1000000) + ((_bytes[++index] & 0xff) * 0x100000000 /*<< 32*/) + ((_bytes[++index] & 0xff) * 0x10000000000 /*<< 40*/) + ((_bytes[++index] & 0xff) * 0x1000000000000 /*<< 48*/) + ((_bytes[++index]) * 0x100000000000000 /*<< 56*/);
			} else { // Bit-field.
				//            long value = getByteBuffer().getLong(position());
				var value:Number = (_bytes[index] & 0xff) + ((_bytes[++index] & 0xff) * 0x100) + ((_bytes[++index] & 0xff) * 0x10000) + ((_bytes[++index] & 0xff) * 0x1000000) + ((_bytes[++index] & 0xff) * 0x100000000 /*<< 32*/) + ((_bytes[++index] & 0xff) * 0x10000000000 /*<< 40*/) + ((_bytes[++index] & 0xff) * 0x1000000000000 /*<< 48*/) + ((_bytes[++index]) * 0x100000000000000 /*<< 56*/);
				value &= _mask;
				value <<= _signShift;
				value >>= _signShift + _shift; // Keeps sign.
				return value;
			}
			return 0;
			
		}
		
		//计算排序id
		public function calculationSortNum(uid:int, userRule:int, equipState:Number, equipState2:Number = 0, m_lLimitStarLevel:Number = 10):Number
		{			
			//默认根据用户ID的大小排序，越小越靠�?
			var liUserPower:Number=999999999 - uid;
			//把用户的各种权限累加起来排序
			var liVipGrade:Number=getVipGrade(equipState);
			var liNobilityGrade:Number=getNobilityGrade(equipState);
			var liDiamondGrade:int=giamandGrade(equipState);
			if (userRule >= 50) //权限如果大于普通管理员，靠�?
			{
				if (liVipGrade == 0 && liNobilityGrade == 0 && liDiamondGrade == 0)
				{
					liUserPower+=900000000;
				}
			}
			
			//******************************
			//收费房间的贵宾和计时  增加明星信息排序
			var lbyChargeRoom:Number = (equipState >> 18) & 0x03;
			if (2 == lbyChargeRoom)		//按时收费
			{
				liUserPower += 9000000;
			}
			else if (3 == lbyChargeRoom)	//房间贵宾
			{
				liUserPower += 9000000;
			}				
			
			//Log.out("MAX:", llResID, m_lLimitStarLevel, ResTree.getInstance().size,ResTree.getInstance().hasNode(llResID),resTree.getResProperty(llResID));
			
			//增加对明星等级排序,因明星等级为九级,故做如下处理
			var llStarJobLevel:Number = (equipState2 & 0x7F);
			if ( ((equipState2 >> 7) & 0x1F) > 0 && llStarJobLevel >= m_lLimitStarLevel) //表示是明星
			{				
				liUserPower += llStarJobLevel * 600000;
				liUserPower += 909000000;
			}
			
			
			//*****************************
			
			
			if (liVipGrade >= 1) //如果是VIP
			{
				liUserPower+=liVipGrade * 990000000;
			}
			
			//钻石相当于VIP16-19
			if (liDiamondGrade > 0)
			{
				for (var i:int=3; i >= 0; i--)
				{
					if (getBitState(liDiamondGrade, i))
					{
						liUserPower+=(Number)(i + 16) * 990000000;
						break;
					}
				}
			}
			
			//贵族高一级则在上�?不管对方是多少基本的VIP
			if (liNobilityGrade >= 1) //如果是贵�?
			{
				liUserPower+=(Number)(liNobilityGrade * 34650000000); //35 * 990000000(绿钻+VIP15=34)
			}
			
			
			return liUserPower;
		}
		
		//vip级别
		protected function getVipGrade(equipState:Number):Number
		{
			//trace("vip:" + Number((equipState / 0x1000000000000) & 0x0F));
			return Number((equipState / 0x1000000000000) & 0x0F);
			
		}
		
		//贵族级别
		protected function getNobilityGrade(equipState:Number):Number
		{
			//trace("贵族:" + Number((equipState / 0x1000000000000000) & 0x0F));
			return Number((equipState / 0x1000000000000000) & 0x0F);
		}
		
		//钻石级别
		protected function giamandGrade(equipState:Number):int
		{
			//trace("钻石:" + int((equipState / 0x10000000000000) & 0x0F));
			return int((equipState / 0x10000000000000) & 0x0F);
		}
		
		protected function getBitState(alBitsState:int, abyStateType:int):Boolean
		{
			return ((alBitsState & (0x00000001 << abyStateType)) != 0);
		}
		///////////////////////////////////////////////////////////////////////////////////////////////
		public function meck32Bit(_meck:String):ByteArray {
			var str:String = _meck;
			var bty:ByteArray = new ByteArray();
			bty.endian=Endian.LITTLE_ENDIAN;
			for (var i:int = 0; i < str.length; i++){
				var bb:uint = uint("0x" + str.charAt(i) + str.charAt(i + 1));
				i++;
				bty.writeByte(uint(bb.toString(10)));
			}
			return bty;
		}
		/**
		 * 用户状态
		enum enum_user_state
		{
				enum_user_text_state = 0,         //是否允许文本发言(1：允许，0不允许)
				enum_user_audio_state = 1,        //是否允许语音发言(1：允许，0不允许)
				enum_video_dev_state = 2,         //是否安装摄像头(1:安装,0:不安装) 
				enum_allow_record_state = 3,      //是否允许别人录象录音等(1,允许,0:不允许)
				enum_pub_msg_recv_state = 4,      //是否接收公聊信息 
				enum_priv_msg_recv_state = 5,     //是否接收悄悄话
				enum_loud_msg_recv_state = 6,     //是否接收公开对我说
				enum_hide_in_room_state = 7,      //是否隐身
				enum_flower_msg_recv_state = 8,   //过滤献花信息
				enum_font_size_pass_state = 9,	  //过滤字体大小信息
				enum_auto_recv_video_state = 10,  //自动接收视频
				enum_auto_open_video_state = 11,  //自动打开视频
				enum_refuse_speak_state = 12,     //拒绝上麦状态
				enum_show_inout_msg_state = 13,   //是否显示进出信息
				enum_show_back_pic_state = 14,    //是否显示聊天背景图片
				enum_visitor_state = 15,		  //是否游客
				enum_family_state = 16,			  //是否家族成员
				enum_sys_msg_recv_state = 17,	  //系统消息接收状态
				enum_auto_res_state = 18,		  //自动回复
				enum_video_phone_state = 19,	  //视频电话状态
				enum_refuse_phone_state = 20,	  //自动拒绝电话状态
				enum_luckcard_failmsg_recv_state = 21,  //幸运卡未中奖消息接收状态
				enum_visitor_msg_recv_state = 22,		//是否接收游客消息
				enum_normal_user_msg_recv_state = 23,	//是否接收普通用户及以下
				enum_yellow_vip_msg_recv_state = 24,	//是否接收黄色VIP及以下
				enum_red_vip_msg_recv_state = 25,		//是否接收红色VIP及以下
				enum_auto_pop_private_mic=26,           //自动弹出私麦
				enum_family_msg_recv_state = 27,		//是否拒收家族频道聊天信息
				enum_nobility_msg_recv_state = 28,      //是否拒收贵族广播信息
				enum_end_of_state 		//结束标志
		  };
		 */
		public function userStateBit(mediaAry:Array=null):uint {
			var b0:uint = 0;
			//先默认都可以使用
			for (var i:int = 0; i < 30; i++) {
				b0 |= (1 << i);//先向左移位
			}
			//web用户 限制
			//b0 = b0 ^ 1 << 1;
			if(Camera.names.length==0)b0 = b0 ^ 1 << 2; //是否安装摄像头
			b0 = b0 ^ 1 << 17;//
			b0 = b0 ^ 1 << 19;
			
			return b0;
		}
		
		public function String_Byt_Length(str:String):int {
			var _ba:ByteArray = new ByteArray;
			_ba.writeMultiByte(str, "");
			return _ba.length;
		}

		//解密ip
		public function intIp2Str(uIp:uint):String{
			
			var date1:uint = (uIp & 0xff000000) >> 24 & 0x000000ff;   
			var date2:uint = (uIp & 0x00ff0000) >> 16;   
			var date3:uint = (uIp & 0x0000ff00) >> 8;   
			var date4:uint = uIp & 0x000000ff;   
			//Log.out("解析IP",date4.toString() + "." + date3.toString() + "." + date2.toString() + "." + date1.toString())
			return date4.toString() + "." + date3.toString() + "." + date2.toString() + "." + date1.toString(); 
		}	
		
		//加密ip
		public function enIp2Num(ipStr:String):Number
		{
			var _temp:uint = 0;

			var ipArr:Array = ipStr.split(".");

			_temp |=  Number(ipArr[0]);
			_temp |=  Number(ipArr[1]) << 8;
			_temp |=  Number(ipArr[2]) << 16;
			_temp |=  Number(ipArr[3]) << 24;
			return _temp;
		}
		
		/**
		 * 检测flashplayer版本
		 * @param	verArr:Array 需要匹配的版本
		 * @return	版本大于匹配版本返回true，否则返回false
		 */
		public function compareVersion(verArr:Array):Boolean
		{
			var version:String = flash.system.Capabilities.version;
			var regExp:RegExp = /\d+/g;
			var pVArr:Array = version.match(regExp);
			var cVersion:Number = Number(pVArr[0]) << 24 | Number(pVArr[1]) << 16 | Number(pVArr[2]) << 8 | Number(pVArr[3]);
			var pVersion:Number = Number(verArr[0]) << 24 | Number(verArr[1]) << 16 | Number(verArr[2]) << 8 | Number(verArr[3]);
			return (cVersion >= pVersion);
		}
	}

}