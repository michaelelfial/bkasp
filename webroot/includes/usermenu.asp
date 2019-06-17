<ul class="leftMenu"><%= TR("Profile") %>
    <li><a <%= UserMenuItemCss("PROFILE") %> href="<%= VirtPath("/userprofile.asp") %>"><%= TR("Details") %></a></li>
    <li><a <%= UserMenuItemCss("NOTIFY") %> href="<%= VirtPath("/usernotify.asp") %>"><%= TR("Notifications") %></a></li>
    <li><a <%= UserMenuItemCss("PASS") %> href="<%= VirtPath("/userchangepass.asp") %>"><%= TR("Change password") %></a></li>
    <li><a <%= UserMenuItemCss("QUOTA") %> href="<%= VirtPath("/userquota.asp") %>"><%= TR("Quota usage") %></a></li>
</ul>
<ul class="leftMenu"><%= TR("Products, services etc.") %>
    <% If CurrentUser.IsServiceAllowed("ITEM") Then %>
    <li><a <%= UserMenuItemCss("SERVICES") %> href="<%= VirtPath("/usersvc.asp") %>"><%= TR("Services") %></a></li>
    <% End If %>
    <% If CurrentUser.IsServiceAllowed("ITEM") Then %>
    <li><a <%= UserMenuItemCss("PRODUCT") %> href="<%= VirtPath("/usersoft.asp") %>"><%= TR("Products (software)") %></a></li>
    <% End If %>
    <% If CurrentUser.IsServiceAllowed("ITEM") Then %>
    <li><a <%= UserMenuItemCss("DEMO") %> href="<%= VirtPath("/userdemo.asp") %>"><%= TR("Demos") %></a></li>
    <% End If %>
</ul>
<ul class="leftMenu"><%= TR("Publications and texts") %>
    <% If IsAdmin Then %>
    <li><a <%= UserMenuItemCss("ABOUT") %> href="<%= VirtPath("/userstatics.asp") %>"><%= TR("About section texts") %></a></li>
    <% End If %>
    <% If CurrentUser.IsServiceAllowed("ARTICLE") Then %>
    <li><a <%= UserMenuItemCss("NEWS") %> href="<%= VirtPath("/usernews.asp") %>"><%= TR("News and announcements") %></a></li>
    <% End If %>
    <% If CurrentUser.IsServiceAllowed("BLOG") Then %>
    <li><a <%= UserMenuItemCss("BLOG") %> href="<%= VirtPath("/userblog.asp") %>"><%= TR("Blog") %></a></li>
    <% End If %>
    <% If CurrentUser.IsServiceAllowed("ARTICLE") Then %>
    <li><a <%= UserMenuItemCss("ARTICLES") %> href="<%= VirtPath("/userarticles.asp") %>"><%= TR("Knowledge base articles") %></a></li>
    <% End If %>    
    <% If CurrentUser.IsServiceAllowed("EVENT") Then %>
    <li><a <%= UserMenuItemCss("EVENT") %> href="<%= VirtPath("/userevents.asp") %>"><%= TR("Events") %></a></li>
    <% End If %>
</ul>
<ul class="leftMenu"><%= TR("Additional tools") %>
    <% If CurrentUser.IsServiceAllowed("IMAGES") Then %>
    <li><a <%= UserMenuItemCss("IMAGEMAN") %> href="<%= VirtPath("/userimages.asp") %>"><%= TR("Manage your photos") %></a></li>
    <% End If %>
    <% If CurrentUser.IsServiceAllowed("FILES") Then %>
    <li><a <%= UserMenuItemCss("FILEMAN") %> href="<%= VirtPath("/userfiles.asp") %>"><%= TR("Manage your files") %></a></li>
    <% End If %>
    <% If IsAdmin Then %>
    <li><a <%= UserMenuItemCss("CONTENTSEL") %> href="<%= VirtPath("/usercontentsel.asp") %>"><%= TR("Special content selection") %></a></li>
    <% End If %>
</ul>