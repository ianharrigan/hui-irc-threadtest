package haxe.ui.core;

class Globals {
	private static var flags:#if haxe3 Map <String, #else Hash <#end String>;
	
	public static function reset():Void {
		flags = null;
	}
	
	public static function add(id:String):Void {
		if (flags == null) {
			flags = new #if haxe3 Map <String, #else Hash <#end String>();
		}
		flags.set(id, id);
	}
	
	public static function has(id:String):Bool {
		if (flags == null) {
			return false;
		}
		return flags.exists(id);
	}
}