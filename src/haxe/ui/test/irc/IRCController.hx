package haxe.ui.test.irc;

import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.containers.TabView;
import haxe.ui.toolkit.controls.popups.Popup;
import haxe.ui.toolkit.core.Component;
import haxe.ui.toolkit.core.Controller;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.core.XMLController;
import flash.events.MouseEvent;


class IRCController extends XMLController {
	private var connection:IRCConnection;
	
	public static var mainTabs:TabView;
	
	public function new() {
		super("ui/irc.xml");
		mainTabs = getComponentAs("mainTabs", TabView);
		
		attachEvent("createConnectionButton", MouseEvent.CLICK, onCreateConnection);
	}

	private function onCreateConnection(event:MouseEvent):Void {
		var controller:Controller = new XMLController("ui/createConnectionPopup.xml");
		var createConnectionPopup:Popup = PopupManager.instance.showCustom(root, controller.view, "New Connection", PopupButtonType.CONFIRM | PopupButtonType.CANCEL, function(b) {
			if (b == PopupButtonType.CONFIRM) {
				if (connection != null) {
					connection.close();
					connection = null;
				}
				
				var server:String = controller.getComponent("server").text;
				var nickname:String = controller.getComponent("nickname").text;
				
				if (connection == null) {
					var connectingPopup:Popup = null;
					connection = new IRCConnection(server);
					connection.addEventListener(IRCEvent.CONNECTED, function(e) {
						connectingPopup = PopupManager.instance.showBusy(root, "Logging in as " + nickname + "...");
						connection.login(nickname);
					});
					
					connection.addEventListener(IRCEvent.LOGGED_IN, function(e) {
						PopupManager.instance.hidePopup(connectingPopup);
						connectingPopup = null;
						var tabController:IRCTabController = new IRCTabController(connection, nickname);
						tabController.view.id = "ircTab";
						cast(tabController.view, Component).text = server;
						getComponentAs("mainTabs", TabView).addChild(tabController.view);
						getComponentAs("mainTabs", TabView).selectedIndex = getComponentAs("mainTabs", TabView).pageCount - 1;
					});
					
					connection.addEventListener(IRCEvent.ERROR, function (e:IRCEvent) {
						trace("ERROR " + e.data);
						PopupManager.instance.hidePopup(connectingPopup);
						connectingPopup = null;
						PopupManager.instance.showSimple(root, "Problem connecting to server:\n\n" + e.data, "Error Connecting");
					});
					
					connection.start();
				}
			}
		});
	}
}