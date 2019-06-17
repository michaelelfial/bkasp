<%
    ' Package:  UserAPI 
    ' Version:  2011-04-11
    ' File:     configuration.asp
    ' Description:
    '   Defines application configuration settings.
    '   This together with the global.asa are the only two places where configuration settings are kept.
%>
<!-- #include file="../aspctl/sqlite-lib.asp" -->
<!-- #include file="userapi.asp" -->
<!-- #include file="userapi-user.asp" -->
<!-- #include file="userapi-binder.asp" -->
<!-- #include file="userapi-utils.asp" -->
<!-- #include file="userapi-indexer.asp" -->
<!-- #include file="userapi-email.asp" -->
<%
    ' General configuration settings
    ' Some settings of similar purpose are set in the global.asa. A balance should be determined over the changes frequency.
    '
    ' The settings here are mostly constants dependent on the application design
    ' and limitations. They are typically development time settings and may rarely need adjustment after the initial deployment.
    ' Also some feature enable/disable statements are listed here for convenience. If you would prefer to control them from another
    ' place make sure they are removed or commented out in this file.
    
    ' Client scripting configuration and feature enablement
    ' Note that most features are enabled automatically or can be requested only by controls that need them,
    '   some optimization can be achieved that way, but if the features are widely used almost everywhere it is probably
    '   better to enable whatever the application needs from the beginning and avoid problems caused by small omissions here and there
    ' ClientScripts.AsyncPostBackErrorText = TR("An error occured while trying to perform AJAX operation. Do you want to temporarily disable AJAX on this page?")
    ' ClientScripts.EnableStaticEventsLibrary
    ' ClientScripts.EnableAsyncLibrary
    ' ClientScripts.EnablePostBack
    ' ClientScripts.AsyncEventSink = "ccStaticStdProgress"
    
    ' General WEB site constants - used by mailers and other routines. Please take your time to set them
    Const cSiteName = "BindKraft playground on an ASP Classic based server."
    Const cSiteDescription = "BindKraft playground on an ASP Classic based server."
    Const cSiteURL = "http://www.bindkraft.io" ' Enter the primary address if you have many
    ' Const cWebMailURL = "http://mail.cleancodefactory.de"
    Const cUseCustomHeader = True ' Set to False if the pages cannot load
    
    ' Main database
        Const cUserDataBase = "/db/main.db"         ' The database location (this is the root database - where the users are authenticated)
        Const cAutoLoginDays = 30                   ' Days to remember the autoligin cookie
        Const cDatabaseNoTempFiles = True           ' No temp files on disk for transactions and journalling. 
        Const cDirectDelete = True
        ' User levels - should not be changed lightly !!! 
        ' Some database queries assume the values listed here. These constants help the application to be in sync with the SQL not the other way around!
        Const cUserAccessAdmin = 100                ' >= admin_level is treated as admin!
        Const cUserAccessRegular = 0                ' Regular users (the constant is not actually used!!!) 0 is default
        Const cUserAccessGroupAdmin = 1             ' Group administrators - can edit anything owned by their group
        Const cUserAccessOmniGroup = 2              ' Omni-group users. They are regular users but belong to all groups.
        
        ' Const cReindexRecordsPerStep = 10
        
    ' Database session initialization callback - changes should not be needed, but in case the application
        ' needs to make some specific parameters directly accessible in queries they can be appended
        Sub InitDatabaseConnection(db, cdb)
            db.Parameters("USER_ID") = CurrentUser.Id
            db.Parameters("GROUP_ID") = CurrentUser.GroupId
            db.Parameters("LANGUAGE") = PageUILanguage
            db.Parameters("USER_LEVEL") = CurrentUser.Level
            If cDatabaseNoTempFiles Then ' No temp files. Note that this rises the risk of data corruption in case of power failure.
                db.Execute "PRAGMA temp_store=2;"
            End If
        End Sub
        
    ' Email
        cMailMode = "JMail"
        cMailFromName = TR("Site administrator")
        cMailToUsersLimit = 100 ' Limits the mail sent through forms by visitors per IP
        cMailCopyToAdmin = False ' Send copy of any message to the admin
    
    ' Default access rights for new entries (used if there is no configuration for the user/group in the db)
        ' These are fail-safe values to be used whenever the configuration is not complete.    
        ' Default rights for regular users
        Const RU_USER_DEFAULT   = &H1F
        Const RU_GROUP_DEFAULT  = &H3
        Const RU_ALL_DEFAULT    = &H1
        
        ' Default rights for master admins
        Const RA_USER_DEFAULT   = &H1F
        Const RA_GROUP_DEFAULT  = &H3
        Const RA_ALL_DEFAULT    = &H3
        
    ' User rights names
        ' Comment out or remove the levels that are not actually in use
        ' A more flexible implementation may be needed if you want to present different options to different kinds of users
        Dim collStandardRightsNames
        Function GetStandardAccessRightsNames
            Dim o
            If Not IsObject(collStandardRightsNames) Then
                Set o = CreateCollection
                Set collStandardRightsNames = o
                o.Add "0", TR("none")
                o.Add "1", TR("Show when embedded")
                o.Add "3", TR("Read")
                'o.Add "7", TR("put records in the category")
                'o.Add "15", TR("put records and sub-categories")
                o.Add "31", TR("Full control")
            End If
            Set GetStandardAccessRightsNames = collStandardRightsNames
        End Function
        
        
        Const MaxAnonymousIPActions = 2 ' Used only if the setting in the CONFIGURATION is not available

    
    ' Images: reference implementations: uc-imageform.asp, uc-imagelist.asp, uc-imagedlg.asp, uc-imagetype.asp, uc-imageattachments.asp
    '                                    image.asp (image server)
        cImageCache = "/db/imagecache.db" ' Where to cachethumbnails
        ' Image store
        Const ImageStore_Path = "/imagestore"
        Const ImageStore_NumDirs = 100
        Const ImageStore_MaxSize = 5294304
        Const ImageCache_DatabaseFile = "/db/imagecache.db"
        ImageNone_Path = VirtPath("/img/noimage.gif")
        ImageError_Path = VirtPath("/img/noimage.gif")
        ImageErrorIcon_Path = VirtPath("/img/pixel.gif")
    
        ' 6 kinds of small images may be used throughout the application
        Const ThumbnailSize = 100               ' 1 The width is limited, but the height may grow over X pixels depending on the aspect ratio
        Const ThumbNailSizeSmall = 100          ' 2 The width and height are limited to X pixels.
        Const ThumbNailSizeIcon = 40            ' 3 The width is limited, but the height may grow over X pixels depending on the aspect ratio
        Const ThumbNailSizeIconSmall = 40       ' 4 The width and height are limited to X pixels.
        Const PreviewSize = 400                 ' 5 The width is limited, but the height may grow over X pixels depending on the aspect ratio
        Const PreviewSizeSmall = 400            ' 6 The width and height are limited to X pixels.
        
        ' Thmbnail types supported by image.asp (see above). 
        ' Some types are used for particualar purposes by routines in userapi-utils.asp and other places. These constants enable you to set the type
        ' used for a specific purpos
        Const cImageKindIcon    = 4
        Const cImageKindThumb   = 2
        Const cImageKindPreview = 6
    
        
     ' Files 
        Const FileStore_Path = "/filestore"
        Const FileStore_NumDirs = 100
        Const FileStore_MaxSize = 10000000 ' About 10 MB
        
        Const cMaxFileAttachments = 5
        
    

        
%>