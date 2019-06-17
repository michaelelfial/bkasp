<%
' Databainder for tables that follow these rules:
' The table has fields: 
' [SID] INTEGER NOT NULL, -- obtained from the SYS table
' [CREATED] DATETIME,   -- OleSysTime when first created
' [MODIFIED] DATETIME,  -- OleSysTime when changed
' [MODIFY_USER_ID] INTEGER, -- The last user who changed the record
' [OWNER_USER_ID] INTEGER,  
' [OWNER_GROUP_ID] INTEGER,
' [R_USER] BOOLEAN DEFAULT -1,
' [R_GROUP] BOOLEAN DEFAULT 0,
' [R_ALL] BOOLEAN DEFAULT 0,
' [DELETED] BOOLEAN DEFAULT 0,
' [CHANGED] BOOLEAN DEFAULT -1,
' [LANGUAGE] TEXT NOT NULL
'
' The binder works with sets of physical records corresponding to a single logical record
' A logical record consists of one physical record for each language for tables supporting languages
'   and of one physical record for tables not supporting languages. This means that the logical record
'   is always a collection of physical records 1 in case of no language and multiple otherwise.
'
' REQUIREMENTS FOR CONTROLS
'   The controls must accept/return their value through a Value property
'   If they have multiple values they must implement Values(key) indexed property


%>