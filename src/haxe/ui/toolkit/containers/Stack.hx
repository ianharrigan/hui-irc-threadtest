package haxe.ui.toolkit.containers;

import flash.events.Event;
import haxe.ui.toolkit.core.Component;
import haxe.ui.toolkit.core.interfaces.IDisplayObject;

class Stack extends Component {
	private var _selectedIndex:Int = 0;
	
	public function new() {
		super();
	}
	
	//******************************************************************************************
	// Overrides
	//******************************************************************************************
	public override function addChild(child:IDisplayObject):IDisplayObject {
		var r = super.addChild(child);
		r.visible = (children.length - 1 == _selectedIndex);
		return r;
	}
	
	//******************************************************************************************
	// Getters/setters
	//******************************************************************************************
	public var selectedIndex(get, set):Int;
	
	private function get_selectedIndex():Int {
		return _selectedIndex;
	}
	
	private function set_selectedIndex(value:Int):Int {
		if (value != _selectedIndex) {
			for (n in 0...children.length) {
				var item:IDisplayObject = children[n];
				if (n == value) {
					item.visible = true;
				} else {
					item.visible = false;
				}
			}
			_selectedIndex = value;
			
			var event:Event = new Event(Event.CHANGE);
			dispatchEvent(event);
		}
		return value;
	}
}