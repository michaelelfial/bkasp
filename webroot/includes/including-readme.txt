How to structure the include directives in your pages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Presently it looks like a waste of time to keep so much explicit 
include directives in the application's ASP pages. It looks possible
to use some include file as a hub that includes everything a page 
needs and leave only secondary features for explicit inclusion.
Despite the looks this has its reasons and this pattern should be
followed in order to keep any application open for future features.

Currently the recommended page structure is as follows:

    Part 1: ASP-CTL control Constants
    Part 2: ASP-CTL core include
    Part 3: ASP-CTL metadata and general attribute initial values
            assignment (such as title, keywords and others)
    Part 4: ASP-CTL WEB controls and periferal feeatures inclusion - 
            a list that can be extended or shrinked to reduce the 
            overal size of ASP code involved when certain features 
            are not needed.
    Part 5: Higher than ASP-CTL level includes and application 
            specific application-wide includes. This is the place
            where libraries built on top of ASP-CTL must be included
            and usually their include files include in turn some
            optional ASP-CTL features employed by them. The libraries
            like UserAPI include configurations, functional and class
            libraries and also reserve places for application specific
            routines. The latter can be included separately of course,
            but like the library they are used by the entire application
            and logically it is more convenient to include everything
            application-wide and be done with it. Still if there is a
            need of some more rarely used application specific routines
            they can be split in a seprate include file and included
            only where needed in this section.
            The section also includes any ASP-CTL backed definitions
            like the Skin. Again the skin may look like something one
            should include in the master page, but such a decision will
            make it harder to assign different skins to different pages
            in scenarios where the master remains the same. The latter
            practice seems to be practical with the design and functional
            patterns used today hence the skin should be declared on page
            and not master level in order to keep the option open.
    Part 6: User controls inclusion. These are both user controls coming
            with the specific library (in this case UserAPI) and specific
            application user control. They can be split into two 
            subsections if this will help track them.
    Part 7: Page functionality - definitions, phase routines, rendering
    Part 8: Inclusion of the master page.
    
In addition we should mention that some user controls and possibly other
optional features can be included in the master providing they are used
only there. This often applies to such elements as login controls, some
WEB site menus, but they should be kept to a minimum and one should prefer
the common.asp for site-wide features if unsure. Inclusion in the master
makes sense only if the feature is used only there and if using more than
one masters in the application seems a strong possibility. In such a case
features needed only by master pages will fall out in those masters where
they are not used - a very little optimization, but still one can take 
advantage of it.

Why is this structure needed?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

First of all the most controversial part is the order of the first 3 or 4
parts. One may be tempted to combine all the constants and definitions
in one place. However, notice that the purposes of those two groups of
constants and definitions are different. The first (Part1) defines
ASP-CTL behaviour and feature turn on/off instructions, while the second 
parrt (Part 3) defines attributes of the page or the application, many of 
which impact the results - e.g. the Title of a page may be changed by
the code of the page (in the next parts), but this is still a data related
to the content not the behavior and the functionality enabled - it uses that
functionality.

For that reason the definitions in Part 1 may determine how the ASP-CTL
framework initializes the current page, while the constants of Part 3
sets up page content attributes. In future developments it is not
impossible to expect that ASP-CTL may take care to help the developer
and provide some automatic level of initialization of such page attributes,
it may also include some new features that can be parametrized after the
framework's initialization - i.e. make their role similar to the page 
content attributes regardless of the fact that they will be not directly
connected to the content. If such definitions are moved to Part 1 this
will require to make tests to see if the page sets something and skip
certain operations - in other words the need of logical decisions will
arise, which we can avoid by simply making sure that we override the
automatically supplied declarations after the moment they are made.

