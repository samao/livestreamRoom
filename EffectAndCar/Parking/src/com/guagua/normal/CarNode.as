package com.guagua.normal
{
	
	/**
	 *@Date:2012-12-13 上午10:47:46	
	 */
	/**加载车辆swf名称和资源内id信息*/
	public dynamic class CarNode extends Object
	{
		/**swf文件名称*/
		private var _gid:String="0";
		/**swf文件库内id*/
		private var _libId:String="0";
		
		public function CarNode(sid:String,lid:String)
		{
			gid=sid;
			libId=lid;
		}

		/**swf库内映射id*/
		public function get libId():String
		{
			return _libId;
		}

		/**
		 * @private
		 */
		public function set libId(value:String):void
		{
			_libId = value;
		}

		/**swf库文件名称*/
		public function get gid():String
		{
			return _gid;
		}

		/**
		 * @private
		 */
		public function set gid(value:String):void
		{
			_gid = value;
		}

	}
}