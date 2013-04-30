package haxe.ui.test.irc;

import haxe.ui.containers.ListView;
import haxe.ui.containers.TabView;
import haxe.ui.core.ComponentParser;
import haxe.ui.core.Controller;
import haxe.ui.popup.Popup;
import nme.events.MouseEvent;


class IRCController extends Controller {
	private var connection:IRCConnection;
	
	public static var mainTabs:TabView;
	
	public function new() {
		super(ComponentParser.fromXMLResource("ui/irc.xml"));
		mainTabs = getComponentAs("mainTabs", TabView);
		
		attachEvent("createConnectionButton", MouseEvent.CLICK, onCreateConnection);
	}

	private function onCreateConnection(event:MouseEvent):Void {
		var controller:Controller = new Controller(ComponentParser.fromXMLResource("ui/createConnectionPopup.xml"));
		var createConnectionPopup:Popup = Popup.showCustom(view.root, controller.view, "New Connection", true);
		controller.attachEvent("cancelButton", MouseEvent.CLICK, function (e) {
			Popup.hidePopup(createConnectionPopup);
		});

		controller.attachEvent("connectButton", MouseEvent.CLICK, function (e) {
			var server:String = controller.getComponent("server").text;
			var nickname:String = controller.getComponent("nickname").text;
			if (connection == null) {
				var connectingPopup:Popup = null;
				
				connection = new IRCConnection(server);
				connection.addEventListener(IRCEvent.CONNECTED, function(e) {
					Popup.hidePopup(connectingPopup);
					Popup.hidePopup(createConnectionPopup);
					
					var tabController:IRCTabController = new IRCTabController(connection, nickname);
					tabController.view.text = server + ":6667";
					getComponentAs("mainTabs", TabView).addChild(tabController.view);
					getComponentAs("mainTabs", TabView).selectedIndex = getComponentAs("mainTabs", TabView).pageCount - 1;
				});
				
				connectingPopup = Popup.showBusy(view.root, "Connecting...");
				connection.start();
			}
		});
	}
}