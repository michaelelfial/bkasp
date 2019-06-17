
BkInit.StartMenu(function(menu){
    menu.add(   "Tabbed surrogate",
                "launchone TabbedSurrogateApp"
    ).appclass(
                "TabbedSurrogateApp"
    );
	
	menu.add(   "MouseHunt in surrogate",
                "launchone TabbedSurrogateApp lv 'MouseHunt:main/capture'"
    ).appclass(
                "TabbedSurrogateApp"
    );
});