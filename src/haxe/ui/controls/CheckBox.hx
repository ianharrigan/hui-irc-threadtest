package haxe.ui.controls;

import haxe.ui.layout.HorizonalLayout;
import nme.events.MouseEvent;
import haxe.ui.core.Component;
import haxe.ui.style.StyleManager;

class CheckBox extends Component {
	private var valueControl:ValueControl;
	private var textControl:Label;
	
	public var selected(get_selected, set_selected):Bool;
	public var value(get_value, set_value):String = "unselected";
	
	public function new() {
		super();
		registerState("over");
		registerState("down");
		
		valueControl = new ValueControl();
		valueControl.verticalAlign = "center";
		valueControl.value = "unselected";
	
		textControl = new Label();
		textControl.verticalAlign = "center";
		
		layout = new HorizonalLayout();
	}
	
	//************************************************************
	//                  OVERRIDES
	//************************************************************
	public override function initialize():Void {
		super.initialize();

		valueControl.addValue("unselected");
		valueControl.addValue("selected");
		
		sprite.useHandCursor = true;
		sprite.buttonMode = true;
		
		textControl.text = text;
		textControl.currentStyle = currentStyle;
		
		addChild(valueControl);
		addChild(textControl);
		
		width = valueControl.width + textControl.width + layout.padding.left + layout.padding.right;
		var cy:Float = Math.max(valueControl.height, textControl.height);
		height = cy + layout.padding.top + layout.padding.bottom;
		
		addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		addEventListener(MouseEvent.CLICK, onMouseClick);
	}

	//************************************************************
	//                  EVENT HANDLERS
	//************************************************************
	private function onMouseOver(event:MouseEvent):Void {
		valueControl.state = "over";
		showStateStyle(valueControl.state);
		textControl.currentStyle = currentStyle;
	}
	
	private function onMouseOut(event:MouseEvent):Void {
		valueControl.state = "normal";
		showStateStyle(valueControl.state);
		textControl.currentStyle = currentStyle;
	}
	
	private function onMouseClick(event:MouseEvent):Void {
		if (valueControl.hitTest(event.stageX, event.stageY) == false) {
			selected = !selected;	
		}
	}
	
	//************************************************************
	//                  GETTERS AND SETTERS
	//************************************************************
	public function get_selected():Bool {
		return (valueControl.value == "selected");
	}
	
	public function set_selected(value:Bool):Bool {
		valueControl.value = (value == true) ? "selected" : "unselected";
		return value;
	}
	
	public function get_value():String {
		return valueControl.value;
	}
	
	public function set_value(value:String):String {
		valueControl.value = value;
		return value;
	}
}