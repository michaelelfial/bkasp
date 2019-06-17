<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<title>SQLite3 SQL references</title>
<link rel=stylesheet href="/styles.css" type="text/css">
<SCRIPT>
    function onInitPage() {
        top.frames["DBManT"].document.frames["DBManT2"].location = "/toolbar2-help.asp?Topic=<%= Request.ServerVariables("SCRIPT_NAME") %>";
    }
    function onUninitPage() {
        top.frames["DBManT"].document.frames["DBManT2"].location = "/toolbar2.asp";
    }
</SCRIPT>
</head>

<body topmargin="0" leftmargin="0" onLoad="onInitPage()" onUnload="onUninitPage()">

<p>Note: this is the standrad SQLite SQL documentation from the official <a href="http://www.sqlite.org">sqlite</a>
site. The SQL syntax described here is supported in SQLite3COM 3.3.5.0 and later</p>
<h1>SQL As Understood By SQLite</h1>
<p>The SQLite library understands most of the standard SQL language. But it does
<a href="http://www.sqlite.org/omitted.html">omit some features</a> while at the
same time adding a few features of its own. This document attempts to describe
precisely what parts of the SQL language SQLite does and does not support. A
list of <a href="http://www.sqlite.org/lang_keywords.html">keywords</a> is also
provided.</p>
<p>In all of the syntax diagrams that follow, literal text is shown in bold
blue. Non-terminal symbols are shown in italic red. Operators that are part of
the syntactic markup itself are shown in black roman.</p>
<p>This document is just an overview of the SQL syntax implemented by SQLite.
Many low-level productions are omitted. For detailed information on the language
that SQLite understands, refer to the source code and the grammar file
&quot;parse.y&quot;.</p>
<p>SQLite implements the follow syntax:</p>
<ul>
  <li><a href="#ALTER TABLE">ALTER TABLE</a>
  <li><a href="#ANALYZE">ANALYZE</a>
  <li><a href="#ATTACH DATABASE">ATTACH DATABASE</a>
  <li><a href="#TRANSACTION">BEGIN TRANSACTION</a>
  <li><a href="#comment">comment</a>
  <li><a href="#TRANSACTION">COMMIT TRANSACTION</a>
  <li><a href="#CREATE INDEX">CREATE INDEX</a>
  <li><a href="#CREATE TABLE">CREATE TABLE</a>
  <li><a href="#CREATE TRIGGER">CREATE TRIGGER</a>
  <li><a href="#CREATE VIEW">CREATE VIEW</a>
  <li><a href="#DELETE">DELETE</a>
  <li><a href="#DETACH DATABASE">DETACH DATABASE</a>
  <li><a href="#DROP INDEX">DROP INDEX</a>
  <li><a href="#DROP TABLE">DROP TABLE</a>
  <li><a href="#DROP TRIGGER">DROP TRIGGER</a>
  <li><a href="#DROP VIEW">DROP VIEW</a>
  <li><a href="#TRANSACTION">END TRANSACTION</a>
  <li><a href="#EXPLAIN">EXPLAIN</a>
  <li><a href="#expression">expression</a>
  <li><a href="#INSERT">INSERT</a>
  <li><a href="#ON CONFLICT clause">ON CONFLICT clause</a>
  <li><a href="#PRAGMA">PRAGMA</a>
  <li><a href="#REINDEX">REINDEX</a>
  <li><a href="#REPLACE">REPLACE</a>
  <li><a href="#TRANSACTION">ROLLBACK TRANSACTION</a>
  <li><a href="#SELECT">SELECT</a>
  <li><a href="#UPDATE">UPDATE</a>
  <li><a href="#VACUUM">VACUUM</a></li>
  <li><a href="#Datatypes">Datatypes In SQLite Version 3</a></li>
</ul>
<h2><a name="ALTER TABLE">ALTER TABLE</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">ALTER TABLE </font></b>[<i><font color="#ff3434">database-name</font></i><b><font color="#2c2cf0">
        <big>.</big></font></b>]<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">table-name</font></i><b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">alteration</font></i></td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">alteration</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">RENAME TO </font></b><i><font color="#ff3434">new-table-name</font></i></td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">alteration</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">ADD </font></b>[<b><font color="#2c2cf0">COLUMN</font></b>]<b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">column-def</font></i></td>
    </tr>
  </tbody>
</table>
<p>SQLite's version of the ALTER TABLE command allows the user to rename or add
a new column to an existing table. It is not possible to remove a column from a
table.</p>
<p>The RENAME TO syntax is used to rename the table identified by <i>[database-name.]table-name</i>
to <i>new-table-name</i>. This command cannot be used to move a table between
attached databases, only to rename a table within the same database.</p>
<p>If the table being renamed has triggers or indices, then these remain
attached to the table after it has been renamed. However, if there are any view
definitions, or statements executed by triggers that refer to the table being
renamed, these are not automatically modified to use the new table name. If this
is required, the triggers or view definitions must be dropped and recreated to
use the new table name by hand.</p>
<p>The ADD [COLUMN] syntax is used to add a new column to an existing table. The
new column is always appended to the end of the list of existing columns. <i>Column-def</i>
may take any of the forms permissable in a CREATE TABLE statement, with the
following restrictions:
<ul>
  <li>The column may not have a PRIMARY KEY or UNIQUE constraint.
  <li>The column may not have a default value of CURRENT_TIME, CURRENT_DATE or
    CURRENT_TIMESTAMP.
  <li>If a NOT NULL constraint is specified, then the column must have a default
    value other than NULL.</li>
</ul>
<p>The execution time of the ALTER TABLE command is independent of the amount of
data in the table. The ALTER TABLE command runs as quickly on a table with 10
million rows as it does on a table with 1 row.</p>
<p>After ADD COLUMN has been run on a database, that database will not be
readable by SQLite version 3.1.3 and earlier until the database is <a href="#VACUUM">VACUUM</a>ed.</p>
<h2><a name="ANALYZE">ANALYZE</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">ANALYZE</font></b></td>
    </tr>
  </tbody>
</table>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">ANALYZE </font></b><i><font color="#ff3434">database-name</font></i></td>
    </tr>
  </tbody>
</table>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">ANALYZE </font></b>[<i><font color="#ff3434">database-name</font></i><b><font color="#2c2cf0">
        <big>.</big></font></b>]<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">table-name</font></i></td>
    </tr>
  </tbody>
</table>
<p>The ANALYZE command gathers statistics about indices and stores them in a
special tables in the database where the query optimizer can use them to help
make better index choices. If no arguments are given, all indices in all
attached databases are analyzed. If a database name is given as the argument,
all indices in that one database are analyzed. If the argument is a table name,
then only indices associated with that one table are analyzed.</p>
<p>The initial implementation stores all statistics in a single table named <b>sqlite_stat1</b>.
Future enhancements may create additional tables with the same name pattern
except with the &quot;1&quot; changed to a different digit. The <b>sqlite_stat1</b>
table cannot be DROPped, but all the content can be DELETEd which has the same
effect.</p>
<h2><a name="ATTACH DATABASE">ATTACH DATABASE</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">ATTACH </font></b>[<b><font color="#2c2cf0">DATABASE</font></b>]<b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">database-filename</font></i><b><font color="#2c2cf0">
        AS </font></b><i><font color="#ff3434">database-name</font></i></td>
    </tr>
  </tbody>
</table>
<p>The ATTACH DATABASE statement adds a preexisting database file to the current
database connection. If the filename contains punctuation characters it must be
quoted. The names 'main' and 'temp' refer to the main database and the database
used for temporary tables. These cannot be detached. Attached databases are
removed using the DETACH DATABASE statement.</p>
<p>You can read from and write to an attached database and you can modify the
schema of the attached database. This is a new feature of SQLite version 3.0. In
SQLite 2.8, schema changes to attached databases were not allowed.</p>
<p>You cannot create a new table with the same name as a table in an attached
database, but you can attach a database which contains tables whose names are
duplicates of tables in the main database. It is also permissible to attach the
same database file multiple times.</p>
<p>Tables in an attached database can be referred to using the syntax <i>database-name.table-name</i>.
If an attached table doesn't have a duplicate table name in the main database,
it doesn't require a database name prefix. When a database is attached, all of
its tables which don't have duplicate names become the 'default' table of that
name. Any tables of that name attached afterwards require the table prefix. If
the 'default' table of a given name is detached, then the last table of that
name attached becomes the new default.</p>
<p>Transactions involving multiple attached databases are atomic, assuming that
the main database is not &quot;:memory:&quot;. If the main database is
&quot;:memory:&quot; then transactions continue to be atomic within each
individual database file. But if the host computer crashes in the middle of a
COMMIT where two or more database files are updated, some of those files might
get the changes where others might not. Atomic commit of attached databases is a
new feature of SQLite version 3.0. In SQLite version 2.8, all commits to
attached databases behaved as if the main database were &quot;:memory:&quot;.</p>
<p>There is a compile-time limit of 10 attached database files.</p>
<h2>BEGIN <a name="TRANSACTION">TRANSACTION</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">BEGIN </font></b>[<b><font color="#2c2cf0">
        DEFERRED </font></b><big>|</big><b><font color="#2c2cf0"> IMMEDIATE </font></b><big>|</big><b><font color="#2c2cf0">
        EXCLUSIVE </font></b>]<b><font color="#2c2cf0"> </font></b>[<b><font color="#2c2cf0">TRANSACTION
        </font></b>[<i><font color="#ff3434">name</font></i>]]</td>
    </tr>
  </tbody>
</table>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">END </font></b>[<b><font color="#2c2cf0">TRANSACTION
        </font></b>[<i><font color="#ff3434">name</font></i>]]</td>
    </tr>
  </tbody>
</table>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">COMMIT </font></b>[<b><font color="#2c2cf0">TRANSACTION
        </font></b>[<i><font color="#ff3434">name</font></i>]]</td>
    </tr>
  </tbody>
</table>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">ROLLBACK </font></b>[<b><font color="#2c2cf0">TRANSACTION
        </font></b>[<i><font color="#ff3434">name</font></i>]]</td>
    </tr>
  </tbody>
</table>
<p>Beginning in version 2.0, SQLite supports transactions with rollback and
atomic commit.</p>
<p>The optional transaction name is ignored. SQLite currently does not allow
nested transactions.</p>
<p>No changes can be made to the database except within a transaction. Any
command that changes the database (basically, any SQL command other than SELECT)
will automatically start a transaction if one is not already in effect.
Automatically started transactions are committed at the conclusion of the
command.</p>
<p>Transactions can be started manually using the BEGIN command. Such
transactions usually persist until the next COMMIT or ROLLBACK command. But a
transaction will also ROLLBACK if the database is closed or if an error occurs
and the ROLLBACK conflict resolution algorithm is specified. See the
documentation on the ON CONFLICT clause for additional information about the
ROLLBACK conflict resolution algorithm.</p>
<p>In SQLite version 3.0.8 and later, transactions can be deferred, immediate,
or exclusive. Deferred means that no locks are acquired on the database until
the database is first accessed. Thus with a deferred transaction, the BEGIN
statement itself does nothing. Locks are not acquired until the first read or
write operation. The first read operation against a database creates a SHARED
lock and the first write operation creates a RESERVED lock. Because the
acquisition of locks is deferred until they are needed, it is possible that
another thread or process could create a separate transaction and write to the
database after the BEGIN on the current thread has executed. If the transaction
is immediate, then RESERVED locks are acquired on all databases as soon as the
BEGIN command is executed, without waiting for the database to be used. After a
BEGIN IMMEDIATE, you are guaranteed that no other thread or process will be able
to write to the database or do a BEGIN IMMEDIATE or BEGIN EXCLUSIVE. Other
processes can continue to read from the database, however. An exclusive
transaction causes EXCLUSIVE locks to be acquired on all databases. After a
BEGIN EXCLUSIVE, you are guaranteed that no other thread or process will be able
to read or write the database until the transaction is complete.</p>
<p>A description of the meaning of SHARED, RESERVED, and EXCLUSIVE locks is
available separately.</p>
<p>The default behavior for SQLite version 3.0.8 is a deferred transaction. For
SQLite version 3.0.0 through 3.0.7, deferred is the only kind of transaction
available. For SQLite version 2.8 and earlier, all transactions are exclusive.</p>
<p>The COMMIT command does not actually perform a commit until all pending SQL
commands finish. Thus if two or more SELECT statements are in the middle of
processing and a COMMIT is executed, the commit will not actually occur until
all SELECT statements finish.</p>
<p>An attempt to execute COMMIT might result in an SQLITE_BUSY return code. This
indicates that another thread or process had a read lock on the database that
prevented the database from being updated. When COMMIT fails in this way, the
transaction remains active and the COMMIT can be retried later after the reader
has had a chance to clear.</p>
<h2><a name="comment">comment</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">comment</font></i>&nbsp;::=</td>
      <td><i><font color="#ff3434">SQL-comment</font></i><b><font color="#2c2cf0">
        </font></b><big>|</big><b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">C-comment</font></i></td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">SQL-comment</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">-- </font></b><i><font color="#ff3434">single-line</font></i></td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">C-comment</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">/<big>*</big> </font></b><i><font color="#ff3434">multiple-lines</font></i><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0"><big>*</big>/</font></b>]</td>
    </tr>
  </tbody>
</table>
<p>Comments aren't SQL commands, but can occur in SQL queries. They are treated
as whitespace by the parser. They can begin anywhere whitespace can be found,
including inside expressions that span multiple lines.</p>
<p>SQL comments only extend to the end of the current line.</p>
<p>C comments can span any number of lines. If there is no terminating
delimiter, they extend to the end of the input. This is not treated as an error.
A new SQL statement can begin on a line after a multiline comment ends. C
comments can be embedded anywhere whitespace can occur, including inside
expressions, and in the middle of other SQL statements. C comments do not nest.
SQL comments inside a C comment will be ignored.</p>
<h2><a name="CREATE INDEX">CREATE INDEX</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">CREATE </font></b>[<b><font color="#2c2cf0">UNIQUE</font></b>]<b><font color="#2c2cf0">
        INDEX </font></b>[<b><font color="#2c2cf0">IF NOT EXISTS</font></b>]<b><font color="#2c2cf0">
        </font></b>[<i><font color="#ff3434">database-name</font></i><b><font color="#2c2cf0">
        <big>.</big></font></b>]<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">index-name</font></i><b><font color="#2c2cf0"><br>
        ON </font></b><i><font color="#ff3434">table-name</font></i><b><font color="#2c2cf0">
        <big>(</big> </font></b><i><font color="#ff3434">column-name</font></i><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0"><big>,</big> </font></b><i><font color="#ff3434">column-name</font></i>]<big>*</big><b><font color="#2c2cf0">
        <big>)</big></font></b></td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">column-name</font></i>&nbsp;::=</td>
      <td><i><font color="#ff3434">name</font></i><b><font color="#2c2cf0"> </font></b>[<b><font color="#2c2cf0">
        COLLATE </font></b><i><font color="#ff3434">collation-name</font></i>]<b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0"> ASC </font></b><big>|</big><b><font color="#2c2cf0">
        DESC </font></b>]</td>
    </tr>
  </tbody>
</table>
<p>The CREATE INDEX command consists of the keywords &quot;CREATE INDEX&quot;
followed by the name of the new index, the keyword &quot;ON&quot;, the name of a
previously created table that is to be indexed, and a parenthesized list of
names of columns in the table that are used for the index key. Each column name
can be followed by one of the &quot;ASC&quot; or &quot;DESC&quot; keywords to
indicate sort order, but the sort order is ignored in the current
implementation. Sorting is always done in ascending order.</p>
<p>The COLLATE clause following each column name defines a collating sequence
used for text entires in that column. The default collating sequence is the
collating sequence defined for that column in the CREATE TABLE statement. Or if
no collating sequence is otherwise defined, the built-in BINARY collating
sequence is used.</p>
<p>There are no arbitrary limits on the number of indices that can be attached
to a single table, nor on the number of columns in an index.</p>
<p>If the UNIQUE keyword appears between CREATE and INDEX then duplicate index
entries are not allowed. Any attempt to insert a duplicate entry will result in
an error.</p>
<p>The exact text of each CREATE INDEX statement is stored in the <b>sqlite_master</b>
or <b>sqlite_temp_master</b> table, depending on whether the table being indexed
is temporary. Every time the database is opened, all CREATE INDEX statements are
read from the <b>sqlite_master</b> table and used to regenerate SQLite's
internal representation of the index layout.</p>
<p>If the optional IF NOT EXISTS clause is present and another index with the
same name aleady exists, then this command becomes a no-op.</p>
<p>Indexes are removed with the DROP INDEX command.</p>
<h2><a name="CREATE TABLE">CREATE TABLE</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-command</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">CREATE </font></b>[<b><font color="#2c2cf0">TEMP
        </font></b><big>|</big><b><font color="#2c2cf0"> TEMPORARY</font></b>]<b><font color="#2c2cf0">
        TABLE </font></b>[<b><font color="#2c2cf0">IF NOT EXISTS</font></b>]<b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">table-name</font></i><b><font color="#2c2cf0">
        <big>(</big><br>
        &nbsp;&nbsp;&nbsp;&nbsp;</font></b><i><font color="#ff3434">column-def</font></i><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0"><big>,</big> </font></b><i><font color="#ff3434">column-def</font></i>]<big>*</big><b><font color="#2c2cf0"><br>
        &nbsp;&nbsp;&nbsp;&nbsp;</font></b>[<b><font color="#2c2cf0"><big>,</big>
        </font></b><i><font color="#ff3434">constraint</font></i>]<big>*</big><b><font color="#2c2cf0"><br>
        <big>)</big></font></b></td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-command</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">CREATE </font></b>[<b><font color="#2c2cf0">TEMP
        </font></b><big>|</big><b><font color="#2c2cf0"> TEMPORARY</font></b>]<b><font color="#2c2cf0">
        TABLE </font></b>[<i><font color="#ff3434">database-name</font></i><b><font color="#2c2cf0"><big>.</big></font></b>]<b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">table-name</font></i><b><font color="#2c2cf0">
        AS </font></b><i><font color="#ff3434">select-statement</font></i></td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">column-def</font></i>&nbsp;::=</td>
      <td><i><font color="#ff3434">name</font></i><b><font color="#2c2cf0"> </font></b>[<i><font color="#ff3434">type</font></i>]<b><font color="#2c2cf0">
        </font></b>[[<b><font color="#2c2cf0">CONSTRAINT </font></b><i><font color="#ff3434">name</font></i>]<b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">column-constraint</font></i>]<big>*</big></td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">type</font></i>&nbsp;::=</td>
      <td><i><font color="#ff3434">typename</font></i><b><font color="#2c2cf0"> </font></b><big>|</big><b><font color="#2c2cf0"><br>
        </font></b><i><font color="#ff3434">typename</font></i><b><font color="#2c2cf0">
        <big>(</big> </font></b><i><font color="#ff3434">number</font></i><b><font color="#2c2cf0">
        <big>)</big> </font></b><big>|</big><b><font color="#2c2cf0"><br>
        </font></b><i><font color="#ff3434">typename</font></i><b><font color="#2c2cf0">
        <big>(</big> </font></b><i><font color="#ff3434">number</font></i><b><font color="#2c2cf0">
        <big>,</big> </font></b><i><font color="#ff3434">number</font></i><b><font color="#2c2cf0">
        <big>)</big></font></b></td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">column-constraint</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">NOT NULL </font></b>[<b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">conflict-clause</font></i><b><font color="#2c2cf0">
        </font></b>]<b><font color="#2c2cf0"> </font></b><big>|</big><b><font color="#2c2cf0"><br>
        PRIMARY KEY </font></b>[<i><font color="#ff3434">sort-order</font></i>]<b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">conflict-clause</font></i><b><font color="#2c2cf0">
        </font></b>]<b><font color="#2c2cf0"> </font></b>[<b><font color="#2c2cf0">AUTOINCREMENT</font></b>]<b><font color="#2c2cf0">
        </font></b><big>|</big><b><font color="#2c2cf0"><br>
        UNIQUE </font></b>[<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">conflict-clause</font></i><b><font color="#2c2cf0">
        </font></b>]<b><font color="#2c2cf0"> </font></b><big>|</big><b><font color="#2c2cf0"><br>
        CHECK <big>(</big> </font></b><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0">
        <big>)</big> </font></b><big>|</big><b><font color="#2c2cf0"><br>
        DEFAULT </font></b><i><font color="#ff3434">value</font></i><b><font color="#2c2cf0">
        </font></b><big>|</big><b><font color="#2c2cf0"><br>
        COLLATE </font></b><i><font color="#ff3434">collation-name</font></i></td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">constraint</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">PRIMARY KEY <big>(</big> </font></b><i><font color="#ff3434">column-list</font></i><b><font color="#2c2cf0">
        <big>)</big> </font></b>[<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">conflict-clause</font></i><b><font color="#2c2cf0">
        </font></b>]<b><font color="#2c2cf0"> </font></b><big>|</big><b><font color="#2c2cf0"><br>
        UNIQUE <big>(</big> </font></b><i><font color="#ff3434">column-list</font></i><b><font color="#2c2cf0">
        <big>)</big> </font></b>[<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">conflict-clause</font></i><b><font color="#2c2cf0">
        </font></b>]<b><font color="#2c2cf0"> </font></b><big>|</big><b><font color="#2c2cf0"><br>
        CHECK <big>(</big> </font></b><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0">
        <big>)</big></font></b></td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">conflict-clause</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">ON CONFLICT </font></b><i><font color="#ff3434">conflict-algorithm</font></i></td>
    </tr>
  </tbody>
</table>
<p>A CREATE TABLE statement is basically the keywords &quot;CREATE TABLE&quot;
followed by the name of a new table and a parenthesized list of column
definitions and constraints. The table name can be either an identifier or a
string. Tables names that begin with &quot;<b>sqlite_</b>&quot; are reserved for
use by the engine.</p>
<p>Each column definition is the name of the column followed by the datatype for
that column, then one or more optional column constraints. The datatype for the
column does not restrict what data may be put in that column. See <a href="#Datatypes">Datatypes
In SQLite Version 3</a> for additional information. The UNIQUE constraint causes
an index to be created on the specified columns. This index must contain unique
keys. The COLLATE clause specifies what text collating
function to use when comparing text entries for the column. The built-in
BINARY collating function is used by default.
<p>The DEFAULT constraint specifies a default value to use when doing an INSERT.
The value may be NULL, a string constant or a number. Starting with version
3.1.0, the default value may also be one of the special case-independant
keywords CURRENT_TIME, CURRENT_DATE or CURRENT_TIMESTAMP. If the value is NULL,
a string constant or number, it is literally inserted into the column whenever
an INSERT statement that does not specify a value for the column is executed. If
the value is CURRENT_TIME, CURRENT_DATE or CURRENT_TIMESTAMP, then the current
UTC date and/or time is inserted into the columns. For CURRENT_TIME, the format
is HH:MM:SS. For CURRENT_DATE, YYYY-MM-DD. The format for CURRENT_TIMESTAMP is
&quot;YYYY-MM-DD HH:MM:SS&quot;.</p>
<p>Specifying a PRIMARY KEY normally just creates a UNIQUE index on the
corresponding columns. However, if primary key is on a single column that has
datatype INTEGER, then that column is used internally as the actual key of the
B-Tree for the table. This means that the column may only hold unique integer
values. (Except for this one case, SQLite ignores the datatype specification of
columns and allows any kind of data to be put in a column regardless of its
declared datatype.) If a table does not have an INTEGER PRIMARY KEY column, then
the B-Tree key will be a automatically generated integer. The B-Tree key for a
row can always be accessed using one of the special names &quot;<b>ROWID</b>&quot;,
&quot;<b>OID</b>&quot;, or &quot;<b>_ROWID_</b>&quot;. This is true regardless
of whether or not there is an INTEGER PRIMARY KEY. An INTEGER PRIMARY KEY column
man also include the keyword AUTOINCREMENT. The AUTOINCREMENT keyword modified
the way that B-Tree keys are automatically generated. Additional detail on
automatic B-Tree key generation is available separately.</p>
<p>If the &quot;TEMP&quot; or &quot;TEMPORARY&quot; keyword occurs in between
&quot;CREATE&quot; and &quot;TABLE&quot; then the table that is created is only
visible within that same database connection and is automatically deleted when
the database connection is closed. Any indices created on a temporary table are
also temporary. Temporary tables and indices are stored in a separate file
distinct from the main database file.</p>
<p>If a &lt;database-name&gt; is specified, then the table is created in the
named database. It is an error to specify both a &lt;database-name&gt; and the
TEMP keyword, unless the &lt;database-name&gt; is &quot;temp&quot;. If no
database name is specified, and the TEMP keyword is not present, the table is
created in the main database.</p>
<p>The optional conflict-clause following each constraint allows the
specification of an alternative default constraint conflict resolution algorithm
for that constraint. The default is abort ABORT. Different constraints within
the same table may have different default conflict resolution algorithms. If an
COPY, INSERT, or UPDATE command specifies a different conflict resolution
algorithm, then that algorithm is used in place of the default algorithm
specified in the CREATE TABLE statement. See the section titled ON
CONFLICT for additional information.</p>
<p>CHECK constraints are supported as of version 3.3.0. Prior to version 3.3.0,
CHECK constraints were parsed but not enforced.</p>
<p>There are no arbitrary limits on the number of columns or on the number of
constraints in a table. The total amount of data in a single row is limited to
about 1 megabytes in version 2.8. In version 3.0 there is no arbitrary limit on
the amount of data in a row.</p>
<p>The CREATE TABLE AS form defines the table to be the result set of a query.
The names of the table columns are the names of the columns in the result.</p>
<p>The exact text of each CREATE TABLE statement is stored in the <b>sqlite_master</b>
table. Every time the database is opened, all CREATE TABLE statements are read
from the <b>sqlite_master</b> table and used to regenerate SQLite's internal
representation of the table layout. If the original command was a CREATE TABLE
AS then then an equivalent CREATE TABLE statement is synthesized and store in <b>sqlite_master</b>
in place of the original command. The text of CREATE TEMPORARY TABLE statements
are stored in the <b>sqlite_temp_master</b> table.</p>
<p>If the optional IF NOT EXISTS clause is present and another table with the
same name aleady exists, then this command becomes a no-op.</p>
<p>Tables are removed using the DROP
TABLE statement.</p>
<h2><a name="CREATE TRIGGER">CREATE TRIGGER</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">CREATE </font></b>[<b><font color="#2c2cf0">TEMP
        </font></b><big>|</big><b><font color="#2c2cf0"> TEMPORARY</font></b>]<b><font color="#2c2cf0">
        TRIGGER </font></b><i><font color="#ff3434">trigger-name</font></i><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0"> BEFORE </font></b><big>|</big><b><font color="#2c2cf0">
        AFTER </font></b>]<b><font color="#2c2cf0"><br>
        </font></b><i><font color="#ff3434">database-event</font></i><b><font color="#2c2cf0">
        ON </font></b>[<i><font color="#ff3434">database-name</font></i><b><font color="#2c2cf0">
        <big>.</big></font></b>]<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">table-name</font></i><b><font color="#2c2cf0"><br>
        </font></b><i><font color="#ff3434">trigger-action</font></i></td>
    </tr>
  </tbody>
</table>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">CREATE </font></b>[<b><font color="#2c2cf0">TEMP
        </font></b><big>|</big><b><font color="#2c2cf0"> TEMPORARY</font></b>]<b><font color="#2c2cf0">
        TRIGGER </font></b><i><font color="#ff3434">trigger-name</font></i><b><font color="#2c2cf0">
        INSTEAD OF<br>
        </font></b><i><font color="#ff3434">database-event</font></i><b><font color="#2c2cf0">
        ON </font></b>[<i><font color="#ff3434">database-name</font></i><b><font color="#2c2cf0">
        <big>.</big></font></b>]<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">view-name</font></i><b><font color="#2c2cf0"><br>
        </font></b><i><font color="#ff3434">trigger-action</font></i></td>
    </tr>
  </tbody>
</table>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">database-event</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">DELETE </font></b><big>|</big><b><font color="#2c2cf0"><br>
        INSERT </font></b><big>|</big><b><font color="#2c2cf0"><br>
        UPDATE </font></b><big>|</big><b><font color="#2c2cf0"><br>
        UPDATE OF </font></b><i><font color="#ff3434">column-list</font></i></td>
    </tr>
  </tbody>
</table>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">trigger-action</font></i>&nbsp;::=</td>
      <td>[<b><font color="#2c2cf0"> FOR EACH ROW </font></b><big>|</big><b><font color="#2c2cf0">
        FOR EACH STATEMENT </font></b>]<b><font color="#2c2cf0"> </font></b>[<b><font color="#2c2cf0">
        WHEN </font></b><i><font color="#ff3434">expression</font></i><b><font color="#2c2cf0">
        </font></b>]<b><font color="#2c2cf0"><br>
        BEGIN<br>
        &nbsp;&nbsp;&nbsp;&nbsp;</font></b><i><font color="#ff3434">trigger-step</font></i><b><font color="#2c2cf0">
        ; </font></b>[<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">trigger-step</font></i><b><font color="#2c2cf0">
        ; </font></b>]<big>*</big><b><font color="#2c2cf0"><br>
        END</font></b></td>
    </tr>
  </tbody>
</table>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">trigger-step</font></i>&nbsp;::=</td>
      <td><i><font color="#ff3434">update-statement</font></i><b><font color="#2c2cf0">
        </font></b><big>|</big><b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">insert-statement</font></i><b><font color="#2c2cf0">
        </font></b><big>|</big><b><font color="#2c2cf0"><br>
        </font></b><i><font color="#ff3434">delete-statement</font></i><b><font color="#2c2cf0">
        </font></b><big>|</big><b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">select-statement</font></i></td>
    </tr>
  </tbody>
</table>
<p>The CREATE TRIGGER statement is used to add triggers to the database schema.
Triggers are database operations (the <i>trigger-action</i>) that are
automatically performed when a specified database event (the <i>database-event</i>)
occurs.</p>
<p>A trigger may be specified to fire whenever a DELETE, INSERT or UPDATE of a
particular database table occurs, or whenever an UPDATE of one or more specified
columns of a table are updated.</p>
<p>At this time SQLite supports only FOR EACH ROW triggers, not FOR EACH
STATEMENT triggers. Hence explicitly specifying FOR EACH ROW is optional. FOR
EACH ROW implies that the SQL statements specified as <i>trigger-steps</i> may
be executed (depending on the WHEN clause) for each database row being inserted,
updated or deleted by the statement causing the trigger to fire.</p>
<p>Both the WHEN clause and the <i>trigger-steps</i> may access elements of the
row being inserted, deleted or updated using references of the form &quot;NEW.<i>column-name</i>&quot;
and &quot;OLD.<i>column-name</i>&quot;, where <i>column-name</i> is the name of
a column from the table that the trigger is associated with. OLD and NEW
references may only be used in triggers on <i>trigger-event</i>s for which they
are relevant, as follows:</p>
<table cellPadding="10" border="0">
  <tbody>
    <tr>
      <td vAlign="top" align="right" width="120"><i>INSERT</i></td>
      <td vAlign="top">NEW references are valid</td>
    </tr>
    <tr>
      <td vAlign="top" align="right" width="120"><i>UPDATE</i></td>
      <td vAlign="top">NEW and OLD references are valid</td>
    </tr>
    <tr>
      <td vAlign="top" align="right" width="120"><i>DELETE</i></td>
      <td vAlign="top">OLD references are valid</td>
    </tr>
  </tbody>
</table>
<p>&nbsp;</p>
<p>If a WHEN clause is supplied, the SQL statements specified as <i>trigger-steps</i>
are only executed for rows for which the WHEN clause is true. If no WHEN clause
is supplied, the SQL statements are executed for all rows.</p>
<p>The specified <i>trigger-time</i> determines when the <i>trigger-steps</i>
will be executed relative to the insertion, modification or removal of the
associated row.</p>
<p>An ON CONFLICT clause may be specified as part of an UPDATE or INSERT <i>trigger-step</i>.
However if an ON CONFLICT clause is specified as part of the statement causing
the trigger to fire, then this conflict handling policy is used instead.</p>
<p>Triggers are automatically dropped when the table that they are associated
with is dropped.</p>
<p>Triggers may be created on views, as well as ordinary tables, by specifying
INSTEAD OF in the CREATE TRIGGER statement. If one or more ON INSERT, ON DELETE
or ON UPDATE triggers are defined on a view, then it is not an error to execute
an INSERT, DELETE or UPDATE statement on the view, respectively. Thereafter,
executing an INSERT, DELETE or UPDATE on the view causes the associated triggers
to fire. The real tables underlying the view are not modified (except possibly
explicitly, by a trigger program).</p>
<p><b>Example:</b></p>
<p>Assuming that customer records are stored in the &quot;customers&quot; table,
and that order records are stored in the &quot;orders&quot; table, the following
trigger ensures that all associated orders are redirected when a customer
changes his or her address:</p>
<blockquote>
  <pre>CREATE TRIGGER update_customer_address UPDATE OF address ON customers 
  BEGIN
    UPDATE orders SET address = new.address WHERE customer_name = old.name;
  END;
</pre>
</blockquote>
<p>With this trigger installed, executing the statement:</p>
<blockquote>
  <pre>UPDATE customers SET address = '1 Main St.' WHERE name = 'Jack Jones';
</pre>
</blockquote>
<p>causes the following to be automatically executed:</p>
<blockquote>
  <pre>UPDATE orders SET address = '1 Main St.' WHERE customer_name = 'Jack Jones';
</pre>
</blockquote>
<p>Note that currently, triggers may behave oddly when created on tables with
INTEGER PRIMARY KEY fields. If a BEFORE trigger program modifies the INTEGER
PRIMARY KEY field of a row that will be subsequently updated by the statement
that causes the trigger to fire, then the update may not occur. The workaround
is to declare the table with a PRIMARY KEY column instead of an INTEGER PRIMARY
KEY column.</p>
<p>A special SQL function RAISE() may be used within a trigger-program, with the
following syntax</p>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">raise-function</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">RAISE <big>(</big> ABORT<big>,</big> </font></b><i><font color="#ff3434">error-message</font></i><b><font color="#2c2cf0">
        <big>)</big> </font></b><big>|</big><b><font color="#2c2cf0"><br>
        RAISE <big>(</big> FAIL<big>,</big> </font></b><i><font color="#ff3434">error-message</font></i><b><font color="#2c2cf0">
        <big>)</big> </font></b><big>|</big><b><font color="#2c2cf0"><br>
        RAISE <big>(</big> ROLLBACK<big>,</big> </font></b><i><font color="#ff3434">error-message</font></i><b><font color="#2c2cf0">
        <big>)</big> </font></b><big>|</big><b><font color="#2c2cf0"><br>
        RAISE <big>(</big> IGNORE <big>)</big></font></b></td>
    </tr>
  </tbody>
</table>
<p>When one of the first three forms is called during trigger-program execution,
the specified ON CONFLICT processing is performed (either ABORT, FAIL or
ROLLBACK) and the current query terminates. An error code of SQLITE_CONSTRAINT
is returned to the user, along with the specified error message.</p>
<p>When RAISE(IGNORE) is called, the remainder of the current trigger program,
the statement that caused the trigger program to execute and any subsequent
trigger programs that would of been executed are abandoned. No database changes
are rolled back. If the statement that caused the trigger program to execute is
itself part of a trigger program, then that trigger program resumes execution at
the beginning of the next step.</p>
<p>Triggers are removed using the DROP
TRIGGER statement.</p>
<h2><a name="CREATE VIEW">CREATE VIEW</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-command</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">CREATE </font></b>[<b><font color="#2c2cf0">TEMP
        </font></b><big>|</big><b><font color="#2c2cf0"> TEMPORARY</font></b>]<b><font color="#2c2cf0">
        VIEW </font></b>[<i><font color="#ff3434">database-name</font></i><b><font color="#2c2cf0"><big>.</big></font></b>]<b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">view-name</font></i><b><font color="#2c2cf0">
        AS </font></b><i><font color="#ff3434">select-statement</font></i></td>
    </tr>
  </tbody>
</table>
<p>The CREATE VIEW command assigns a name to a pre-packaged SELECT
statement. Once the view is created, it can be used in the FROM clause of
another SELECT in place of a table name.</p>
<p>If the &quot;TEMP&quot; or &quot;TEMPORARY&quot; keyword occurs in between
&quot;CREATE&quot; and &quot;VIEW&quot; then the view that is created is only
visible to the process that opened the database and is automatically deleted
when the database is closed.</p>
<p>If a &lt;database-name&gt; is specified, then the view is created in the
named database. It is an error to specify both a &lt;database-name&gt; and the
TEMP keyword, unless the &lt;database-name&gt; is &quot;temp&quot;. If no
database name is specified, and the TEMP keyword is not present, the table is
created in the main database.</p>
<p>You cannot COPY, DELETE, INSERT or UPDATE a view. Views are read-only in
SQLite. However, in many cases you can use a TRIGGER
on the view to accomplish the same thing. Views are removed with the DROP
VIEW command.</p>
<h2><a name="DELETE">DELETE</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">DELETE FROM </font></b>[<i><font color="#ff3434">database-name</font></i><b><font color="#2c2cf0">
        <big>.</big></font></b>]<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">table-name</font></i><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0">WHERE </font></b><i><font color="#ff3434">expr</font></i>]</td>
    </tr>
  </tbody>
</table>
<p>The DELETE command is used to remove records from a table. The command
consists of the &quot;DELETE FROM&quot; keywords followed by the name of the
table from which records are to be removed.</p>
<p>Without a WHERE clause, all rows of the table are removed. If a WHERE clause
is supplied, then only those rows that match the expression are removed.</p>
<h2><a name="DETACH DATABASE">DETACH DATABASE</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-command</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">DETACH </font></b>[<b><font color="#2c2cf0">DATABASE</font></b>]<b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">database-name</font></i></td>
    </tr>
  </tbody>
</table>
<p>This statement detaches an additional database connection previously attached
using the ATTACH DATABASE
statement. It is possible to have the same database file attached multiple times
using different names, and detaching one connection to a file will leave the
others intact.</p>
<p>This statement will fail if SQLite is in the middle of a transaction.</p>
<h2><a name="DROP INDEX">DROP INDEX</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-command</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">DROP INDEX </font></b>[<b><font color="#2c2cf0">IF
        EXISTS</font></b>]<b><font color="#2c2cf0"> </font></b>[<i><font color="#ff3434">database-name</font></i><b><font color="#2c2cf0">
        <big>.</big></font></b>]<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">index-name</font></i></td>
    </tr>
  </tbody>
</table>
<p>The DROP INDEX statement removes an index added with the CREATE
INDEX statement. The index named is completely removed from the disk. The
only way to recover the index is to reenter the appropriate CREATE INDEX
command.</p>
<p>The DROP INDEX statement does not reduce the size of the database file in the
default mode. Empty space in the database is retained for later INSERTs. To
remove free space in the database, use the VACUUM
command. If AUTOVACUUM mode is enabled for a database then space will be freed
automatically by DROP INDEX.</p>
<h2><a name="DROP TABLE">DROP TABLE</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-command</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">DROP TABLE </font></b>[<b><font color="#2c2cf0">IF
        EXISTS</font></b>]<b><font color="#2c2cf0"> </font></b>[<i><font color="#ff3434">database-name</font></i><b><font color="#2c2cf0"><big>.</big></font></b>]<b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">table-name</font></i></td>
    </tr>
  </tbody>
</table>
<p>The DROP TABLE statement removes a table added with the CREATE
TABLE statement. The name specified is the table name. It is completely
removed from the database schema and the disk file. The table can not be
recovered. All indices associated with the table are also deleted.</p>
<p>The DROP TABLE statement does not reduce the size of the database file in the
default mode. Empty space in the database is retained for later INSERTs. To
remove free space in the database, use the VACUUM
command. If AUTOVACUUM mode is enabled for a database then space will be freed
automatically by DROP TABLE.</p>
<p>The optional IF EXISTS clause suppresses the error that would normally result
if the table does not exist.</p>
<h2><a name="DROP TRIGGER">DROP TRIGGER</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">DROP TRIGGER </font></b>[<i><font color="#ff3434">database-name</font></i><b><font color="#2c2cf0">
        <big>.</big></font></b>]<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">trigger-name</font></i></td>
    </tr>
  </tbody>
</table>
<p>The DROP TRIGGER statement removes a trigger created by the CREATE
TRIGGER statement. The trigger is deleted from the database schema. Note
that triggers are automatically dropped when the associated table is dropped.</p>
<h2><a name="DROP VIEW">DROP VIEW</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-command</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">DROP VIEW </font></b><i><font color="#ff3434">view-name</font></i></td>
    </tr>
  </tbody>
</table>
<p>The DROP VIEW statement removes a view created by the CREATE
VIEW statement. The name specified is the view name. It is removed from the
database schema, but no actual data in the underlying base tables is modified.</p>
<h2><a name="EXPLAIN">EXPLAIN</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">EXPLAIN </font></b><i><font color="#ff3434">sql-statement</font></i></td>
    </tr>
  </tbody>
</table>
<p>The EXPLAIN command modifier is a non-standard extension. The idea comes from
a similar command found in PostgreSQL, but the operation is completely
different.</p>
<p>If the EXPLAIN keyword appears before any other SQLite SQL command then
instead of actually executing the command, the SQLite library will report back
the sequence of virtual machine instructions it would have used to execute the
command had the EXPLAIN keyword not been present. For additional information
about virtual machine instructions see the architecture
description or the documentation on available
opcodes for the virtual machine.</p>
<h2><a name="expression">expression</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">expr</font></i>&nbsp;::=</td>
      <td><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">binary-op</font></i><b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0">
        </font></b><big>|</big><b><font color="#2c2cf0"><br>
        </font></b><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0">NOT</font></b>]<b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">like-op</font></i><b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0">ESCAPE </font></b><i><font color="#ff3434">expr</font></i>]<b><font color="#2c2cf0">
        </font></b><big>|</big><b><font color="#2c2cf0"><br>
        </font></b><i><font color="#ff3434">unary-op</font></i><b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0">
        </font></b><big>|</big><b><font color="#2c2cf0"><br>
        <big>(</big> </font></b><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0">
        <big>)</big> </font></b><big>|</big><b><font color="#2c2cf0"><br>
        </font></b><i><font color="#ff3434">column-name</font></i><b><font color="#2c2cf0">
        </font></b><big>|</big><b><font color="#2c2cf0"><br>
        </font></b><i><font color="#ff3434">table-name</font></i><b><font color="#2c2cf0">
        <big>.</big> </font></b><i><font color="#ff3434">column-name</font></i><b><font color="#2c2cf0">
        </font></b><big>|</big><b><font color="#2c2cf0"><br>
        </font></b><i><font color="#ff3434">database-name</font></i><b><font color="#2c2cf0">
        <big>.</big> </font></b><i><font color="#ff3434">table-name</font></i><b><font color="#2c2cf0">
        <big>.</big> </font></b><i><font color="#ff3434">column-name</font></i><b><font color="#2c2cf0">
        </font></b><big>|</big><b><font color="#2c2cf0"><br>
        </font></b><i><font color="#ff3434">literal-value</font></i><b><font color="#2c2cf0">
        </font></b><big>|</big><b><font color="#2c2cf0"><br>
        </font></b><i><font color="#ff3434">parameter</font></i><b><font color="#2c2cf0">
        </font></b><big>|</big><b><font color="#2c2cf0"><br>
        </font></b><i><font color="#ff3434">function-name</font></i><b><font color="#2c2cf0">
        <big>(</big> </font></b><i><font color="#ff3434">expr-list</font></i><b><font color="#2c2cf0">
        </font></b><big>|</big><b><font color="#2c2cf0"> <big>*</big> <big>)</big>
        </font></b><big>|</big><b><font color="#2c2cf0"><br>
        </font></b><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0">
        ISNULL </font></b><big>|</big><b><font color="#2c2cf0"><br>
        </font></b><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0">
        NOTNULL </font></b><big>|</big><b><font color="#2c2cf0"><br>
        </font></b><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0">NOT</font></b>]<b><font color="#2c2cf0">
        BETWEEN </font></b><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0">
        AND </font></b><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0">
        </font></b><big>|</big><b><font color="#2c2cf0"><br>
        </font></b><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0">NOT</font></b>]<b><font color="#2c2cf0">
        IN <big>(</big> </font></b><i><font color="#ff3434">value-list</font></i><b><font color="#2c2cf0">
        <big>)</big> </font></b><big>|</big><b><font color="#2c2cf0"><br>
        </font></b><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0">NOT</font></b>]<b><font color="#2c2cf0">
        IN <big>(</big> </font></b><i><font color="#ff3434">select-statement</font></i><b><font color="#2c2cf0">
        <big>)</big> </font></b><big>|</big><b><font color="#2c2cf0"><br>
        </font></b><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0">NOT</font></b>]<b><font color="#2c2cf0">
        IN </font></b>[<i><font color="#ff3434">database-name</font></i><b><font color="#2c2cf0">
        <big>.</big></font></b>]<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">table-name</font></i><b><font color="#2c2cf0">
        </font></b><big>|</big><b><font color="#2c2cf0"><br>
        </font></b>[<b><font color="#2c2cf0">EXISTS</font></b>]<b><font color="#2c2cf0">
        <big>(</big> </font></b><i><font color="#ff3434">select-statement</font></i><b><font color="#2c2cf0">
        <big>)</big> </font></b><big>|</big><b><font color="#2c2cf0"><br>
        CASE </font></b>[<i><font color="#ff3434">expr</font></i>]<b><font color="#2c2cf0">
        </font></b>(<b><font color="#2c2cf0"> WHEN </font></b><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0">
        THEN </font></b><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0">
        </font></b>)+<b><font color="#2c2cf0"> </font></b>[<b><font color="#2c2cf0">ELSE
        </font></b><i><font color="#ff3434">expr</font></i>]<b><font color="#2c2cf0">
        END </font></b><big>|</big><b><font color="#2c2cf0"><br>
        CAST <big>(</big> </font></b><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0">
        AS </font></b><i><font color="#ff3434">type</font></i><b><font color="#2c2cf0">
        <big>)</big></font></b></td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">like-op</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">LIKE </font></b><big>|</big><b><font color="#2c2cf0">
        GLOB </font></b><big>|</big><b><font color="#2c2cf0"> REGEXP</font></b></td>
    </tr>
  </tbody>
</table>
<p>This section is different from the others. Most other sections of this
document talks about a particular SQL command. This section does not talk about
a standalone command but about &quot;expressions&quot; which are subcomponents
of most other commands.</p>
<p>SQLite understands the following binary operators, in order from highest to
lowest precedence:</p>
<blockquote>
  <pre><font color="#2c2cf0"><big>||
*    /    %
+    -
&lt;&lt;   &gt;&gt;   &amp;    |
&lt;    &lt;=   &gt;    &gt;=
=    ==   !=   &lt;&gt;   </big>IN
AND   
OR</font>
</pre>
</blockquote>
<p>Supported unary operators are these:</p>
<blockquote>
  <pre><font color="#2c2cf0"><big>-    +    !    ~    NOT</big></font>
</pre>
</blockquote>
<p>Note that there are two variations of the equals and not equals operators.
Equals can be either <font color="#2c2cf0"><big>=</big></font> or <font color="#2c2cf0"><big>==</big></font>.
The non-equals operator can be either <font color="#2c2cf0"><big>!=</big></font>
or <font color="#2c2cf0"><big>&lt;&gt;</big></font>. The <font color="#2c2cf0"><big>||</big></font>
operator is &quot;concatenate&quot; - it joins together the two strings of its
operands. The operator <font color="#2c2cf0"><big>%</big></font> outputs the
remainder of its left operand modulo its right operand.</p>
<p>The result of any binary operator is a numeric value, except for the <font color="#2c2cf0"><big>||</big></font>
concatenation operator which gives a string result.</p>
<a name="literal_value"></a>
<p>A literal value is an integer number or a floating point number. Scientific
notation is supported. The &quot;.&quot; character is always used as the decimal
point even if the locale setting specifies &quot;,&quot; for this role - the use
of &quot;,&quot; for the decimal point would result in syntactic ambiguity. A
string constant is formed by enclosing the string in single quotes ('). A single
quote within the string can be encoded by putting two single quotes in a row -
as in Pascal. C-style escapes using the backslash character are not supported
because they are not standard SQL. BLOB literals are string literals containing
hexadecimal data and preceded by a single &quot;x&quot; or &quot;X&quot;
character. For example:</p>
<blockquote>
  <pre>X'53514697465'
</pre>
</blockquote>
<p>A literal value can also be the token &quot;NULL&quot;.</p>
<p>A parameter specifies a placeholder in the expression for a literal value
that is filled in at runtime using the sqlite3_bind
API. Parameters can take several forms:</p>
<table>
  <tbody>
    <tr>
      <td vAlign="top" align="right"><b>?</b><i>NNN</i></td>
      <td width="20"></td>
      <td>A question mark followed by a number <i>NNN</i> holds a spot for the
        NNN-th parameter. NNN must be between 1 and 999.</td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><b>?</b></td>
      <td width="20"></td>
      <td>A question mark that is not followed by a number holds a spot for the
        next unused parameter.</td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><b>:</b><i>AAAA</i></td>
      <td width="20"></td>
      <td>A colon followed by an identifier name holds a spot for a named
        parameter with the name AAAA. Named parameters are also numbered. The
        number assigned is the next unused number. To avoid confusion, it is
        best to avoid mixing named and numbered parameters.</td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><b>$</b><i>AAAA</i></td>
      <td width="20"></td>
      <td>A dollar-sign followed by an identifier name also holds a spot for a
        named parameter with the name AAAA. The identifier name in this case can
        include one or more occurances of &quot;::&quot; and a suffix enclosed
        in &quot;(...)&quot; containing any text at all. This syntax is the form
        of a variable name in the Tcl programming language.</td>
    </tr>
  </tbody>
</table>
<blockquote>
</blockquote>
<p>Parameters that are not assigned values using sqlite3_bind
are treated as NULL.</p>
<a name="like"></a>
<p>The LIKE operator does a pattern matching comparison. The operand to the
right contains the pattern, the left hand operand contains the string to match
against the pattern. A percent symbol <font color="#2c2cf0"><big>%</big></font>
in the pattern matches any sequence of zero or more characters in the string. An
underscore <font color="#2c2cf0"><big>_</big></font> in the pattern matches any
single character in the string. Any other character matches itself or it's
lower/upper case equivalent (i.e. case-insensitive matching). (A bug: SQLite
only understands upper/lower case for 7-bit Latin characters. Hence the LIKE
operator is case sensitive for 8-bit iso8859 characters or UTF-8 characters. For
example, the expression <b>'a'&nbsp;LIKE&nbsp;'A'</b> is TRUE but <b>'?'&nbsp;LIKE&nbsp;'?'</b>
is FALSE.).</p>
<p>If the optional ESCAPE clause is present, then the expression following the
ESCAPE keyword must evaluate to a string consisting of a single character. This
character may be used in the LIKE pattern to include literal percent or
underscore characters. The escape character followed by a percent symbol,
underscore or itself matches a literal percent symbol, underscore or escape
character in the string, respectively. The infix LIKE operator is implemented by
calling the user function like(<i>X</i>,<i>Y</i>).</p>
The LIKE operator is not case sensitive and will match upper case characters on
one side against lower case characters on the other. (A bug: SQLite only
understands upper/lower case for 7-bit Latin characters. Hence the LIKE operator
is case sensitive for 8-bit iso8859 characters or UTF-8 characters. For example,
the expression <b>'a'&nbsp;LIKE&nbsp;'A'</b> is TRUE but <b>'?'&nbsp;LIKE&nbsp;'?'</b>
is FALSE.).
<p>&nbsp;</p>
<p>The infix LIKE operator is implemented by calling the user function like(<i>X</i>,<i>Y</i>).
If an ESCAPE clause is present, it adds a third parameter to the function call.
If the functionality of LIKE can be overridden by defining an alternative
implementation of the like() SQL function.</p>
<p>&nbsp;</p>
<a name="glob"></a>
<p>The GLOB operator is similar to LIKE but uses the Unix file globbing syntax
for its wildcards. Also, GLOB is case sensitive, unlike LIKE. Both GLOB and LIKE
may be preceded by the NOT keyword to invert the sense of the test. The infix
GLOB operator is implemented by calling the user function glob(<i>X</i>,<i>Y</i>)
and can be modified by overriding that function.</p>
<a name="regexp"></a>
<p>The REGEXP operator is a special syntax for the regexp() user function. No
regexp() user function is defined by default and so use of the REGEXP operator
will normally result in an error message. If a user-defined function named
&quot;regexp&quot; is defined at run-time, that function will be called in order
to implement the REGEXP operator.</p>
<p>A column name can be any of the names defined in the CREATE TABLE statement
or one of the following special identifiers: &quot;<b>ROWID</b>&quot;, &quot;<b>OID</b>&quot;,
or &quot;<b>_ROWID_</b>&quot;. These special identifiers all describe the unique
random integer key (the &quot;row key&quot;) associated with every row of every
table. The special identifiers only refer to the row key if the CREATE TABLE
statement does not define a real column with the same name. Row keys act like
read-only columns. A row key can be used anywhere a regular column can be used,
except that you cannot change the value of a row key in an UPDATE or INSERT
statement. &quot;SELECT * ...&quot; does not return the row key.</p>
<p>SELECT statements can appear in expressions as either the right-hand operand
of the IN operator, as a scalar quantity, or as the operand of an EXISTS
operator. As a scalar quantity or the operand of an IN operator, the SELECT
should have only a single column in its result. Compound SELECTs (connected with
keywords like UNION or EXCEPT) are allowed. With the EXISTS operator, the
columns in the result set of the SELECT are ignored and the expression returns
TRUE if one or more rows exist and FALSE if the result set is empty. If no terms
in the SELECT expression refer to value in the containing query, then the
expression is evaluated once prior to any other processing and the result is
reused as necessary. If the SELECT expression does contain variables from the
outer query, then the SELECT is reevaluated every time it is needed.</p>
<p>When a SELECT is the right operand of the IN operator, the IN operator
returns TRUE if the result of the left operand is any of the values generated by
the select. The IN operator may be preceded by the NOT keyword to invert the
sense of the test.</p>
<p>When a SELECT appears within an expression but is not the right operand of an
IN operator, then the first row of the result of the SELECT becomes the value
used in the expression. If the SELECT yields more than one result row, all rows
after the first are ignored. If the SELECT yields no rows, then the value of the
SELECT is NULL.</p>
<p>A CAST expression changes the datatype of the <EXPR>
into the type specified by &lt;type&gt;. &lt;type&gt; can be any non-empty type
name that is valid for the type in a column definition of a CREATE TABLE
statement.</p>
<p>Both simple and aggregate functions are supported. A simple function can be
used in any expression. Simple functions return a result immediately based on
their inputs. Aggregate functions may only be used in a SELECT statement.
Aggregate functions compute their result across all rows of the result set.</p>
<p>The functions shown below are available by default. Additional functions may
be written in C and added to the database engine using the sqlite3_create_function()
API.</p>
<table cellPadding="10" border="0">
  <tbody>
    <tr>
      <td vAlign="top" align="right" width="120">abs(<i>X</i>)</td>
      <td vAlign="top">Return the absolute value of argument <i>X</i>.</td>
    </tr>
    <tr>
      <td vAlign="top" align="right">coalesce(<i>X</i>,<i>Y</i>,...)</td>
      <td vAlign="top">Return a copy of the first non-NULL argument. If all
        arguments are NULL then NULL is returned. There must be at least 2
        arguments.</td>
    </tr>
    <tr>
      <a name="globFunc"></a>
      <td vAlign="top" align="right">glob(<i>X</i>,<i>Y</i>)</td>
      <td vAlign="top">This function is used to implement the &quot;<b>X GLOB Y</b>&quot;
        syntax of SQLite. The sqlite3_create_function()
        interface can be used to override this function and thereby change the
        operation of the GLOB operator.</td>
    </tr>
    <tr>
      <td vAlign="top" align="right">ifnull(<i>X</i>,<i>Y</i>)</td>
      <td vAlign="top">Return a copy of the first non-NULL argument. If both
        arguments are NULL then NULL is returned. This behaves the same as <b>coalesce()</b>
        above.</td>
    </tr>
    <tr>
      <td vAlign="top" align="right">last_insert_rowid()</td>
      <td vAlign="top">Return the ROWID of the last row insert from this
        connection to the database. This is the same value that would be
        returned from the <b>sqlite_last_insert_rowid()</b> API function.</td>
    </tr>
    <tr>
      <td vAlign="top" align="right">length(<i>X</i>)</td>
      <td vAlign="top">Return the string length of <i>X</i> in characters. If
        SQLite is configured to support UTF-8, then the number of UTF-8
        characters is returned, not the number of bytes.</td>
    </tr>
    <tr>
      <a name="likeFunc"></a>
      <td vAlign="top" align="right">like(<i>X</i>,<i>Y</i> [,<i>Z</i>])</td>
      <td vAlign="top">This function is used to implement the &quot;<b>X LIKE Y
        [ESCAPE Z]</b>&quot; syntax of SQL. If the optional ESCAPE clause is
        present, then the user-function is invoked with three arguments.
        Otherwise, it is invoked with two arguments only. The sqlite_create_function()
        interface can be used to override this function and thereby change the
        operation of the LIKE operator. When doing this, it
        may be important to override both the two and three argument versions of
        the like() function. Otherwise, different code may be called to
        implement the LIKE operator depending on whether or not an ESCAPE clause
        was specified.</td>
    </tr>
    <tr>
      <td vAlign="top" align="right">lower(<i>X</i>)</td>
      <td vAlign="top">Return a copy of string <i>X</i> will all characters
        converted to lower case. The C library <b>tolower()</b> routine is used
        for the conversion, which means that this function might not work
        correctly on UTF-8 characters.</td>
    </tr>
    <tr>
      <td vAlign="top" align="right">max(<i>X</i>,<i>Y</i>,...)</td>
      <td vAlign="top">Return the argument with the maximum value. Arguments may
        be strings in addition to numbers. The maximum value is determined by
        the usual sort order. Note that <b>max()</b> is a simple function when
        it has 2 or more arguments but converts to an aggregate function if
        given only a single argument.</td>
    </tr>
    <tr>
      <td vAlign="top" align="right">min(<i>X</i>,<i>Y</i>,...)</td>
      <td vAlign="top">Return the argument with the minimum value. Arguments may
        be strings in addition to numbers. The minimum value is determined by
        the usual sort order. Note that <b>min()</b> is a simple function when
        it has 2 or more arguments but converts to an aggregate function if
        given only a single argument.</td>
    </tr>
    <tr>
      <td vAlign="top" align="right">nullif(<i>X</i>,<i>Y</i>)</td>
      <td vAlign="top">Return the first argument if the arguments are different,
        otherwise return NULL.</td>
    </tr>
    <tr>
      <td vAlign="top" align="right">quote(<i>X</i>)</td>
      <td vAlign="top">This routine returns a string which is the value of its
        argument suitable for inclusion into another SQL statement. Strings are
        surrounded by single-quotes with escapes on interior quotes as needed.
        BLOBs are encoded as hexadecimal literals. The current implementation of
        VACUUM uses this function. The function is also useful when writing
        triggers to implement undo/redo functionality.</td>
    </tr>
    <tr>
      <td vAlign="top" align="right">random(*)</td>
      <td vAlign="top">Return a random integer between -2147483648 and
        +2147483647.</td>
    </tr>
    <tr>
      <td vAlign="top" align="right">round(<i>X</i>)<br>
        round(<i>X</i>,<i>Y</i>)</td>
      <td vAlign="top">Round off the number <i>X</i> to <i>Y</i> digits to the
        right of the decimal point. If the <i>Y</i> argument is omitted, 0 is
        assumed.</td>
    </tr>
    <tr>
      <td vAlign="top" align="right">soundex(<i>X</i>)</td>
      <td vAlign="top">Compute the soundex encoding of the string <i>X</i>. The
        string &quot;?000&quot; is returned if the argument is NULL. This
        function is omitted from SQLite by default. It is only available the
        -DSQLITE_SOUNDEX=1 compiler option is used when SQLite is built.</td>
    </tr>
    <tr>
      <td vAlign="top" align="right">sqlite_version(*)</td>
      <td vAlign="top">Return the version string for the SQLite library that is
        running. Example: &quot;2.8.0&quot;</td>
    </tr>
    <tr>
      <td vAlign="top" align="right">substr(<i>X</i>,<i>Y</i>,<i>Z</i>)</td>
      <td vAlign="top">Return a substring of input string <i>X</i> that begins
        with the <i>Y</i>-th character and which is <i>Z</i> characters long.
        The left-most character of <i>X</i> is number 1. If <i>Y</i> is negative
        the the first character of the substring is found by counting from the
        right rather than the left. If SQLite is configured to support UTF-8,
        then characters indices refer to actual UTF-8 characters, not bytes.</td>
    </tr>
    <tr>
      <td vAlign="top" align="right">typeof(<i>X</i>)</td>
      <td vAlign="top">Return the type of the expression <i>X</i>. The only
        return values are &quot;null&quot;, &quot;integer&quot;,
        &quot;real&quot;, &quot;text&quot;, and &quot;blob&quot;. SQLite's type
        handling is explained in <a href="#Datatypes">Datatypes
        in SQLite Version 3</a>.</td>
    </tr>
    <tr>
      <td vAlign="top" align="right">upper(<i>X</i>)</td>
      <td vAlign="top">Return a copy of input string <i>X</i> converted to all
        upper-case letters. The implementation of this function uses the C
        library routine <b>toupper()</b> which means it may not work correctly
        on UTF-8 strings.</td>
    </tr>
  </tbody>
</table>
<p>The aggregate functions shown below are available by default. Additional
aggregate functions written in C may be added using the sqlite3_create_function()
API.</p>
<p>In any aggregate function that takes a single argument, that argument can be
preceeded by the keyword DISTINCT. In such cases, duplicate elements are
filtered before being passed into the aggregate function. For example, the
function &quot;count(distinct X)&quot; will return the number of distinct values
of column X instead of the total number of non-null values in column X.</p>
<table cellPadding="10" border="0">
  <tbody>
    <tr>
      <td vAlign="top" align="right" width="120">avg(<i>X</i>)</td>
      <td vAlign="top">Return the average value of all non-NULL <i>X</i> within
        a group. String and BLOB values that do not look like numbers are
        interpreted as 0. The result of avg() is always a floating point value
        even if all inputs are integers.
        <p>&nbsp;</p>
      </td>
    </tr>
    <tr>
      <td vAlign="top" align="right">count(<i>X</i>)<br>
        count(*)</td>
      <td vAlign="top">The first form return a count of the number of times that
        <i>X</i> is not NULL in a group. The second form (with no argument)
        returns the total number of rows in the group.</td>
    </tr>
    <tr>
      <td vAlign="top" align="right">max(<i>X</i>)</td>
      <td vAlign="top">Return the maximum value of all values in the group. The
        usual sort order is used to determine the maximum.</td>
    </tr>
    <tr>
      <td vAlign="top" align="right">min(<i>X</i>)</td>
      <td vAlign="top">Return the minimum non-NULL value of all values in the
        group. The usual sort order is used to determine the minimum. NULL is
        only returned if all values in the group are NULL.</td>
    </tr>
    <tr>
      <td vAlign="top" align="right">sum(<i>X</i>)<br>
        total(<i>X</i>)</td>
      <td vAlign="top">Return the numeric sum of all non-NULL values in the
        group. If there are no non-NULL input rows then sum() returns NULL but
        total() returns 0.0. NULL is not normally a helpful result for the sum
        of no rows but the SQL standard requires it and most other SQL database
        engines implement sum() that way so SQLite does it in the same way in
        order to be compatible. The non-standard total() function is provided as
        a convenient way to work around this design problem in the SQL language.
        <p>&nbsp;</p>
        <p>The result of total() is always a floating point value. The result of
        sum() is an integer value if all non-NULL inputs are integers. If any
        input to sum() is neither an integer or a NULL then sum() returns a
        floating point value which might be an approximation to the true sum.</p>
        <p>Sum() will throw an &quot;integer overflow&quot; exception if all
        inputs are integers or NULL and an integer overflow occurs at any point
        during the computation. Total() never throws an exception.</p>
      </td>
    </tr>
  </tbody>
</table>

<p>In addition to the
          standard SQLite SQL <a href="sql.htm#functions">functions</a> that you
          can use in any <a href="sql.htm#expression">expression</a> SQLite3 COM
          implements a number of functions such as OLE date/time and Session
          parameters.
          <h4><a name="Session">Session</a> parameter functions</h4>
          <p>The session parameter functions work together with the <a href="SQLite-Parameters.htm">Parameters</a>
          collection maintained by the SQLite3 COM object. No matter if the
          functions are called explicitly or implicitly they return the value
          corresponding to the parameter in the same collection. By explicit use
          we mean usage in a query passed to an <a href="SQLite-Execute.htm">Execute</a>
          method, by implicit usage we mean a call to these functions caused by
          invoking a view or a trigger in result of execution of a query that
          refers to the view or triggers the trigger.
          <p>The functions:
          <blockquote>
            <p><b><font color="#FF0000">Parameter('&lt;param_name&gt;')</font></b><br>
            Returns the value of a parameter in the <a href="SQLite-Parameters.htm">Parameters</a>
            collection. &lt;param_name&gt; is the name of the parameter in the
            Parameters collection as set when the Add method or
            object.Parameters(&lt;param_name&gt;) = soemthing has been used. If
            an object is set under that name in the Parameters collection its
            default property is returned. If the object has no such property
            database error will occur. If the parameter does not exist &quot;Parameter not found&quot;
            database error will occur.
            <br>
            <br>
            <b><font color="#FF0000">RefDate() and RefDateSys()</font></b><br>
            Return the current date/time or the reference date/time as specified
            in the <a href="SQLite-Parameters.htm">Parameters</a> object (see
            the ReferenceDate and UseReferenceDate properties). The difference
            between the two function is as follows: RefDate function returns the
            current local date/time when Parameters.UseReferenceDate = false,
            while RefDateSys returns the UTC date/time. Both functions return
            the reference date &quot;as is&quot; if Parameters.UseReferenceDate
            = true.
            <br>
            <br>
            <b><font color="#FF0000">CallObject('param_name' [,'method_or_prop_name'
            [, arg1 [, arg2 [ ...] ]]]</font></b><br>
            If the parameter in the Parameters collection specified by the name <b><i>param_name</i></b>
            is an object this function calls a method on it or gets the value of
            objects property. All the arguments except the param_name are
            optional. If all are omitted the default property is returned (if
            exists).&nbsp;<br>
            If a <b><i>method_or_prop_name</i></b> is specified the specified
            property or method is called on the object.<br>
            All the remaining arguments are passed to the called method or
            property. Their number and type must match the arguments of the
            called method or property.<br>
            If an error occurs in the called method/property &quot;Object error&quot;
            database error will occur.<br>
            If the param_name points to a parameter that is not an object "The specified parameter is NULL or not an object"
            database error is issued.<br>
            The called method or property must return result which can be
            converted to one of the database types INTEGER, REAL, TEXT, BLOB or
            NULL. I.e. if the result is an object (without default property
            returning scalar value) an error will occur: "Cannot convert/obtain the returned result in useful form."<p>&nbsp;
          </blockquote>
          <h4><a name="OLE">OLE</a> date/time functions</h4>
          <p>SQLite3 COM defines a set
          of Date/Time SQL functions which can be used in SQL statements to deal
          with date and time values in a manner compatible and convenient for
          COM programming. They allow you work with date/time values even
          without support from the outside - for instance making conversion
          every time you read/write values from to the database. You can move
          most of the date/time related work to the SQL instead of doing it in
          the application code (VBScript, JScript, VB etc.). This is often more
          productive and especially useful if embedding date/time calculations
          in the SQL will offer more simplicity and better performance. For
          instance if you need to filter some records based on some date/time
          criteria that involves calculation of intervals for example, instead
          of feeding the SQL with pre-calculated values it is better to do this
          in the SQL statement in-place and thus benefit of the ability to
          calculate them dynamically in the SQL over the current data.<p><b>What
          is the OLE DATE type?</b> In short it is double precision floating
          point value that counts the time from 30 December 1899 00:00:00. The
          positive values mean date after this date, negative values mean date
          before that date. Thus 0.0 will equal to 30 December 1899 00:00:00.
          Therefore when OLE DATE is used to specify time only (without a date)
          it will convert to 30 December 1899 plus some hours, minutes seconds
          if it is converted to full date in a mistake. The OLE DATE values act
          correctly in any expression because they are just real numbers, they
          can be summed, subtracted and otherwise processed. The fact that the
          time and the date are kept in a single value allows complex
          calculations that involve date and time parts (and not only one of
          them) to be performed easily. In contrast the Julian date supported by
          the most databases (SQLite contains other set of functions for this)
          keeps the date and the time in separate values and makes the
          expressions more difficult to write. The additional benefit of using
          OLE DATE is that the values that are result of expressions/statements
          can be directly passed to any script or a COM routine that requires
          date/time value without any conversion.<p><b>The functions:</b>
          <blockquote>
            <p><b><font color="#FF0000">ParseOleDate</font></b> - Parses a
            date/time string in standard format and returns the double precision
            value that represents it. The format is:<br>
            YYYY-MM-DD hh:mm:ss. Example:<br>
            <br>
            <b>SELECT * FROM T WHERE Created &gt; ParseOleDate(&quot;2001-01-05&quot;);</b><br>
            will return the records with field &quot;Created&quot; containing
            date bigger than or equal to January, 05, 2001.<br>
            <b>SELECT * FROM T WHERE Created &gt; ParseOleDate(&quot;2001-01-05
            13:30&quot;);<br>
            </b>will return the records with field &quot;Created&quot;
            containing date/time bigger than or equal to January, 05, 2001 01:30
            pm<p>You can pass date only or time only to ParseOleDate function.
            For instance all these:<br>
            ParseOleDate(&quot;2003-05-12&quot;)<br>
            ParseOleDate(&quot;05:15:00&quot;)<br>
            ParseOleDate(&quot;05:15&quot;)<br>
            ParseOleDate(&quot;2004-06-17 05:15:00&quot;)<br>
            will be ok. The seconds part of the time specification are optional.<p>Note
            that we are using this function in the samples below to make them
            more readable. In the real world you will pass to them arguments
            that are results from the query or an expression.&nbsp;<p><b><font color="#FF0000">OleDateTime</font></b>
            - Composes a date/time string in the standard format from a date
            value. For instance PleDateTime(0.0) will return &quot;1899-12-30
            00:00:00&quot;. This function is needed when the date values are to
            be converted to human readable format after some calculations.<p><b><font color="#FF0000">OleDate</font></b>
            and <b><font color="#FF0000">OleTime</font></b> - Act as above but
            return only the date part of the string representation (OleDate) or
            only the time part (OleTime) of the date/time value passed as
            argument. For example:<br>
            <b>SELECT OleDate(ParseOleDate(&quot;2001-12-22 14:30:10&quot;));</b><br>
            &nbsp;will return &quot;2001-12-22&quot;<br>
            <b>SELECT OleTime(ParseOleDate(&quot;2001-12-22 14:30:10&quot;));</b><br>
            &nbsp;will return &quot;14:30:10&quot;<br>
            <br>
            <b><font color="#FF0000">OleDay</font></b>, <b><font color="#FF0000">OleMonth</font></b>,
            <b><font color="#FF0000">OleYear</font></b>, <font color="#FF0000"><b>OleHour</b></font>,
            <font color="#FF0000"><b>OleMinute</b></font>, <b><font color="#FF0000">OleSecond</font></b>
            and <b><font color="#FF0000">OleWeekDay</font></b> - all return
            numeric value that represents the corresponding part of the date
            value passed to them as argument. For example:<br>
            SELECT <b>OleDay(ParseOleDate(&quot;2001-12-22 14:30:10&quot;));<br>
            </b>&nbsp;will return <b>22</b> (22 - day of the month)<br>
            SELECT <b>OleMonth(ParseOleDate(&quot;2001-12-22 14:30:10&quot;));<br>
            </b>&nbsp;will return <b>12 </b>(12 month - December)<br>
            SELECT <b>OleYear(ParseOleDate(&quot;2001-12-22 14:30:10&quot;));<br>
            </b>&nbsp;will return <b>2001 </b>(the year specified in the date
            value)<br>
            SELECT <b>OleHour(ParseOleDate(&quot;2001-12-22 14:30:10&quot;));<br>
            </b>&nbsp;will return <b>14 </b>(2 p.m.)<br>
            SELECT <b>OleMinute(ParseOleDate(&quot;2001-12-22 14:30:10&quot;));<br>
            </b>&nbsp;will return <b>30 </b>(the minutes of the time contained
            in the value)<br>
            SELECT <b>OleSeconds(ParseOleDate(&quot;2001-12-22 14:30:10&quot;));<br>
            </b>&nbsp;will return <b>10 </b>(the seconds of the time contained
            in the value)<br>
            SELECT <b>OleWeekDay(ParseOleDate(&quot;2001-12-22 14:30:10&quot;));<br>
            </b>&nbsp;will return <b>7 </b>(Saturday)<p>For example if you want
            to query for records created on Mondays, assuming the Created field
            contains their creation time you can use query like this:<br>
            <b>SELECT * FROM T WHERE OleWeekDay(Created) = 7;</b><p>The week
            days are numbered as follows: 1 - Sunday, 2 - Monday ... 7 -
            Saturday<p><b><font color="#FF0000">OleDateAdd</font></b> - This
            function provides way to calculate new date over existing one adding
            an interval to it. The full specification of the function is:<br>
            <b>OleDateAdd</b>(interval,count,date)<br>
            &nbsp; <b>interval</b> - is a character which can be: &quot;Y&quot;
            - years, &quot;M&quot; - months, &quot;D&quot; - days, &quot;h&quot;
            - hours, &quot;m&quot; - minutes, &quot;s&quot; - seconds<br>
            &nbsp; <b>count</b> - is a number specifying how many <b>interval</b>-s
            to add. Can be negative if you want to subtract from the date.<br>
            &nbsp; <b>date</b> - is the date value to which the interval will be
            added.<br>
            For example this can be useful to fetch the records created in past
            month:<br>
            <b>SELECT * FROM T WHERE Created &gt; OleDateAdd(&quot;M&quot;,-1,ParseOleDate(&quot;2004-12-14&quot;))
            AND Created &lt; ParseOleDate(&quot;2004-12-14&quot;);<br>
            </b>Assuming that the string in the ParseOleDate is passed from
            outside.<p><b><font color="#FF0000">OleDateDiff</font></b> - This function calculates the difference
            between two date/time values in the interval-s specified. The full
            specification is:<br>
            OleDateDiff(interval,date1,date2)<br>
            &nbsp; <b>interval</b> - One character specifying the interval in
            which the difference will be calculated. Can be: &quot;Y&quot; -
            years, &quot;M&quot; - months, &quot;D&quot; - days, &quot;h&quot; -
            hours, &quot;m&quot; - minutes, &quot;s&quot; - seconds<br>
            &nbsp; <b>date1</b> - The first date<br>
            &nbsp; <b>date2</b> - The second date <br>
            If the date2 is bigger than date1 the result is positive (or 0) and
            negative (or 0) otherwise.<br>
            For example if you want to fetch the records created this month you
            can use query like this one:<br>
            <b>SELECT * FROM T WHERE
            OleDateDiff(&quot;M&quot;,Created,ParseOleDate(&quot;2004-12-14&quot;))
            = 0;</b>
            <p><font color="#FF0000"><b>OleLocalTime</b><b>()</b></font>, <b><font color="#FF0000">OleSysTime()</font></b>
            - return the current local time (OleLocalTime) or the current UTC
            time (OleSysTime).
          </blockquote>
          <p>&nbsp; <p><b>A small sample ASP code</b>.
          These few lines of code Execute a query that retrieves the records
          created during the previous year from a table &quot;T&quot;, the field
          &quot;Created&quot; is assumed to contain the record creation date.<pre class="sample">Set db = Server.CreateObject(&quot;newObjects.sqlite.dbutf8&quot;)
Set su = Server.CreateObject(&quot;newObjects.utilctls.<a href="../axpack1/StringUtilities.htm">StringUtilities</a>&quot;)
dt = Now
Set r = db.Execute(su.Sprintf(&quot;SELECT * FROM T WHERE &quot; &amp; _
          &quot;OleDateDiff('Y',Created,ParseOleDate('%hT')) = 1&quot;,dt))
%&gt;
&lt;TABLE&gt;
&lt;%
For I = 1 To r.Count
  %&gt;
  &lt;TR&gt;
    &lt;% For J = 1 To r(I).Count %&gt;
      &lt;TD&gt;&lt;%= r(I)(J) %&gt;&lt;/TD&gt;
    &lt;% Next %&gt;
  &lt;/TR&gt;
  &lt;%
Next
%&gt;
&lt;/TABLE&gt; 
</pre>
<h2><a name="INSERT">INSERT</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">INSERT </font></b>[<b><font color="#2c2cf0">OR
        </font></b><i><font color="#ff3434">conflict-algorithm</font></i>]<b><font color="#2c2cf0">
        INTO </font></b>[<i><font color="#ff3434">database-name</font></i><b><font color="#2c2cf0">
        <big>.</big></font></b>]<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">table-name</font></i><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0"><big>(</big></font></b><i><font color="#ff3434">column-list</font></i><b><font color="#2c2cf0"><big>)</big></font></b>]<b><font color="#2c2cf0">
        VALUES<big>(</big></font></b><i><font color="#ff3434">value-list</font></i><b><font color="#2c2cf0"><big>)</big>
        </font></b><big>|</big><b><font color="#2c2cf0"><br>
        INSERT </font></b>[<b><font color="#2c2cf0">OR </font></b><i><font color="#ff3434">conflict-algorithm</font></i>]<b><font color="#2c2cf0">
        INTO </font></b>[<i><font color="#ff3434">database-name</font></i><b><font color="#2c2cf0">
        <big>.</big></font></b>]<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">table-name</font></i><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0"><big>(</big></font></b><i><font color="#ff3434">column-list</font></i><b><font color="#2c2cf0"><big>)</big></font></b>]<b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">select-statement</font></i></td>
    </tr>
  </tbody>
</table>
<p>The INSERT statement comes in two basic forms. The first form (with the
&quot;VALUES&quot; keyword) creates a single new row in an existing table. If no
column-list is specified then the number of values must be the same as the
number of columns in the table. If a column-list is specified, then the number
of values must match the number of specified columns. Columns of the table that
do not appear in the column list are filled with the default value, or with NULL
if not default value is specified.</p>
<p>The second form of the INSERT statement takes it data from a SELECT
statement. The number of columns in the result of the SELECT must exactly match
the number of columns in the table if no column list is specified, or it must
match the number of columns name in the column list. A new entry is made in the
table for every row of the SELECT result. The SELECT may be simple or compound.
If the SELECT statement has an ORDER BY clause, the ORDER BY is ignored.</p>
<p>The optional conflict-clause allows the specification of an alternative
constraint conflict resolution algorithm to use during this one command. See the
section titled ON CONFLICT
for additional information. For compatibility with MySQL, the parser allows the
use of the single keyword REPLACE
as an alias for &quot;INSERT OR REPLACE&quot;.</p>
<h2><a name="ON CONFLICT clause">ON CONFLICT clause</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">conflict-clause</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">ON CONFLICT </font></b><i><font color="#ff3434">conflict-algorithm</font></i></td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">conflict-algorithm</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">ROLLBACK </font></b><big>|</big><b><font color="#2c2cf0">
        ABORT </font></b><big>|</big><b><font color="#2c2cf0"> FAIL </font></b><big>|</big><b><font color="#2c2cf0">
        IGNORE </font></b><big>|</big><b><font color="#2c2cf0"> REPLACE</font></b></td>
    </tr>
  </tbody>
</table>
<p>The ON CONFLICT clause is not a separate SQL command. It is a non-standard
clause that can appear in many other SQL commands. It is given its own section
in this document because it is not part of standard SQL and therefore might not
be familiar.</p>
<p>The syntax for the ON CONFLICT clause is as shown above for the CREATE TABLE
command. For the INSERT and UPDATE commands, the keywords &quot;ON
CONFLICT&quot; are replaced by &quot;OR&quot;, to make the syntax seem more
natural. For example, instead of &quot;INSERT ON CONFLICT IGNORE&quot; we have
&quot;INSERT OR IGNORE&quot;. The keywords change but the meaning of the clause
is the same either way.</p>
<p>The ON CONFLICT clause specifies an algorithm used to resolve constraint
conflicts. There are five choices: ROLLBACK, ABORT, FAIL, IGNORE, and REPLACE.
The default algorithm is ABORT. This is what they mean:</p>
<dl>
  <dt><b>ROLLBACK</b>
  <dd>
    <p>When a constraint violation occurs, an immediate ROLLBACK occurs, thus
    ending the current transaction, and the command aborts with a return code of
    SQLITE_CONSTRAINT. If no transaction is active (other than the implied
    transaction that is created on every command) then this algorithm works the
    same as ABORT.</p>
  <dt><b>ABORT</b>
  <dd>
    <p>When a constraint violation occurs, the command backs out any prior
    changes it might have made and aborts with a return code of
    SQLITE_CONSTRAINT. But no ROLLBACK is executed so changes from prior
    commands within the same transaction are preserved. This is the default
    behavior.</p>
  <dt><b>FAIL</b>
  <dd>
    <p>When a constraint violation occurs, the command aborts with a return code
    SQLITE_CONSTRAINT. But any changes to the database that the command made
    prior to encountering the constraint violation are preserved and are not
    backed out. For example, if an UPDATE statement encountered a constraint
    violation on the 100th row that it attempts to update, then the first 99 row
    changes are preserved but changes to rows 100 and beyond never occur.</p>
  <dt><b>IGNORE</b>
  <dd>
    <p>When a constraint violation occurs, the one row that contains the
    constraint violation is not inserted or changed. But the command continues
    executing normally. Other rows before and after the row that contained the
    constraint violation continue to be inserted or updated normally. No error
    is returned.</p>
  <dt><b>REPLACE</b>
  <dd>
    <p>When a UNIQUE constraint violation occurs, the pre-existing rows that are
    causing the constraint violation are removed prior to inserting or updating
    the current row. Thus the insert or update always occurs. The command
    continues executing normally. No error is returned. If a NOT NULL constraint
    violation occurs, the NULL value is replaced by the default value for that
    column. If the column has no default value, then the ABORT algorithm is
    used. If a CHECK constraint violation occurs then the IGNORE algorithm is
    used.</p>
    <p>When this conflict resolution strategy deletes rows in order to satisfy a
    constraint, it does not invoke delete triggers on those rows. This behavior
    might change in a future release.</p>
  </dd>
</dl>
<p>The algorithm specified in the OR clause of a INSERT or UPDATE overrides any
algorithm specified in a CREATE TABLE. If no algorithm is specified anywhere,
the ABORT algorithm is used.</p>
<h2><a name="PRAGMA">PRAGMA</a> command syntax</h2>
<p>The PRAGMA command is a special command used to modify
the operation of the SQLite library or to query the library for internal
(non-table) data. The PRAGMA command is issued using the same interface as other
SQLite commands (e.g. SELECT, INSERT) but is different in the following
important respects:</p>
<ul>
  <li>Specific pragma statements may be removed and others added in future
    releases of SQLite. Use with caution!
  <li>No error messages are generated if an unknown pragma is issued. Unknown
    pragmas are simply ignored. This means if there is a typo in a pragma
    statement the library does not inform the user of the fact.
  <li>Some pragmas take effect during the SQL compilation stage, not the
    execution stage. This means if using the C-language sqlite3_compile(),
    sqlite3_step(), sqlite3_finalize() API (or similar in a wrapper interface),
    the pragma may be applied to the library during the sqlite3_compile() call.
  <li>The pragma command is unlikely to be compatible with any other SQL engine.</li>
</ul>
<p>The available pragmas fall into four basic categories:</p>
<ul>
  <li>Pragmas used to query the schema of the current
    database.
  <li>Pragmas used to modify the operation of the SQLite
    library in some manner, or to query for the current mode of operation.
  <li>Pragmas used to query or modify the databases two version values, the schema-version and the user-version.
  <li>Pragmas used to debug the library and verify that
    database files are not corrupted.</li>
</ul>
<hr>
<a name="syntax"></a>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">PRAGMA </font></b><i><font color="#ff3434">name</font></i><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0">= </font></b><i><font color="#ff3434">value</font></i>]<b><font color="#2c2cf0">
        </font></b><big>|</big><b><font color="#2c2cf0"><br>
        PRAGMA </font></b><i><font color="#ff3434">function</font></i><b><font color="#2c2cf0"><big>(</big></font></b><i><font color="#ff3434">arg</font></i><b><font color="#2c2cf0"><big>)</big></font></b></td>
    </tr>
  </tbody>
</table>
<p>The pragmas that take an integer <b><i>value</i></b> also accept symbolic
names. The strings &quot;<b>on</b>&quot;, &quot;<b>true</b>&quot;, and &quot;<b>yes</b>&quot;
are equivalent to <b>1</b>. The strings &quot;<b>off</b>&quot;, &quot;<b>false</b>&quot;,
and &quot;<b>no</b>&quot; are equivalent to <b>0</b>. These strings are case-
insensitive, and do not require quotes. An unrecognized string will be treated
as <b>1</b>, and will not generate an error. When the <i>value</i> is returned
it is as an integer.</p>
<hr>
<a name="modify"></a>
<h1>Pragmas to modify library operation</h1>
<ul>
  <a name="pragma_auto_vacuum"></a>
  <li>
    <p><b>PRAGMA auto_vacuum;<br>
    PRAGMA auto_vacuum = </b><i>0 | 1</i><b>;</b></p>
    <p>Query or set the auto-vacuum flag in the database.</p>
    <p>Normally, when a transaction that deletes data from a database is
    committed, the database file remains the same size. Unused database file
    pages are marked as such and reused later on, when data is inserted into the
    database. In this mode the VACUUM
    command is used to reclaim unused space.</p>
    <p>When the auto-vacuum flag is set, the database file shrinks when a
    transaction that deletes data is committed (The VACUUM command is not useful
    in a database with the auto-vacuum flag set). To support this functionality
    the database stores extra information internally, resulting in slightly
    larger database files than would otherwise be possible.</p>
    <p>It is only possible to modify the value of the auto-vacuum flag before
    any tables have been created in the database. No error message is returned
    if an attempt to modify the auto-vacuum flag is made after one or more
    tables have been created.</p>
    <a name="pragma_cache_size"></a>
  <li>
    <p><b>PRAGMA cache_size;<br>
    PRAGMA cache_size = </b><i>Number-of-pages</i><b>;</b></p>
    <p>Query or change the maximum number of database disk pages that SQLite
    will hold in memory at once. Each page uses about 1.5K of memory. The
    default cache size is 2000. If you are doing UPDATEs or DELETEs that change
    many rows of a database and you do not mind if SQLite uses more memory, you
    can increase the cache size for a possible speed improvement.</p>
    <p>When you change the cache size using the cache_size pragma, the change
    only endures for the current session. The cache size reverts to the default
    value when the database is closed and reopened. Use the <b>default_cache_size</b>
    pragma to check the cache size permanently.</p>
    <a name="pragma_case_sensitive_like"></a>
  <li>
    <p><b>PRAGMA case_sensitive_like;<br>
    PRAGMA case_sensitive_like = </b><i>0 | 1</i><b>;</b></p>
    <p>The default behavior of the LIKE operator is to ignore case for latin1
    characters. Hence, by default <b>'a' LIKE 'A'</b> is true. The
    case_sensitive_like pragma can be turned on to change this behavior. When
    case_sensitive_like is enabled, <b>'a' LIKE 'A'</b> is false but <b>'a' LIKE
    'a'</b> is still true.</p>
    <a name="pragma_count_changes"></a>
  <li>
    <p><b>PRAGMA count_changes;<br>
    PRAGMA count_changes = </b><i>0 | 1</i><b>;</b></p>
    <p>Query or change the count-changes flag. Normally, when the count-changes
    flag is not set, INSERT, UPDATE and DELETE statements return no data. When
    count-changes is set, each of these commands returns a single row of data
    consisting of one integer value - the number of rows inserted, modified or
    deleted by the command. The returned change count does not include any
    insertions, modifications or deletions performed by triggers.</p>
    <a name="pragma_default_cache_size"></a>
  <li>
    <p><b>PRAGMA default_cache_size;<br>
    PRAGMA default_cache_size = </b><i>Number-of-pages</i><b>;</b></p>
    <p>Query or change the maximum number of database disk pages that SQLite
    will hold in memory at once. Each page uses 1K on disk and about 1.5K in
    memory. This pragma works like the <b>cache_size</b>
    pragma with the additional feature that it changes the cache size
    persistently. With this pragma, you can set the cache size once and that
    setting is retained and reused every time you reopen the database.</p>
    <a name="pragma_default_synchronous"></a>
  <li>
    <p><b>PRAGMA default_synchronous;</b></p>
    <p>This pragma was available in version 2.8 but was removed in version 3.0.
    It is a dangerous pragma whose use is discouraged. To help dissuide users of
    version 2.8 from employing this pragma, the documentation will not tell you
    what it does.</p>
    <a name="pragma_empty_result_callbacks"></a>
  <li>
    <p><b>PRAGMA empty_result_callbacks;<br>
    PRAGMA empty_result_callbacks = </b><i>0 | 1</i><b>;</b></p>
    <p>Query or change the empty-result-callbacks flag.</p>
    <p>The empty-result-callbacks flag affects the sqlite3_exec API only.
    Normally, when the empty-result-callbacks flag is cleared, the callback
    function supplied to the sqlite3_exec() call is not invoked for commands
    that return zero rows of data. When empty-result-callbacks is set in this
    situation, the callback function is invoked exactly once, with the third
    parameter set to 0 (NULL). This is to enable programs that use the
    sqlite3_exec() API to retrieve column-names even when a query returns no
    data.</p>
    <a name="pragma_encoding"></a>
  <li>
    <p><b>PRAGMA encoding;<br>
    PRAGMA encoding = &quot;UTF-8&quot;;<br>
    PRAGMA encoding = &quot;UTF-16&quot;;<br>
    PRAGMA encoding = &quot;UTF-16le&quot;;<br>
    PRAGMA encoding = &quot;UTF-16be&quot;;</b></p>
    <p>In first form, if the main database has already been created, then this
    pragma returns the text encoding used by the main database, one of
    &quot;UTF-8&quot;, &quot;UTF-16le&quot; (little-endian UTF-16 encoding) or
    &quot;UTF-16be&quot; (big-endian UTF-16 encoding). If the main database has
    not already been created, then the value returned is the text encoding that
    will be used to create the main database, if it is created by this session.</p>
    <p>The second and subsequent forms of this pragma are only useful if the
    main database has not already been created. In this case the pragma sets the
    encoding that the main database will be created with if it is created by
    this session. The string &quot;UTF-16&quot; is interpreted as &quot;UTF-16
    encoding using native machine byte-ordering&quot;. If the second and
    subsequent forms are used after the database file has already been created,
    they have no effect and are silently ignored.</p>
    <p>Once an encoding has been set for a database, it cannot be changed.</p>
    <p>Databases created by the ATTACH command always use the same encoding as
    the main database.</p>
    <a name="pragma_full_column_names"></a>
  <li>
    <p><b>PRAGMA full_column_names;<br>
    PRAGMA full_column_names = </b><i>0 | 1</i><b>;</b></p>
    <p>Query or change the full-column-names flag. This flag affects the way
    SQLite names columns of data returned by SELECT statements when the
    expression for the column is a table-column name or the wildcard
    &quot;*&quot;. Normally, such result columns are named
    &lt;table-name/alias&gt;&lt;column-name&gt; if the SELECT statement joins
    two or more tables together, or simply &lt;column-name&gt; if the SELECT
    statement queries a single table. When the full-column-names flag is set,
    such columns are always named &lt;table-name/alias&gt; &lt;column-name&gt;
    regardless of whether or not a join is performed.</p>
    <p>If both the short-column-names and full-column-names are set, then the
    behaviour associated with the full-column-names flag is exhibited.</p>
    <a name="pragma_fullfsync"></a>
  <li>
    <p><b>PRAGMA fullfsync<br>
    PRAGMA fullfsync = </b><i>0 | 1</i><b>;</b></p>
    <p>Query or change the fullfsync flag. This flag affects determines whether
    or not the F_FULLFSYNC syncing method is used on systems that support it.
    The default value is off. As of this writing (2006-02-10) only Mac OS X
    supports F_FULLFSYNC.</p>
    <a name="pragma_page_size"></a>
  <li>
    <p><b>PRAGMA page_size;<br>
    PRAGMA page_size = </b><i>bytes</i><b>;</b></p>
    <p>Query or set the page-size of the database. The page-size may only be set
    if the database has not yet been created. The page size must be a power of
    two greater than or equal to 512 and less than or equal to 8192. The upper
    limit may be modified by setting the value of macro SQLITE_MAX_PAGE_SIZE
    during compilation. The maximum upper bound is 32768.</p>
    <a name="pragma_read_uncommitted"></a>
  <li>
    <p><b>PRAGMA read_uncommitted;<br>
    PRAGMA read_uncommitted = </b><i>0 | 1</i><b>;</b></p>
    <p>Query, set, or clear READ UNCOMMITTED isolation. The default isolation
    level for SQLite is SERIALIZABLE. Any process or thread can select READ
    UNCOMMITTED isolation, but SERIALIZABLE will still be used except between
    connections that share a common page and schema cache. Cache sharing is
    enabled using the sqlite3_enable_shared_cache()
    API and is only available between connections running the same thread. Cache
    sharing is off by default.</p>
    <a name="pragma_short_column_names"></a>
  <li>
    <p><b>PRAGMA short_column_names;<br>
    PRAGMA short_column_names = </b><i>0 | 1</i><b>;</b></p>
    <p>Query or change the short-column-names flag. This flag affects the way
    SQLite names columns of data returned by SELECT statements when the
    expression for the column is a table-column name or the wildcard
    &quot;*&quot;. Normally, such result columns are named
    &lt;table-name/alias&gt;lt;column-name&gt; if the SELECT statement joins two
    or more tables together, or simply &lt;column-name&gt; if the SELECT
    statement queries a single table. When the short-column-names flag is set,
    such columns are always named &lt;column-name&gt; regardless of whether or
    not a join is performed.</p>
    <p>If both the short-column-names and full-column-names are set, then the
    behaviour associated with the full-column-names flag is exhibited.</p>
    <a name="pragma_synchronous"></a>
  <li>
    <p><b>PRAGMA synchronous;<br>
    PRAGMA synchronous = FULL; </b>(2)<b><br>
    PRAGMA synchronous = NORMAL; </b>(1)<b><br>
    PRAGMA synchronous = OFF; </b>(0)</p>
    <p>Query or change the setting of the &quot;synchronous&quot; flag. The
    first (query) form will return the setting as an integer. When synchronous
    is FULL (2), the SQLite database engine will pause at critical moments to
    make sure that data has actually been written to the disk surface before
    continuing. This ensures that if the operating system crashes or if there is
    a power failure, the database will be uncorrupted after rebooting. FULL
    synchronous is very safe, but it is also slow. When synchronous is NORMAL,
    the SQLite database engine will still pause at the most critical moments,
    but less often than in FULL mode. There is a very small (though non-zero)
    chance that a power failure at just the wrong time could corrupt the
    database in NORMAL mode. But in practice, you are more likely to suffer a
    catastrophic disk failure or some other unrecoverable hardware fault. With
    synchronous OFF (0), SQLite continues without pausing as soon as it has
    handed data off to the operating system. If the application running SQLite
    crashes, the data will be safe, but the database might become corrupted if
    the operating system crashes or the computer loses power before that data
    has been written to the disk surface. On the other hand, some operations are
    as much as 50 or more times faster with synchronous OFF.</p>
    <p>In SQLite version 2, the default value is NORMAL. For version 3, the
    default was changed to FULL.</p>
    <a name="pragma_temp_store"></a>
  <li>
    <p><b>PRAGMA temp_store;<br>
    PRAGMA temp_store = DEFAULT;</b> (0)<b><br>
    PRAGMA temp_store = FILE;</b> (1)<b><br>
    PRAGMA temp_store = MEMORY;</b> (2)</p>
    <p>Query or change the setting of the &quot;<b>temp_store</b>&quot;
    parameter. When temp_store is DEFAULT (0), the compile-time C preprocessor
    macro TEMP_STORE is used to determine where temporary tables and indices are
    stored. When temp_store is MEMORY (2) temporary tables and indices are kept
    in memory. When temp_store is FILE (1) temporary tables and indices are
    stored in a file. The temp_store_directory
    pragma can be used to specify the directory containing this file. <b>FILE</b>
    is specified. When the temp_store setting is changed, all existing temporary
    tables, indices, triggers, and views are immediately deleted.</p>
    <p>It is possible for the library compile-time C preprocessor symbol
    TEMP_STORE to override this pragma setting. The following table summarizes
    the interaction of the TEMP_STORE preprocessor macro and the temp_store
    pragma:</p>
    <blockquote>
      <table cellPadding="2" border="1">
        <tbody>
          <tr>
            <th vAlign="bottom">TEMP_STORE</th>
            <th vAlign="bottom">PRAGMA<br>
              temp_store</th>
            <th>Storage used for<br>
              TEMP tables and indices</th>
          </tr>
          <tr>
            <td align="middle">0</td>
            <td align="middle"><em>any</em></td>
            <td align="middle">file</td>
          </tr>
          <tr>
            <td align="middle">1</td>
            <td align="middle">0</td>
            <td align="middle">file</td>
          </tr>
          <tr>
            <td align="middle">1</td>
            <td align="middle">1</td>
            <td align="middle">file</td>
          </tr>
          <tr>
            <td align="middle">1</td>
            <td align="middle">2</td>
            <td align="middle">memory</td>
          </tr>
          <tr>
            <td align="middle">2</td>
            <td align="middle">0</td>
            <td align="middle">memory</td>
          </tr>
          <tr>
            <td align="middle">2</td>
            <td align="middle">1</td>
            <td align="middle">file</td>
          </tr>
          <tr>
            <td align="middle">2</td>
            <td align="middle">2</td>
            <td align="middle">memory</td>
          </tr>
          <tr>
            <td align="middle">3</td>
            <td align="middle"><em>any</em></td>
            <td align="middle">memory</td>
          </tr>
        </tbody>
      </table>
    </blockquote>
    &nbsp;
  <li>
    <p><b>PRAGMA temp_store_directory;<br>
    PRAGMA temp_store_directory = 'directory-name';</b></p>
    <p>Query or change the setting of the &quot;temp_store_directory&quot; - the
    directory where files used for storing temporary tables and indices are
    kept. This setting lasts for the duration of the current connection only and
    resets to its default value for each new connection opened.
    <p>When the temp_store_directory setting is changed, all existing temporary
    tables, indices, triggers, and viewers are immediately deleted. In practice,
    temp_store_directory should be set immediately after the database is opened.</p>
    <p>The value <i>directory-name</i> should be enclosed in single quotes. To
    revert the directory to the default, set the <i>directory-name</i> to an
    empty string, e.g., <i>PRAGMA temp_store_directory = ''</i>. An error is
    raised if <i>directory-name</i> is not found or is not writable.</p>
    <p>The default directory for temporary files depends on the OS. For
    Unix/Linux/OSX, the default is the is the first writable directory found in
    the list of: <b>/var/tmp, /usr/tmp, /tmp,</b> and <b><i>current-directory</i></b>.
    For Windows NT, the default directory is determined by Windows, generally <b>C:\Documents
    and Settings\<i>user-name</i>\Local Settings\Temp\</b>. Temporary files
    created by SQLite are unlinked immediately after opening, so that the
    operating system can automatically delete the files when the SQLite process
    exits. Thus, temporary files are not normally visible through <i>ls</i> or <i>dir</i>
    commands.</p>
  </li>
</ul>
<hr>
<a name="schema"></a>
<h1>Pragmas to query the database schema</h1>
<ul>
  <a name="pragma_database_list"></a>
  <li>
    <p><b>PRAGMA database_list;</b></p>
    <p>For each open database, invoke the callback function once with
    information about that database. Arguments include the index and the name
    the database was attached with. The first row will be for the main database.
    The second row will be for the database used to store temporary tables.</p>
    <a name="pragma_foreign_key_list"></a>
  <li>
    <p><b>PRAGMA foreign_key_list(</b><i>table-name</i><b>);</b></p>
    <p>For each foreign key that references a column in the argument table,
    invoke the callback function with information about that foreign key. The
    callback function will be invoked once for each column in each foreign key.</p>
    <a name="pragma_index_info"></a>
  <li>
    <p><b>PRAGMA index_info(</b><i>index-name</i><b>);</b></p>
    <p>For each column that the named index references, invoke the callback
    function once with information about that column, including the column name,
    and the column number.</p>
    <a name="pragma_index_list"></a>
  <li>
    <p><b>PRAGMA index_list(</b><i>table-name</i><b>);</b></p>
    <p>For each index on the named table, invoke the callback function once with
    information about that index. Arguments include the index name and a flag to
    indicate whether or not the index must be unique.</p>
    <a name="pragma_table_info"></a>
  <li>
    <p><b>PRAGMA table_info(</b><i>table-name</i><b>);</b></p>
    <p>For each column in the named table, invoke the callback function once
    with information about that column, including the column name, data type,
    whether or not the column can be NULL, and the default value for the column.</p>
  </li>
</ul>
<hr>
<a name="version"></a>
<h1>Pragmas to query/modify version values</h1>
<ul>
  <a name="pragma_schema_version"></a><a name="pragma_user_version"></a>
  <li>
    <p><b>PRAGMA [database.]schema_version;<br>
    PRAGMA [database.]schema_version = </b><i>integer </i><b>;<br>
    PRAGMA [database.]user_version;<br>
    PRAGMA [database.]user_version = </b><i>integer </i><b>;</b>
    <p>The pragmas schema_version and user_version are used to set or get the
    value of the schema-version and user-version, respectively. Both the
    schema-version and the user-version are 32-bit signed integers stored in the
    database header.</p>
    <p>The schema-version is usually only manipulated internally by SQLite. It
    is incremented by SQLite whenever the database schema is modified (by
    creating or dropping a table or index). The schema version is used by SQLite
    each time a query is executed to ensure that the internal cache of the
    schema used when compiling the SQL query matches the schema of the database
    against which the compiled query is actually executed. Subverting this
    mechanism by using &quot;PRAGMA schema_version&quot; to modify the
    schema-version is potentially dangerous and may lead to program crashes or
    database corruption. Use with caution!</p>
    <p>The user-version is not used internally by SQLite. It may be used by
    applications for any purpose.</p>
  </li>
</ul>
<hr>
<a name="debug"></a>
<h1>Pragmas to debug the library</h1>
<ul>
  <a name="pragma_integrity_check"></a>
  <li>
    <p><b>PRAGMA integrity_check;</b></p>
    <p>The command does an integrity check of the entire database. It looks for
    out-of-order records, missing pages, malformed records, and corrupt indices.
    If any problems are found, then a single string is returned which is a
    description of all problems. If everything is in order, &quot;ok&quot; is
    returned.</p>
    <a name="pragma_parser_trace"></a>
  <li>
    <p><b>PRAGMA parser_trace = ON; </b>(1)<b><br>
    PRAGMA parser_trace = OFF;</b> (0)</p>
    <p>Turn tracing of the SQL parser inside of the SQLite library on and off.
    This is used for debugging. This only works if the library is compiled
    without the NDEBUG macro.</p>
    <a name="pragma_vdbe_trace"></a>
  <li>
    <p><b>PRAGMA vdbe_trace = ON; </b>(1)<b><br>
    PRAGMA vdbe_trace = OFF;</b> (0)</p>
    <p>Turn tracing of the virtual database engine inside of the SQLite library
    on and off. This is used for debugging. See the <a href="http://www.sqlite.org/vdbe.html#trace">VDBE
    documentation</a> for more information.</p>
    <a name="pragma_vdbe_listing"></a>
  <li>
    <p><b>PRAGMA vdbe_listing = ON; </b>(1)<b><br>
    PRAGMA vdbe_listing = OFF;</b> (0)</p>
    <p>Turn listings of virtual machine programs on and off. With listing is on,
    the entire content of a program is printed just prior to beginning
    execution. This is like automatically executing an EXPLAIN prior to each
    statement. The statement executes normally after the listing is printed.
    This is used for debugging. See the <a href="http://www.sqlite.org/vdbe.html#trace">VDBE
    documentation</a> for more information.</p>
  </li>
</ul>
<h2><a name="REINDEX">REINDEX</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">REINDEX </font></b><i><font color="#ff3434">collation
        name</font></i></td>
    </tr>
  </tbody>
</table>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">REINDEX </font></b>[<i><font color="#ff3434">database-name</font></i><b><font color="#2c2cf0">
        <big>.</big></font></b>]<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">table/index-name</font></i></td>
    </tr>
  </tbody>
</table>
<p>The REINDEX command is used to delete and recreate indices from scratch. This
is useful when the definition of a collation sequence has changed.</p>
<p>In the first form, all indices in all attached databases that use the named
collation sequence are recreated. In the second form, if <i>[database-name.]table/index-name</i>
identifies a table, then all indices associated with the table are rebuilt. If
an index is identified, then only this specific index is deleted and recreated.</p>
<p>If no <i>database-name</i> is specified and there exists both a table or
index and a collation sequence of the specified name, then indices associated
with the collation sequence only are reconstructed. This ambiguity may be
dispelled by always specifying a <i>database-name</i> when reindexing a specific
table or index.</p>
<h2><a name="REPLACE">REPLACE</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">REPLACE INTO </font></b>[<i><font color="#ff3434">database-name</font></i><b><font color="#2c2cf0">
        <big>.</big></font></b>]<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">table-name</font></i><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0"><big>(</big> </font></b><i><font color="#ff3434">column-list</font></i><b><font color="#2c2cf0">
        <big>)</big></font></b>]<b><font color="#2c2cf0"> VALUES <big>(</big> </font></b><i><font color="#ff3434">value-list</font></i><b><font color="#2c2cf0">
        <big>)</big> </font></b><big>|</big><b><font color="#2c2cf0"><br>
        REPLACE INTO </font></b>[<i><font color="#ff3434">database-name</font></i><b><font color="#2c2cf0">
        <big>.</big></font></b>]<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">table-name</font></i><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0"><big>(</big> </font></b><i><font color="#ff3434">column-list</font></i><b><font color="#2c2cf0">
        <big>)</big></font></b>]<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">select-statement</font></i></td>
    </tr>
  </tbody>
</table>
<p>The REPLACE command is an alias for the &quot;INSERT OR REPLACE&quot; variant
of the INSERT command. This
alias is provided for compatibility with MySQL. See the INSERT
command documentation for additional information.</p>
<h2><a name="SELECT">SELECT</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">SELECT </font></b>[<b><font color="#2c2cf0">ALL
        </font></b><big>|</big><b><font color="#2c2cf0"> DISTINCT</font></b>]<b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">result</font></i><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0">FROM </font></b><i><font color="#ff3434">table-list</font></i>]<b><font color="#2c2cf0"><br>
        </font></b>[<b><font color="#2c2cf0">WHERE </font></b><i><font color="#ff3434">expr</font></i>]<b><font color="#2c2cf0"><br>
        </font></b>[<b><font color="#2c2cf0">GROUP BY </font></b><i><font color="#ff3434">expr-list</font></i>]<b><font color="#2c2cf0"><br>
        </font></b>[<b><font color="#2c2cf0">HAVING </font></b><i><font color="#ff3434">expr</font></i>]<b><font color="#2c2cf0"><br>
        </font></b>[<i><font color="#ff3434">compound-op</font></i><b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">select</font></i>]<big>*</big><b><font color="#2c2cf0"><br>
        </font></b>[<b><font color="#2c2cf0">ORDER BY </font></b><i><font color="#ff3434">sort-expr-list</font></i>]<b><font color="#2c2cf0"><br>
        </font></b>[<b><font color="#2c2cf0">LIMIT </font></b><i><font color="#ff3434">integer</font></i><b><font color="#2c2cf0">
        </font></b>[(<b><font color="#2c2cf0"> OFFSET </font></b><big>|</big><b><font color="#2c2cf0">
        <big>,</big> </font></b>)<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">integer</font></i>]]</td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">result</font></i>&nbsp;::=</td>
      <td><i><font color="#ff3434">result-column</font></i><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0"><big>,</big> </font></b><i><font color="#ff3434">result-column</font></i>]<big>*</big></td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">result-column</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0"><big>*</big> </font></b><big>|</big><b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">table-name</font></i><b><font color="#2c2cf0">
        <big>.</big> <big>*</big> </font></b><big>|</big><b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0"> </font></b>[<b><font color="#2c2cf0">AS</font></b>]<b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">string</font></i><b><font color="#2c2cf0">
        </font></b>]</td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">table-list</font></i>&nbsp;::=</td>
      <td><i><font color="#ff3434">table</font></i><b><font color="#2c2cf0"> </font></b>[<i><font color="#ff3434">join-op</font></i><b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">table</font></i><b><font color="#2c2cf0">
        </font></b><i><font color="#ff3434">join-args</font></i>]<big>*</big></td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">table</font></i>&nbsp;::=</td>
      <td><i><font color="#ff3434">table-name</font></i><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0">AS </font></b><i><font color="#ff3434">alias</font></i>]<b><font color="#2c2cf0">
        </font></b><big>|</big><b><font color="#2c2cf0"><br>
        <big>(</big> </font></b><i><font color="#ff3434">select</font></i><b><font color="#2c2cf0">
        <big>)</big> </font></b>[<b><font color="#2c2cf0">AS </font></b><i><font color="#ff3434">alias</font></i>]</td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">join-op</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0"><big>,</big> </font></b><big>|</big><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0">NATURAL</font></b>]<b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0">LEFT </font></b><big>|</big><b><font color="#2c2cf0">
        RIGHT </font></b><big>|</big><b><font color="#2c2cf0"> FULL</font></b>]<b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0">OUTER </font></b><big>|</big><b><font color="#2c2cf0">
        INNER </font></b><big>|</big><b><font color="#2c2cf0"> CROSS</font></b>]<b><font color="#2c2cf0">
        JOIN</font></b></td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">join-args</font></i>&nbsp;::=</td>
      <td>[<b><font color="#2c2cf0">ON </font></b><i><font color="#ff3434">expr</font></i>]<b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0">USING <big>(</big> </font></b><i><font color="#ff3434">id-list</font></i><b><font color="#2c2cf0">
        <big>)</big></font></b>]</td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sort-expr-list</font></i>&nbsp;::=</td>
      <td><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0"> </font></b>[<i><font color="#ff3434">sort-order</font></i>]<b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0"><big>,</big> </font></b><i><font color="#ff3434">expr</font></i><b><font color="#2c2cf0">
        </font></b>[<i><font color="#ff3434">sort-order</font></i>]]<big>*</big></td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sort-order</font></i>&nbsp;::=</td>
      <td>[<b><font color="#2c2cf0"> COLLATE </font></b><i><font color="#ff3434">collation-name</font></i><b><font color="#2c2cf0">
        </font></b>]<b><font color="#2c2cf0"> </font></b>[<b><font color="#2c2cf0">
        ASC </font></b><big>|</big><b><font color="#2c2cf0"> DESC </font></b>]</td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">compound_op</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">UNION </font></b><big>|</big><b><font color="#2c2cf0">
        UNION ALL </font></b><big>|</big><b><font color="#2c2cf0"> INTERSECT </font></b><big>|</big><b><font color="#2c2cf0">
        EXCEPT</font></b></td>
    </tr>
  </tbody>
</table>
<p>The SELECT statement is used to query the database. The result of a SELECT is
zero or more rows of data where each row has a fixed number of columns. The
number of columns in the result is specified by the expression list in between
the SELECT and FROM keywords. Any arbitrary expression can be used as a result.
If a result expression is <font color="#2c2cf0"><big>*</big></font> then all
columns of all tables are substituted for that one expression. If the expression
is the name of a table followed by <font color="#2c2cf0"><big>.*</big></font>
then the result is all columns in that one table.</p>
<p>The DISTINCT keyword causes a subset of result rows to be returned, in which
each result row is different. NULL values are not treated as distinct from each
other. The default behavior is that all result rows be returned, which can be
made explicit with the keyword ALL.</p>
<p>The query is executed against one or more tables specified after the FROM
keyword. If multiple tables names are separated by commas, then the query is
against the cross join of the various tables. The full SQL-92 join syntax can
also be used to specify joins. A sub-query in parentheses may be substituted for
any table name in the FROM clause. The entire FROM clause may be omitted, in
which case the result is a single row consisting of the values of the expression
list.</p>
<p>The WHERE clause can be used to limit the number of rows over which the query
operates.</p>
<p>The GROUP BY clauses causes one or more rows of the result to be combined
into a single row of output. This is especially useful when the result contains
aggregate functions. The expressions in the GROUP BY clause do <em>not</em> have
to be expressions that appear in the result. The HAVING clause is similar to
WHERE except that HAVING applies after grouping has occurred. The HAVING
expression may refer to values, even aggregate functions, that are not in the
result.</p>
<p>The ORDER BY clause causes the output rows to be sorted. The argument to
ORDER BY is a list of expressions that are used as the key for the sort. The
expressions do not have to be part of the result for a simple SELECT, but in a
compound SELECT each sort expression must exactly match one of the result
columns. Each sort expression may be optionally followed by a COLLATE keyword
and the name of a collating function used for ordering text and/or keywords ASC
or DESC to specify the sort order.</p>
<p>The LIMIT clause places an upper bound on the number of rows returned in the
result. A negative LIMIT indicates no upper bound. The optional OFFSET following
LIMIT specifies how many rows to skip at the beginning of the result set. In a
compound query, the LIMIT clause may only appear on the final SELECT statement.
The limit is applied to the entire query not to the individual SELECT statement
to which it is attached. Note that if the OFFSET keyword is used in the LIMIT
clause, then the limit is the first number and the offset is the second number.
If a comma is used instead of the OFFSET keyword, then the offset is the first
number and the limit is the second number. This seeming contradition is
intentional - it maximizes compatibility with legacy SQL database systems.</p>
<p>A compound SELECT is formed from two or more simple SELECTs connected by one
of the operators UNION, UNION ALL, INTERSECT, or EXCEPT. In a compound SELECT,
all the constituent SELECTs must specify the same number of result columns.
There may be only a single ORDER BY clause at the end of the compound SELECT.
The UNION and UNION ALL operators combine the results of the SELECTs to the
right and left into a single big table. The difference is that in UNION all
result rows are distinct where in UNION ALL there may be duplicates. The
INTERSECT operator takes the intersection of the results of the left and right
SELECTs. EXCEPT takes the result of left SELECT after removing the results of
the right SELECT. When three or more SELECTs are connected into a compound, they
group from left to right.</p>
<h2><a name="UPDATE">UPDATE</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">UPDATE </font></b>[<b><font color="#2c2cf0">
        OR </font></b><i><font color="#ff3434">conflict-algorithm</font></i><b><font color="#2c2cf0">
        </font></b>]<b><font color="#2c2cf0"> </font></b>[<i><font color="#ff3434">database-name</font></i><b><font color="#2c2cf0">
        <big>.</big></font></b>]<b><font color="#2c2cf0"> </font></b><i><font color="#ff3434">table-name</font></i><b><font color="#2c2cf0"><br>
        SET </font></b><i><font color="#ff3434">assignment</font></i><b><font color="#2c2cf0">
        </font></b>[<b><font color="#2c2cf0"><big>,</big> </font></b><i><font color="#ff3434">assignment</font></i>]<big>*</big><b><font color="#2c2cf0"><br>
        </font></b>[<b><font color="#2c2cf0">WHERE </font></b><i><font color="#ff3434">expr</font></i>]</td>
    </tr>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">assignment</font></i>&nbsp;::=</td>
      <td><i><font color="#ff3434">column-name</font></i><b><font color="#2c2cf0">
        <big>=</big> </font></b><i><font color="#ff3434">expr</font></i></td>
    </tr>
  </tbody>
</table>
<p>The UPDATE statement is used to change the value of columns in selected rows
of a table. Each assignment in an UPDATE specifies a column name to the left of
the equals sign and an arbitrary expression to the right. The expressions may
use the values of other columns. All expressions are evaluated before any
assignments are made. A WHERE clause can be used to restrict which rows are
updated.</p>
<p>The optional conflict-clause allows the specification of an alternative
constraint conflict resolution algorithm to use during this one command. See the
section titled ON CONFLICT
for additional information.</p>
<h2><a name="VACUUM">VACUUM</a></h2>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top" align="right"><i><font color="#ff3434">sql-statement</font></i>&nbsp;::=</td>
      <td><b><font color="#2c2cf0">VACUUM </font></b>[<i><font color="#ff3434">index-or-table-name</font></i>]</td>
    </tr>
  </tbody>
</table>
<p>The VACUUM command is an SQLite extension modeled after a similar command
found in PostgreSQL. If VACUUM is invoked with the name of a table or index then
it is suppose to clean up the named table or index. In version 1.0 of SQLite,
the VACUUM command would invoke <b>gdbm_reorganize()</b> to clean up the backend
database file.</p>
<p>VACUUM became a no-op when the GDBM backend was removed from SQLITE in
version 2.0.0. VACUUM was reimplemented in version 2.8.1. The index or table
name argument is now ignored.</p>
<p>When an object (table, index, or trigger) is dropped from the database, it
leaves behind empty space. This makes the database file larger than it needs to
be, but can speed up inserts. In time inserts and deletes can leave the database
file structure fragmented, which slows down disk access to the database
contents. The VACUUM command cleans the main database by copying its contents to
a temporary database file and reloading the original database file from the
copy. This eliminates free pages, aligns table data to be contiguous, and
otherwise cleans up the database file structure. It is not possible to perform
the same process on an attached database file.</p>
<p>This command will fail if there is an active transaction. This command has no
effect on an in-memory database.</p>
<p>As of SQLite version 3.1, an alternative to using the VACUUM command is
auto-vacuum mode, enabled using the auto_vacuum
pragma.</p>
<h2><a name="Datatypes">Datatypes</a> In SQLite Version 3</h2>
<h3>1. Storage Classes</h3>
<p>Version 2 of SQLite stores all column values as ASCII text. Version 3
enhances this by providing the ability to store integer and real numbers in a
more compact format and the capability to store BLOB data.</p>
<p>Each value stored in an SQLite database (or manipulated by the database
engine) has one of the following storage classes:</p>
<ul>
  <li>
    <p><b>NULL</b>. The value is a NULL value.</p>
  <li>
    <p><b>INTEGER</b>. The value is a signed integer, stored in 1, 2, 3, 4, 6,
    or 8 bytes depending on the magnitude of the value.</p>
  <li>
    <p><b>REAL</b>. The value is a floating point value, stored as an 8-byte
    IEEE floating point number.</p>
  <li>
    <p><b>TEXT</b>. The value is a text string, stored using the database
    encoding (UTF-8, UTF-16BE or UTF-16-LE).</p>
  <li>
    <p><b>BLOB</b>. The value is a blob of data, stored exactly as it was input.</p>
  </li>
</ul>
<p>As in SQLite version 2, any column in a version 3 database except an INTEGER
PRIMARY KEY may be used to store any type of value. The exception to this rule
is described below under 'Strict Affinity Mode'.</p>
<p>All values supplied to SQLite, whether as literals embedded in SQL statements
or values bound to pre-compiled SQL statements are assigned a storage class
before the SQL statement is executed. Under circumstances described below, the
database engine may convert values between numeric storage classes (INTEGER and
REAL) and TEXT during query execution.</p>
<p>Storage classes are initially assigned as follows:</p>
<ul>
  <li>
    <p>Values specified as literals as part of SQL statements are assigned
    storage class TEXT if they are enclosed by single or double quotes, INTEGER
    if the literal is specified as an unquoted number with no decimal point or
    exponent, REAL if the literal is an unquoted number with a decimal point or
    exponent and NULL if the value is a NULL. Literals with storage class BLOB
    are specified using the X'ABCD' notation.</p>
  <li>
    <p>Values supplied using the sqlite3_bind_* APIs are assigned the storage
    class that most closely matches the native type bound (i.e.
    sqlite3_bind_blob() binds a value with storage class BLOB).</p>
  </li>
</ul>
<p>The storage class of a value that is the result of an SQL scalar operator
depends on the outermost operator of the expression. User-defined functions may
return values with any storage class. It is not generally possible to determine
the storage class of the result of an expression at compile time.</p>
<a name="affinity">
<h3>2. Column Affinity</h3>
<p>In SQLite version 3, the type of a value is associated with the value itself,
not with the column or variable in which the value is stored. (This is sometimes
called </a>manifest
typing.) All other SQL databases engines that we are aware of use the more
restrictive system of static typing where the type is associated with the
container, not the value.</p>
<p>In order to maximize compatibility between SQLite and other database engines,
SQLite support the concept of &quot;type affinity&quot; on columns. The type
affinity of a column is the recommended type for data stored in that column. The
key here is that the type is recommended, not required. Any column can still
store any type of data, in theory. It is just that some columns, given the
choice, will prefer to use one storage class over another. The preferred storage
class for a column is called its &quot;affinity&quot;.</p>
<p>Each column in an SQLite 3 database is assigned one of the following type
affinities:</p>
<ul>
  <li>TEXT
  <li>NUMERIC
  <li>INTEGER
  <li>REAL
  <li>NONE</li>
</ul>
<p>A column with TEXT affinity stores all data using storage classes NULL, TEXT
or BLOB. If numerical data is inserted into a column with TEXT affinity it is
converted to text form before being stored.</p>
<p>A column with NUMERIC affinity may contain values using all five storage
classes. When text data is inserted into a NUMERIC column, an attempt is made to
convert it to an integer or real number before it is stored. If the conversion
is successful, then the value is stored using the INTEGER or REAL storage class.
If the conversion cannot be performed the value is stored using the TEXT storage
class. No attempt is made to convert NULL or blob values.</p>
<p>A column that uses INTEGER affinity behaves in the same way as a column with
NUMERIC affinity, except that if a real value with no floating point component
(or text value that converts to such) is inserted it is converted to an integer
and stored using the INTEGER storage class.</p>
<p>A column with REAL affinity behaves like a column with NUMERIC affinity
except that it forces integer values into floating point representation. (As an
optimization, integer values are stored on disk as integers in order to take up
less space and are only converted to floating point as the value is read out of
the table.)</p>
<p>A column with affinity NONE does not prefer one storage class over another.
It makes no attempt to coerce data before it is inserted.</p>
<h4>2.1 Determination Of Column Affinity</h4>
<p>The type affinity of a column is determined by the declared type of the
column, according to the following rules:</p>
<ol>
  <li>
    <p>If the datatype contains the string &quot;INT&quot; then it is assigned
    INTEGER affinity.</p>
  <li>
    <p>If the datatype of the column contains any of the strings
    &quot;CHAR&quot;, &quot;CLOB&quot;, or &quot;TEXT&quot; then that column has
    TEXT affinity. Notice that the type VARCHAR contains the string
    &quot;CHAR&quot; and is thus assigned TEXT affinity.</p>
  <li>
    <p>If the datatype for a column contains the string &quot;BLOB&quot; or if
    no datatype is specified then the column has affinity NONE.</p>
  <li>
    <p>If the datatype for a column contains any of the strings
    &quot;REAL&quot;, &quot;FLOA&quot;, or &quot;DOUB&quot; then the column has
    REAL affinity</p>
  <li>
    <p>Otherwise, the affinity is NUMERIC.</p>
  </li>
</ol>
<p>If a table is created using a &quot;CREATE TABLE &lt;table&gt; AS
SELECT...&quot; statement, then all columns have no datatype specified and they
are given no affinity.</p>
<h4>2.2 Column Affinity Example</h4>
<blockquote>
  <pre>CREATE TABLE t1(
    t  TEXT,
    nu NUMERIC, 
    i  INTEGER,
    no BLOB
);

-- Storage classes for the following row:
-- TEXT, REAL, INTEGER, TEXT
INSERT INTO t1 VALUES('500.0', '500.0', '500.0', '500.0');

-- Storage classes for the following row:
-- TEXT, REAL, INTEGER, REAL
INSERT INTO t1 VALUES(500.0, 500.0, 500.0, 500.0);
</pre>
</blockquote>
<h3>3. Comparison Expressions</h3>
<p>Like SQLite version 2, version 3 features the binary comparison operators
'=', '&lt;', '&lt;=', '&gt;=' and '!=', an operation to test for set membership,
'IN', and the ternary comparison operator 'BETWEEN'.</p>
<p>The results of a comparison depend on the storage classes of the two values
being compared, according to the following rules:</p>
<ul>
  <li>
    <p>A value with storage class NULL is considered less than any other value
    (including another value with storage class NULL).</p>
  <li>
    <p>An INTEGER or REAL value is less than any TEXT or BLOB value. When an
    INTEGER or REAL is compared to another INTEGER or REAL, a numerical
    comparison is performed.</p>
  <li>
    <p>A TEXT value is less than a BLOB value. When two TEXT values are
    compared, the C library function memcmp() is usually used to determine the
    result. However this can be overridden, as described under 'User-defined
    collation Sequences' below.</p>
  <li>
    <p>When two BLOB values are compared, the result is always determined using
    memcmp().</p>
  </li>
</ul>
<p>SQLite may attempt to convert values between the numeric storage classes
(INTEGER and REAL) and TEXT before performing a comparison. For binary
comparisons, this is done in the cases enumerated below. The term
&quot;expression&quot; used in the bullet points below means any SQL scalar
expression or literal other than a column value.</p>
<ul>
  <li>
    <p>When a column value is compared to the result of an expression, the
    affinity of the column is applied to the result of the expression before the
    comparison takes place.</p>
  <li>
    <p>When two column values are compared, if one column has INTEGER or NUMERIC
    affinity and the other does not, the NUMERIC affinity is applied to any
    values with storage class TEXT extracted from the non-NUMERIC column.</p>
  <li>
    <p>When the results of two expressions are compared, no conversions occur.
    The results are compared as is. If a string is compared to a number, the
    number will always be less than the string.</p>
  </li>
</ul>
<p>In SQLite, the expression &quot;a BETWEEN b AND c&quot; is equivalent to
&quot;a &gt;= b AND a &lt;= c&quot;, even if this means that different
affinities are applied to 'a' in each of the comparisons required to evaluate
the expression.</p>
<p>Expressions of the type &quot;a IN (SELECT b ....)&quot; are handled by the
three rules enumerated above for binary comparisons (e.g. in a similar manner to
&quot;a = b&quot;). For example if 'b' is a column value and 'a' is an
expression, then the affinity of 'b' is applied to 'a' before any comparisons
take place.</p>
<p>SQLite treats the expression &quot;a IN (x, y, z)&quot; as equivalent to
&quot;a = z OR a = y OR a = z&quot;.</p>
<h4>3.1 Comparison Example</h4>
<blockquote>
  <pre>CREATE TABLE t1(
    a TEXT,
    b NUMERIC,
    c BLOB
);

-- Storage classes for the following row:
-- TEXT, REAL, TEXT
INSERT INTO t1 VALUES('500', '500', '500');

-- 60 and 40 are converted to '60' and '40' and values are compared as TEXT.
SELECT a &lt; 60, a &lt; 40 FROM t1;
1|0

-- Comparisons are numeric. No conversions are required.
SELECT b &lt; 60, b &lt; 600 FROM t1;
0|1

-- Both 60 and 600 (storage class NUMERIC) are less than '500'
-- (storage class TEXT).
SELECT c &lt; 60, c &lt; 600 FROM t1;
0|0
</pre>
</blockquote>
<h3>4. Operators</h3>
<p>All mathematical operators (which is to say, all operators other than the
concatenation operator &quot;||&quot;) apply NUMERIC affinity to all operands
prior to being carried out. If one or both operands cannot be converted to
NUMERIC then the result of the operation is NULL.</p>
<p>For the concatenation operator, TEXT affinity is applied to both operands. If
either operand cannot be converted to TEXT (because it is NULL or a BLOB) then
the result of the concatenation is NULL.</p>
<h3>5. Sorting, Grouping and Compound SELECTs</h3>
<p>When values are sorted by an ORDER by clause, values with storage class NULL
come first, followed by INTEGER and REAL values interspersed in numeric order,
followed by TEXT values usually in memcmp() order, and finally BLOB values in
memcmp() order. No storage class conversions occur before the sort.</p>
<p>When grouping values with the GROUP BY clause values with different storage
classes are considered distinct, except for INTEGER and REAL values which are
considered equal if they are numerically equal. No affinities are applied to any
values as the result of a GROUP by clause.</p>
<p>The compound SELECT operators UNION, INTERSECT and EXCEPT perform implicit
comparisons between values. Before these comparisons are performed an affinity
may be applied to each value. The same affinity, if any, is applied to all
values that may be returned in a single column of the compound SELECT result
set. The affinity applied is the affinity of the column returned by the left
most component SELECTs that has a column value (and not some other kind of
expression) in that position. If for a given compound SELECT column none of the
component SELECTs return a column value, no affinity is applied to the values
from that column before they are compared.</p>
<h3>6. Other Affinity Modes</h3>
<p>The above sections describe the operation of the database engine in 'normal'
affinity mode. SQLite version 3 will feature two other affinity modes, as
follows:</p>
<ul>
  <li>
    <p><b>Strict affinity</b> mode. In this mode if a conversion between storage
    classes is ever required, the database engine returns an error and the
    current statement is rolled back.</p>
  <li>
    <p><b>No affinity</b> mode. In this mode no conversions between storage
    classes are ever performed. Comparisons between values of different storage
    classes (except for INTEGER and REAL) are always false.</p>
  </li>
</ul>
<a name="collation"></a>
<h3>7. User-defined Collation Sequences</h3>
<p>By default, when SQLite compares two text values, the result of the
comparison is determined using memcmp(), regardless of the encoding of the
string. SQLite v3 provides the ability for users to supply arbitrary comparison
functions, known as user-defined collation sequences, to be used instead of
memcmp().</p>
<p>Aside from the default collation sequence BINARY, implemented using memcmp(),
SQLite features one extra built-in collation sequences intended for testing
purposes, the NOCASE collation:</p>
<ul>
  <li><b>BINARY</b> - Compares string data using memcmp(), regardless of text
    encoding.
  <li><b>NOCASE</b> - The same as binary, except the 26 upper case characters
    used by the English language are folded to their lower case equivalents
    before the comparison is performed.</li>
</ul>
<h4>7.1 Assigning Collation Sequences from SQL</h4>
<p>Each column of each table has a default collation type. If a collation type
other than BINARY is required, a COLLATE clause is specified as part of the column
definition to define it.</p>
<p>Whenever two text values are compared by SQLite, a collation sequence is used
to determine the results of the comparison according to the following rules.
Sections 3 and 5 of this document describe the circumstances under which such a
comparison takes place.</p>
<p>For binary comparison operators (=, &lt;, &gt;, &lt;= and &gt;=) if either
operand is a column, then the default collation type of the column determines
the collation sequence to use for the comparison. If both operands are columns,
then the collation type for the left operand determines the collation sequence
used. If neither operand is a column, then the BINARY collation sequence is
used.</p>
<p>The expression &quot;x BETWEEN y and z&quot; is equivalent to &quot;x &gt;= y
AND x &lt;= z&quot;. The expression &quot;x IN (SELECT y ...)&quot; is handled
in the same way as the expression &quot;x = y&quot; for the purposes of
determining the collation sequence to use. The collation sequence used for
expressions of the form &quot;x IN (y, z ...)&quot; is the default collation
type of x if x is a column, or BINARY otherwise.</p>
<p>An ORDER BY clause that
is part of a SELECT statement may be assigned a collation sequence to be used
for the sort operation explicitly. In this case the explicit collation sequence
is always used. Otherwise, if the expression sorted by an ORDER BY clause is a
column, then the default collation type of the column is used to determine sort
order. If the expression is not a column, then the BINARY collation sequence is
used.</p>
<h4>7.2 Collation Sequences Example</h4>
<p>The examples below identify the collation sequences that would be used to
determine the results of text comparisons that may be performed by various SQL
statements. Note that a text comparison may not be required, and no collation
sequence used, in the case of numeric, blob or NULL values.</p>
<blockquote>
  <pre>CREATE TABLE t1(
    a,                 -- default collation type BINARY
    b COLLATE BINARY,  -- default collation type BINARY
    c COLLATE REVERSE, -- default collation type REVERSE
    d COLLATE NOCASE   -- default collation type NOCASE
);

-- Text comparison is performed using the BINARY collation sequence.
SELECT (a = b) FROM t1;

-- Text comparison is performed using the NOCASE collation sequence.
SELECT (d = a) FROM t1;

-- Text comparison is performed using the BINARY collation sequence.
SELECT (a = d) FROM t1;

-- Text comparison is performed using the REVERSE collation sequence.
SELECT ('abc' = c) FROM t1;

-- Text comparison is performed using the REVERSE collation sequence.
SELECT (c = 'abc') FROM t1;

-- Grouping is performed using the NOCASE collation sequence (i.e. values
-- 'abc' and 'ABC' are placed in the same group).
SELECT count(*) GROUP BY d FROM t1;

-- Grouping is performed using the BINARY collation sequence.
SELECT count(*) GROUP BY (d || '') FROM t1;

-- Sorting is performed using the REVERSE collation sequence.
SELECT * FROM t1 ORDER BY c;

-- Sorting is performed using the BINARY collation sequence.
SELECT * FROM t1 ORDER BY (c || '');

-- Sorting is performed using the NOCASE collation sequence.
SELECT * FROM t1 ORDER BY c COLLATE NOCASE;
</pre>
</blockquote>


</body>

</html>
