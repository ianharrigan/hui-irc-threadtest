package haxe.ui.style;

class Styles {
	var styles:#if haxe3 Map <String, #else Hash <#end Dynamic>;
	var styleRules:Array<String>;
	
	public var rules(getStyleRules, null):Iterator<String>;
	
	public function new() {
		styles = new #if haxe3 Map <String, #else Hash <#end Dynamic>();
		styleRules = new Array<String>();
	}
	
	public function addStyle(rule:String, style:Dynamic):Dynamic {
		var currentStyle:Dynamic = getStyle(rule);
		if (currentStyle != null) {
			style = StyleManager.mergeStyle(currentStyle, style);
		} else {
			styleRules.push(rule);
		}
		styles.set(rule, style);
		return style;
	}
	
	public function getStyle(rule:String):Dynamic {
		return styles.get(rule);
	}
	
	public function getStyleRules():Iterator<String> {
		return styleRules.iterator();
	}
}