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
					Popup.hidePopup(createConnectionPopup);
					Popup.hidePopup(connectingPopup);
					
					connectingPopup = Popup.showBusy(view.root, "Logging in as " + nickname + "...");
					connection.login(nickname);
				});
				
				connection.addEventListener(IRCEvent.LOGGED_IN, function(e) {
					Popup.hidePopup(connectingPopup);
					var tabController:IRCTabController = new IRCTabController(connection, nickname);
					//tabController.view.text = server + ":6667";
					tabController.view.id = "ircTab";
					getComponentAs("mainTabs", TabView).addChild(tabController.view);
					getComponentAs("mainTabs", TabView).selectedIndex = getComponentAs("mainTabs", TabView).pageCount - 1;
				});
				
				connection.addEventListener(IRCEvent.ERROR, function (e:IRCEvent) {
					Popup.hidePopup(connectingPopup);
					Popup.showSimple(view.root, "Problem connecting to server:\n" + e.data, "Error Connecting");
				});
				
				connectingPopup = Popup.showBusy(view.root, "Connecting to " + server +"...");
				connection.start();
			}
		});
	}
}