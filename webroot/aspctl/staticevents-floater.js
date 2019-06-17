function ccStaticShowFloater(e,fid,opts) {
    var x,y,fw,fh,floater;
    floater = EL(fid);
    x = (opts.posx == null)?e.pageX:opts.posx;
    y = (opts.posy == null)?e.pageY:opts.posY;
    fw = (opts.fwidth == null)?floater.scrollWidth:opts.fwidth;
    fh = (opts.fheight == null)?floater.scrollHeight:opts.fheight;
    
    var w = (document.body.scrollWidth > 0)?document.body.scrollWidth:((document.documentElement.scrollWidth > 0)?document.documentElement.scrollWidth:0);
    var h = (document.body.scrollHeight > 0)?document.body.scrollHeight:((document.documentElement.scrollHeight > 0)?document.documentElement.scrollHeight:0);
    var l = (document.body.scrollLeft)?document.body.scrollLeft:((document.documentElement.scrollLeft)?document.documentElement.scrollLeft:window.pageXOffset);
    var t = (document.body.scrollTop)?document.body.scrollTop:((document.documentElement.scrollTop)?document.documentElement.scrollTop:window.pageYOffset);
    t = (t)?t:0;
    l = (l)?l:0;
    
    x += (opts.dx != null)?opts.dx:0;
    y += (opts.dy != null)?opts.dy:0;
    
    if (!opts.noCorrect) {
        if (w >= 0 && h >= 0) {
            //alert(w + "\t" + h + "\n" + x + "\t" + y);
            w = w + l;
            h = h + t;
            
            if (w - x < fw) {
                x = w - fw;
            }
            if (h - y < fh) {
                y = h - fh;
            }
        }
    }
    floater.style.left = x + "px";
    floater.style.top = y + "px";
    floater.style.display = "block";
}
function ccStaticHideFloater(e,fid) {
    var floater = EL(fid);
    floater.style.display = "none";
}