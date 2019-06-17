function SysToolsPackageViewer () {
	TrivialView.apply(this, arguments);
	//this.$isFinalAuthority?
}

SysToolsPackageViewer.Inherit(TrivialView, 'SysToolsPackageViewer');
SysToolsPackageViewer.Implement(IAjaxContextParameters);

SysToolsPackageViewer.prototype.get_caption = function () {
    return 'Package executor';
};

SysToolsPackageViewer.prototype.init = function () {
    this.$reload();      // used to get the history data
    this.updateTargets();
};

SysToolsPackageViewer.ImplementProperty('packageUrl', new InitializeStringParameter('Package url for execution.', null));

SysToolsPackageViewer.prototype.$result = null;

SysToolsPackageViewer.prototype.get_result = function () {
	return this.$result;
};

SysToolsPackageViewer.prototype.$localStorageKey = 'HistoryOfExecutedPackages';

// Get History From Local Storage
SysToolsPackageViewer.prototype.$reload = function () {
    var l = localStorage.getItem(this.$localStorageKey);
	
    if (l != null) {
        this.history = l.split(",");
        if (this.history.length == 1) {
            if (this.history[0] == "") {
                this.history.removeElement(0);
            }
        }
    } else {
        this.history = null;
    }
};

 // Save History To Local Storage
SysToolsPackageViewer.prototype.SerializeHistory = function () {
    if (IsNull(this.history)) return;
	
	var urls = this.history;
	var urlsForHistory = urls.join(',');
	
	localStorage.setItem(this.$localStorageKey, urlsForHistory);
};

// Clear Whole history
SysToolsPackageViewer.prototype.OnClearHistoryClick = function() {
    localStorage.removeItem(this.$localStorageKey);
	
    this.$reload();
    this.updateTargets();
};

// Add New Element
SysToolsPackageViewer.prototype.CardHistory = function (url) {
	if (url == "") return;
	
	if (!IsNull(this.history)) {
		if (this.history.findElement(url) == -1) {
			this.history.unshift(url);			
		} else {
			this.history.removeElement(url);
			this.history.unshift(url);
		}
	} else {
		this.history = new Array();
		this.history.unshift(url);
	}
	
	this.SerializeHistory();
};

// Move Opended Element From History To Top
SysToolsPackageViewer.prototype.HistoryOpen = function (e, url, el) {
	if (!IsNull(this.history)) {
		this.history.removeElement(url);
		this.history.unshift(url);
		this.SerializeHistory();
		
		this.ajaxPostXml(mapPath(url), null, function (result) {
			if (result.status.issuccessful) {
				this.$result = result.data;

				this.CardHistory(url);
			} else {
				this.$result = null;
				
				CInfoMessage.emit(this, result.status.message, null, InfoMessageTypeEnum.error);
			}	

			this.updateTargets();
		});		
	}    
};

SysToolsPackageViewer.prototype.DeleteCurrent = function (e, dc, binding) {
	this.history.removeElement(dc);
	this.SerializeHistory();
	
	this.updateTargets();
};

SysToolsPackageViewer.prototype.onExecutePackage = function (e, dc, binding) {	
	this.updateSources();
	
    if (this.get_packageUrl() == null || this.get_packageUrl().length <= 0) return;		
	
	this.ajaxPostXml(mapPath(this.get_packageUrl()), null, function (result) {
		if (result.status.issuccessful) {
			this.$result = result.data;

			this.CardHistory(this.get_packageUrl());
		} else {
			this.$result = null;
			
			InfoMessage.emit(this, result.status.message, null, InfoMessageTypeEnum.error);
		}	

		this.updateTargets();
	});
};