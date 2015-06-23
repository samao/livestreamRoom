package com.guagua.chat.net.handler
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * ...
	 * @author idzeir
	 */
	public class HandlerMap 
	{
		static private var mapInstance:HandlerMap;
		
		/**cas数据包存储*/
		private var casByteMap:Vector.<ByteArray> = new Vector.<ByteArray>();
		
		/**bsp数据包存储*/
		private var bspByteMap:Vector.<ByteArray> = new Vector.<ByteArray>();
		
		/**acs数据包存储*/
		private var acsByteMap:Vector.<ByteArray> = new Vector.<ByteArray>();
		
		/**goods数据包存储*/
		private var goodsByteMap:Vector.<ByteArray> = new Vector.<ByteArray>();
		
		public function HandlerMap() 
		{
			
		}
		
		static public function getMap():HandlerMap {
			if (mapInstance == null) {
				mapInstance = new HandlerMap();
			}
			return mapInstance;
		}
		
		/**
		 * 存储一个服务器数据；
		 * @paran:key:uint包id
		 * @param:type:包类型，0为cas，1为acs，2为bsp，3为cqs
		 * */
		public function put(value:ByteArray, type:uint = 0):void {
			value.position = 0;
			var byte:ByteArray = new ByteArray();
			byte.endian = Endian.LITTLE_ENDIAN;
			value.readBytes(byte);
			byte.position = 0;
			
			switch(type) {
				case 0:					
					casByteMap.push(byte);
					break
				case 1:
					acsByteMap.push(byte);
					break;
				case 2:
					bspByteMap.push(byte);
					break;
				case 3:
					goodsByteMap.push(byte);
					break;
				default:
					
					break;
			}
		}
		
		/**
		 * 获取一条数据
		 * @param:type:包类型，0为cas，1为acs，2为bsp，3为cqs	
		 * */
		public function getByte(type:uint = 0):ByteArray {
			if (hasByte(type)) {
				switch(type) {
					case 0:
						return casByteMap.splice(0,1)[0];
						break
					case 1:
						return acsByteMap.splice(0,1)[0];
						break;
					case 2:
						return bspByteMap.splice(0,1)[0];
						break;
					case 3:
						return goodsByteMap.splice(0,1)[0];
						break;				
				}
			}
			return null;
		}
		
		/**
		 * 判断是否还有未解数据包;
		 * @param:type:包类型，0为cas，1为acs，2为bsp，3为cqs
		 * */
		public function hasByte(type:uint=0):Boolean {
			switch(type) {
				case 0:
					return (casByteMap.length > 0);
					break
				case 1:
					return (acsByteMap.length > 0);
					break;
				case 2:
					return (bspByteMap.length > 0);
					break;
				case 3:
					return (goodsByteMap.length > 0);
					break;
				default:
					return false
					break;
			}
		}
	}

}