/*CLASS*/
function SysToolsInterfaceInfo(prot, bFullDetails) {
    var c, protName;
    this.kind = "interface";
    if (typeof prot == "string") {
        protName = prot;
    } else if (prot != null && prot.classType != null) {
        protName = prot.classType;
    } else {
        this.name = "{undefined interface}";
        this.valid = false;
        this.kind = "not defined";
        return;
    }
    if (Function.interfaces[protName] != null) {
        c = Function.interfaces[protName];
        this.name = c.classType;
        this.valid = true;
        this.kind = "interface";
        this.implementors = Class.implementors(protName);
    } else {
        this.implementors = Class.implementors(protName);
        if (this.implementors.length > 0) {
            this.name = protName;
            this.kind = "marker interface";
            this.valid = true;
        } else {
            this.name = "{undefined interface}";
            this.kind = "not defined";
            this.valid = false;
        }
    }

    if (c != null && bFullDetails) {
        var m, priv, n, p, curly;
        this.fields = [];
        this.properties = [];
        this.methods = [];
        for (var i in c.prototype) {
            priv = false;
            n = i;
            if (i.charAt(0) == "$") {
                priv = true;
                n = i.slice(1);
            }
            if (BaseObject.is(c.prototype[i], "function")) {
                m = i.match(/^(set_|get_)/i);
                if (m != null) {
                    this.properties.push({
                        name: n,
                        kind: m[1],
                        priv: priv,
                        desc: (c.prototype[i].$description != null) ? c.prototype[i].$description : ""
                    });
                } else {
                    p = c.prototype[i].toString();
                    curly = p.indexOf("{");
                    p = p.slice(0, curly);
                    this.methods.push({
                        name: n,
                        proto: p,
                        priv: priv,
                        desc: (c.prototype[i].$description != null) ? c.prototype[i].$description : "",
						args: (c.prototype[i].$paramDescriptions != null)?c[i].$paramDescriptions:null
                    });
                }
            } else {
                this.fields.push({
                    name: n,
                    priv: priv,
                    defval: c.prototype[i]
                });
            }
        }
    }
}
SysToolsInterfaceInfo.Inherit(BaseObject, "SysToolsInterfaceInfo");
SysToolsInterfaceInfo.prototype.name = null;
SysToolsInterfaceInfo.prototype.kind = null;
SysToolsInterfaceInfo.prototype.valid = false;
SysToolsInterfaceInfo.prototype.methods = null;
SysToolsInterfaceInfo.prototype.properties = null;
SysToolsInterfaceInfo.prototype.fields = null;