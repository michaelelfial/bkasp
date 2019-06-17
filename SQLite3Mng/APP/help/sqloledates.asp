<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<title>EULA</title>
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
<h2>OLE Date/Time SQL functions</h2>
<p>SQLite3 COM defines a set of Date/Time SQL functions which can be used in SQL
statements to deal with date and time values in a manner compatible and
convenient for COM programming. They allow you work with date/time values even
without support from the outside - for instance making conversion every time you
read/write values from to the database. You can move most of the date/time
related work to the SQL instead of doing it in the application code (VBScript,
JScript, VB etc.). This is often more productive and especially useful if
embedding date/time calculations in the SQL will offer more simplicity and
better performance. For instance if you need to filter some records based on
some date/time criteria that involves calculation of intervals for example,
instead of feeding the SQL with pre-calculated values it is better to do this in
the SQL statement in-place and thus benefit of the ability to calculate them
dynamically in the SQL over the current data.
<p><b>What is the OLE DATE type?</b> In short it is double precision floating
point value that counts the time from 30 December 1899 00:00:00. The positive
values mean date after this date, negative values mean date before that date.
Thus 0.0 will equal to 30 December 1899 00:00:00. Therefore when OLE DATE is
used to specify time only (without a date) it will convert to 30 December 1899
plus some hours, minutes seconds if it is converted to full date in a mistake.
The OLE DATE values act correctly in any expression because they are just real
numbers, they can be summed, subtracted and otherwise processed. The fact that
the time and the date are kept in a single value allows complex calculations
that involve date and time parts (and not only one of them) to be performed
easily. In contrast the Julian date supported by the most databases (SQLite
contains other set of functions for this) keeps the date and the time in
separate values and makes the expressions more difficult to write. The
additional benefit of using OLE DATE is that the values that are result of
expressions/statements can be directly passed to any script or a COM routine
that requires date/time value without any conversion.
<p><b>The functions:</b>
<blockquote>
  <p><b><font color="#ff0000">ParseOleDate</font></b> - Parses a date/time
  string in standard format and returns the double precision value that
  represents it. The format is:<br>
  YYYY-MM-DD hh:mm:ss. Example:<br>
  <br>
  <b>SELECT * FROM T WHERE Created &gt; ParseOleDate(&quot;2001-01-05&quot;);</b><br>
  will return the records with field &quot;Created&quot; containing date bigger
  than or equal to January, 05, 2001.<br>
  <b>SELECT * FROM T WHERE Created &gt; ParseOleDate(&quot;2001-01-05
  13:30&quot;);<br>
  </b>will return the records with field &quot;Created&quot; containing
  date/time bigger than or equal to January, 05, 2001 01:30 pm
  <p>You can pass date only or time only to ParseOleDate function. For instance
  all these:<br>
  ParseOleDate(&quot;2003-05-12&quot;)<br>
  ParseOleDate(&quot;05:15:00&quot;)<br>
  ParseOleDate(&quot;05:15&quot;)<br>
  ParseOleDate(&quot;2004-06-17 05:15:00&quot;)<br>
  will be ok. The seconds part of the time specification are optional.
  <p>Note that we are using this function in the samples below to make them more
  readable. In the real world you will pass to them arguments that are results
  from the query or an expression.&nbsp;
  <p><b><font color="#ff0000">OleDateTime</font></b> - Composes a date/time
  string in the standard format from a date value. For instance PleDateTime(0.0)
  will return &quot;1899-12-30 00:00:00&quot;. This function is needed when the
  date values are to be converted to human readable format after some
  calculations.
  <p><b><font color="#ff0000">OleDate</font></b> and <b><font color="#ff0000">OleTime</font></b>
  - Act as above but return only the date part of the string representation
  (OleDate) or only the time part (OleTime) of the date/time value passed as
  argument. For example:<br>
  <b>SELECT OleDate(ParseOleDate(&quot;2001-12-22 14:30:10&quot;));</b><br>
  &nbsp;will return &quot;2001-12-22&quot;<br>
  <b>SELECT OleTime(ParseOleDate(&quot;2001-12-22 14:30:10&quot;));</b><br>
  &nbsp;will return &quot;14:30:10&quot;<br>
  <br>
  <b><font color="#ff0000">OleDay</font></b>, <b><font color="#ff0000">OleMonth</font></b>,
  <b><font color="#ff0000">OleYear</font></b>, <font color="#ff0000"><b>OleHour</b></font>,
  <font color="#ff0000"><b>OleMinute</b></font>, <b><font color="#ff0000">OleSecond</font></b>
  and <b><font color="#ff0000">OleWeekDay</font></b> - all return numeric value
  that represents the corresponding part of the date value passed to them as
  argument. For example:<br>
  SELECT <b>OleDay(ParseOleDate(&quot;2001-12-22 14:30:10&quot;));<br>
  </b>&nbsp;will return <b>22</b> (22 - day of the month)<br>
  SELECT <b>OleMonth(ParseOleDate(&quot;2001-12-22 14:30:10&quot;));<br>
  </b>&nbsp;will return <b>12 </b>(12 month - December)<br>
  SELECT <b>OleYear(ParseOleDate(&quot;2001-12-22 14:30:10&quot;));<br>
  </b>&nbsp;will return <b>2001 </b>(the year specified in the date value)<br>
  SELECT <b>OleHour(ParseOleDate(&quot;2001-12-22 14:30:10&quot;));<br>
  </b>&nbsp;will return <b>14 </b>(2 p.m.)<br>
  SELECT <b>OleMinute(ParseOleDate(&quot;2001-12-22 14:30:10&quot;));<br>
  </b>&nbsp;will return <b>30 </b>(the minutes of the time contained in the
  value)<br>
  SELECT <b>OleSeconds(ParseOleDate(&quot;2001-12-22 14:30:10&quot;));<br>
  </b>&nbsp;will return <b>10 </b>(the seconds of the time contained in the
  value)<br>
  SELECT <b>OleWeekDay(ParseOleDate(&quot;2001-12-22 14:30:10&quot;));<br>
  </b>&nbsp;will return <b>7 </b>(Saturday)
  <p>For example if you want to query for records created on Mondays, assuming
  the Created field contains their creation time you can use query like this:<br>
  <b>SELECT * FROM T WHERE OleWeekDay(Created) = 7;</b>
  <p>The week days are numbered as follows: 1 - Sunday, 2 - Monday ... 7 -
  Saturday
  <p><b><font color="#ff0000">OleDateAdd</font></b> - This function provides way
  to calculate new date over existing one adding an interval to it. The full
  specification of the function is:<br>
  <b>OleDateAdd</b>(interval,count,date)<br>
  &nbsp; <b>interval</b> - is a character which can be: &quot;Y&quot; - years,
  &quot;M&quot; - months, &quot;D&quot; - days, &quot;h&quot; - hours,
  &quot;m&quot; - minutes, &quot;s&quot; - seconds<br>
  &nbsp; <b>count</b> - is a number specifying how many <b>interval</b>-s to
  add. Can be negative if you want to subtract from the date.<br>
  &nbsp; <b>date</b> - is the date value to which the interval will be added.<br>
  For example this can be useful to fetch the records created in past month:<br>
  <b>SELECT * FROM T WHERE Created &gt;
  OleDateAdd(&quot;M&quot;,-1,ParseOleDate(&quot;2004-12-14&quot;)) AND Created
  &lt; ParseOleDate(&quot;2004-12-14&quot;);<br>
  </b>Assuming that the string in the ParseOleDate is passed from outside.
  <p>OleDateDiff - This function calculates the difference between two date/time
  values in the interval-s specified. The full specification is:<br>
  OleDateDiff(interval,date1,date2)<br>
  &nbsp; <b>interval</b> - One character specifying the interval in which the
  difference will be calculated. Can be: &quot;Y&quot; - years, &quot;M&quot; -
  months, &quot;D&quot; - days, &quot;h&quot; - hours, &quot;m&quot; - minutes,
  &quot;s&quot; - seconds<br>
  &nbsp; <b>date1</b> - The first date<br>
  &nbsp; <b>date2</b> - The second date<br>
  If the date2 is bigger than date1 the result is positive (or 0) and negative
  (or 0) otherwise.<br>
  For example if you want to fetch the records created this month you can use
  query like this one:<br>
  <b>SELECT * FROM T WHERE
  OleDateDiff(&quot;M&quot;,Created,ParseOleDate(&quot;2004-12-14&quot;)) = 0;</b></p>
</blockquote>
<p><font color="#FF0000"><b>OleLocalTime</b><b>()</b></font>, <b><font color="#FF0000">OleSysTime()</font></b>
            - return the current local time (OleLocalTime) or the current UTC
            time (OleSysTime).
<p><b>Why OleLocalTime/OleSysTime functions are not recommended? </b>It is a common error to use
such function in the database. Note that between the composing the query in the
application and executing it in the database some time will pass. Although it is
insignificant in almost all the cases it may be enough to cross a border of day
month or even year. Thus when composing queries that deal with date/time the
current date/time should be obtained once, just before starting to compose the
query and set in it from outside to ensure all the expressions in the SQL
statement and the external application code will use the same value. Although
such functions may be useful in some cases the mistakes they may lead to
convinced us to not include them in order to make impossible mistakes like
above.&nbsp;

<p><b>A small sample ASP code</b>. These few lines of code Execute a query that
retrieves the records created during the previous year from a table
&quot;T&quot;, the field &quot;Created&quot; is assumed to contain the record
creation date.
<pre class="sample">Set db = Server.CreateObject(&quot;newObjects.sqlite.dbutf8&quot;)
Set su = Server.CreateObject(&quot;newObjects.utilctls.StringUtilities&quot;)
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
&lt;/TABLE&gt;</pre>


</body>

</html>
