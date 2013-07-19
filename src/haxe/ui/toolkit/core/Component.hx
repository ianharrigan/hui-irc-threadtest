package haxe.ui.toolkit.core;

import flash.events.MouseEvent;
import flash.geom.Point;
import haxe.ui.toolkit.core.Client;
import haxe.ui.toolkit.core.interfaces.IDraggable;

class Component extends StyleableDisplayObject {
	private var _text:String;
	
	public function new() {
		super();
	}

	//******************************************************************************************
	// Overrides
	//******************************************************************************************
	private override function initialize():Void {
		super.initialize();
		
		if (Std.is(this, IDraggable)) {
			addEventListener(MouseEvent.MOUSE_DOWN, _onComponentMouseDown);
		}
	}
	
	//******************************************************************************************
	// Component methods/properties
	//******************************************************************************************
	public var text(get, set):String;
	
	private function get_text():String {
		return _text;
	}
	
	private function set_text(value:String):String {
		if (StringTools.startsWith(value, "@#")) {
			value = value.substr(2, value.length) + "_" + Client.instance.language;
		}
		_text = value;
		return value;
	}
	
	//******************************************************************************************
	// Drag functions
	//******************************************************************************************
	private var mouseDownPos:Point;
	private function _onComponentMouseDown(event:MouseEvent):Void {
		if (Std.is(this, IDraggable)) {
			if (cast(this, IDraggable).allowDrag(event) == false) {
				return;
			}
		}
		
		mouseDownPos = new Point(event.stageX - stageX, event.stageY - stageY);
		root.addEventListener(MouseEvent.MOUSE_MOVE, _onComponentMouseMove);
		root.addEventListener(MouseEvent.MOUSE_UP, _onComponentMouseUp);
	}
	
	private function _onComponentMouseUp(event:MouseEvent):Void {
		root.removeEventListener(MouseEvent.MOUSE_MOVE, _onComponentMouseMove);
		root.removeEventListener(MouseEvent.MOUSE_UP, _onComponentMouseUp);
	}
	
	private function _onComponentMouseMove(event:MouseEvent):Void {
		this.x = event.stageX - mouseDownPos.x;
		this.y = event.stageY - mouseDownPos.y;
	}
}