package haxe.ui.toolkit.controls.selection;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.data.IDataSource;
import haxe.ui.toolkit.core.interfaces.IDataComponent;

class List extends Button implements IDataComponent {
	private var _dataSource:IDataSource;
	private var _list:ListView;
	
	private var _maxListSize:Int = 4;
	private var _method:String = "";
	
	private var _selectedIndex:Int = -1;
	private var _selectedItems:Array<ListViewItem>;
	
	public function new() {
		super();
		toggle = true;
	}
	
	//******************************************************************************************
	// Overrides
	//******************************************************************************************
	private override function preInitialize():Void {
		super.preInitialize();
		
		if (_style != null) {
			if (_style.method != null) {
				_method = _style.method;
			}
		}
	}
	
	private override function _onMouseClick(event:MouseEvent):Void {
		super._onMouseClick(event);
		if (_list == null || _list.visible == false) {
			showList();
		} else {
			hideList();
		}
	}
	
	//******************************************************************************************
	// IDataComponent
	//******************************************************************************************
	public var dataSource(get, set):IDataSource;
	
	private function get_dataSource():IDataSource {
		return _dataSource;
	}
	
	private function set_dataSource(value:IDataSource):IDataSource {
		_dataSource = value;
		return value;
	}
	
	//******************************************************************************************
	// Instance methods
	//******************************************************************************************
	public function showList():Void {
		if (_method == "popup") {
			PopupManager.instance.showList(root, dataSource, "Select", _selectedIndex, function(item:ListViewItem) {
				this.text = item.text;
				_selectedItems = new Array<ListViewItem>();
				_selectedItems.push(item);
				this.selected = false;
				var event:Event = new Event(Event.CHANGE);
				dispatchEvent(event);
			});
		} else {
			if (_list == null) {
				_list = new ListView();
				_list.addEventListener(Event.CHANGE, _onListChange);
				_list.dataSource = _dataSource;
				root.addChild(_list);
			}
			
			root.addEventListener(MouseEvent.MOUSE_DOWN, _onRootMouseDown);
			root.addEventListener(MouseEvent.MOUSE_WHEEL, _onRootMouseDown);
			
			_list.x = this.stageX;
			_list.y = this.stageY + this.height;
			_list.width = this.width;
			_list.sprite.filters = [ new DropShadowFilter (4, 45, 0x808080, 1, 4, 4, 1, 3) ];
			
			var n:Int = _maxListSize;
			if (n > _list.listSize) {
				n = _list.listSize;
			}
			
			var listHeight:Float = n * _list.itemHeight + (_list.layout.padding.top + _list.layout.padding.bottom);
			_list.height = listHeight;
			_list.visible = true;
			this.selected = true;
		}
	}
	
	public function hideList():Void {
		if (_list != null) {
			_list.visible = false;
			this.selected = false;
		}
	}
	
	//******************************************************************************************
	// ListView props
	//******************************************************************************************
	public var selectedItems(get, null):Array<ListViewItem>;
	
	private function get_selectedItems():Array<ListViewItem> {
		return _selectedItems;
	}
	
	//******************************************************************************************
	// Event handlers
	//******************************************************************************************
	private function _onRootMouseDown(event:MouseEvent):Void {
		var mouseInList:Bool = false;
		if (_list != null) {
			mouseInList = _list.hitTest(event.stageX, event.stageY);
		}

		var mouseIn:Bool = hitTest(event.stageX, event.stageY);
		if (mouseInList == false && _list != null && mouseIn == false) {
			root.removeEventListener(MouseEvent.MOUSE_DOWN, _onRootMouseDown);
			root.removeEventListener(MouseEvent.MOUSE_WHEEL, _onRootMouseDown);
			hideList();
		}
	}
	
	private function _onListChange(event:Event):Void {
		if (_list.selectedItems != null && _list.selectedItems.length > 0) {
			this.text = _list.selectedItems[0].text;
			_selectedItems = _list.selectedItems;
			hideList();
			
			var event:Event = new Event(Event.CHANGE);
			dispatchEvent(event);
		}
	}
}

private class DropDownList extends ListView {
	public function new() {
		super();
	}
}