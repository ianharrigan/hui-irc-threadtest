package haxe.ui.core;

import nme.display.Sprite;
import nme.events.Event;
import nme.events.EventDispatcher;
import nme.filters.DropShadowFilter;
import nme.Lib;
import haxe.ui.style.StyleManager;

class Root {
	private static var roots:Array<Root>;
	
	public var component:Component;
	private var initOptions:Dynamic;
	
	public var width(get_width, null):Float;
	public var height(get_height, null):Float;
	
	private var disabledOverlay:Component;
	public var enabled(default, set_enabled):Bool = true;
	
	public static function createRoot(options:Dynamic = null):Root {
		if (roots == null) {
			roots = new Array<Root>();
		}
		var r:Root = new Root();
		r.initialize(options);
		roots.push(r);
		return r;
	}

	public static function destroyAll():Void {
		if (roots != null) {
			for (r in roots) {
				r.destroy();
			}
		}
	}
	
	public function new() {
		
	}
	
	public function initialize(options:Dynamic = null):Void {
		initOptions = options;
		if (initOptions == null) {
			initOptions = { };
		}
		initOptions.parent = (initOptions.parent != null) ? initOptions.parent : Lib.current.stage;
		
		component = new Component();
		component.root = this;
		//component.addStyleName("Root");
		if (initOptions.additionalStyles != null) {
			component.styles = initOptions.additionalStyles;
		}
		if (initOptions.id != null) {
			component.id = initOptions.id;
		} else {
			component.id = "root";
		}
		component.horizontalAlign = "";
		component.verticalAlign = "";
		//component.autoSize = true;
		component.x = (initOptions.x != null) ? initOptions.x : 0;
		component.y = (initOptions.y != null) ? initOptions.y : 0;
		component.width = (initOptions.width != null) ? initOptions.width : 0;
		component.height = (initOptions.height != null) ? initOptions.height : 0;
		
		//component.setScrollRect(20, 20, component.width - 40, component.height - 40);
		if (initOptions.useShadow != null && initOptions.useShadow == true) {
			component.sprite.filters = [ new DropShadowFilter (4, 45, 0x808080, .7, 4, 4, 1, 3) ];
		}
		
		resizeRoot(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		initOptions.parent.addChild(component.sprite);
		cast(initOptions.parent, EventDispatcher).addEventListener(Event.RESIZE, onResize); // if this doesnt work, its a good thing
	}
	
	public function destroy():Void {
		cast(initOptions.parent, EventDispatcher).removeEventListener(Event.RESIZE, onResize); // if this doesnt work, its a good thing
		if (disabledOverlay != null && component.contains(disabledOverlay)) { // TODO: shouldnt need "contains" clause
			component.removeChild(disabledOverlay);
			disabledOverlay = null;
		}
		if (component != null) {
			component.dispose();
			initOptions.parent.removeChild(component.sprite);
			component = null;
		}
	}
	
	public function addChild(c:Dynamic):Dynamic {
		if (Std.is(c, Component)) { // TODO: doenst feel like the  right method to stop components overflowing when not fullscreen
			cast(c, Component).setScrollRect(0, 0, component.innerWidth, component.innerHeight);
		}
		var r = component.addChild(c);
		return r;
	}
	
	public function removeChild(c:Dynamic):Dynamic {
		var r = component.removeChild(c);
		return r;
	}
	
	public function bringToFront(c:Dynamic):Void {
		component.bringToFront(c);
	}

	public function addEventListener(type:String, listener:Dynamic->Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void {
		var target = Lib.current.stage;
		target.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}	
	
	public function removeEventListener(type:String, listener:Dynamic->Void, useCapture:Bool = false):Void {
		var target = Lib.current.stage;
		target.removeEventListener(type, listener, useCapture);
	}
	
	//************************************************************
	//                  EVENT HANDLERS
	//************************************************************
	private function onResize(event:Event) {
		resizeRoot(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		//repositionCurrentPopup();
		for (c in component.listChildComponents()) { // TODO: if components autosize then scrollrect needs to be updated accordingly
			c.setScrollRect(0, 0, component.innerWidth, component.innerHeight);
		}
	}
	
	//************************************************************
	//                  HELPERS
	//************************************************************
	public function resizeRoot(width:Float, height:Float):Void {
		if (initOptions.width != null) {
			component.width = initOptions.width;
		} else {
			component.width = width;
		}
			
		if (initOptions.height != null) {
			component.height = initOptions.height;
		} else {
			component.height = height;
		}
		
		resizeDisabledOverlay();
	}
	
	//************************************************************
	//                  GETTERS AND SETTERS
	//************************************************************
	public function get_width():Float {
		if (component == null) {
		}
		return component.width;
	}
	
	public function get_height():Float {
		if (component == null) {
		}
		return component.height;
	}

	public function set_enabled(value:Bool):Bool {
		enabled = value;
		if (value == true) {
			if (disabledOverlay != null) {
				disabledOverlay.visible = false;
			}
		} else {
			if (disabledOverlay == null) {
				disabledOverlay = new Component();
				disabledOverlay.id = "disabledOverlay";
				disabledOverlay.sprite.alpha = .5;
				//disabledOverlay.addEventListener(MouseEvent.CLICK, onDisabledOverlayClick);
				component.addChild(disabledOverlay);
			}

			resizeDisabledOverlay();
			component.bringToFront(disabledOverlay);
			disabledOverlay.visible = true;
		}
		return value;
	}
	
	private function resizeDisabledOverlay():Void {
		if (disabledOverlay != null) {
			disabledOverlay.width = Std.int(component.width - (component.layout.padding.left + component.layout.padding.right));
			disabledOverlay.height = Std.int(component.height - (component.layout.padding.top + component.layout.padding.bottom));
		}
	}
}