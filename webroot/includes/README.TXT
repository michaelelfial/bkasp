USERAPI Library for ASP-CTL
===========================

This library provides variety of features typically needed in small and 
middle range WEB sites and WEB based business applications.

USERAPI depends on certain database structure, requires several tables 
related to the user management and some more for other basic functions.
Aside of the library files USERAPI includes several user controls - 
mostly related to user management and system maintenance. The controls
can be changed to match the design and/or UI philosophy of the particular
project.

USERAPI is designed for multilanguage applications, but can be used for
single language ones as well. If the particular project is guaranteed to
never need more than one language supported some required fields can be
excluded from the DB schema. However, it is probably better to leave them
in the database for potential future development, the space consumed by
them is negligible.

1. Requirements
~~~~~~~~~~~~~~~

    - ASP-CTL v. 1.A or greater
    
    Required includes on global level:
    - sqlite-lib.asp
    
2. Placement
~~~~~~~~~~~~

The USERAPI files are typically palced in the application's includes
directory, but can be moved elsewhere. All the #include directives are
attuned for placement in a subdirectory direct descendant of the root
directory of the WEB application.    

3. Configuration
~~~~~~~~~~~~~~~~

The file configuration.asp is intended as configuration center for the
application. It contains settings for USERAPI and assortment of sample 
settings related to tables and features not part of USERAPI for which
reference implementions are available.

4. Impact over the application code - some globals that you may be tempted
    to duplicate in a mistake
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Please read !!!

    a) USERAPI creates a few global utility objects for internal and 
        application wide use:
        StringUtilities - an instance of newObjects.utilclts.StringUtilities
        SFMain - an instance of newObjects.utilclts.SFMain
    b) USERAPI initializes the main database as a CDatabase instance as a
        global variable named:
        Database - instance of CDatabase (defined in aspctl/sqlite-lib.asp)
    c) CurrentUser - instance of the CUser (impl. userapi.user) representing
        the current user.
        USERAPI also exposes a few global functions which has equivalent
        member in CUser. It is strongly recommended to use them from the
        application code instead of calling methods on the CurrentUser
        instance of CUser. These global functions may perform additional
        tasks intended to bring more consistency and relieve you from the
        need to make additional checks and adjustments. They are:
            LogOn(login, password, email, save)
            UpdateCurrentUser
            LogOff
            AutoLogOn
            RemoveAutoLogOn
            IsLoggedOn
            IsAdmin
        USERAPI performs auto logon always, so typically the application
        does not need to do anything about that. The related functions 
        are needed only in implementations of login functions/user 
        profile management.
    