# UL4ON

UL4ON is a lightweight text-based cross-platform object serialization format.

This Oracle package makes it possible to output UL4ON encoded data that can
then be parsed by any of the UL4ON implementations in Python, Java and
Javascript:

- [Python](https://github.com/LivingLogic/LivingLogic.Python.xist)
- [Java](https://github.com/LivingLogic/LivingLogic.Java.ul4)
- [Javascript](https://github.com/LivingLogic/LivingLogic.Javascript.ul4)


## Example

Define the following Oracle function:

```sql
create or replace function ul4on_test
return clob
as
	c_out clob;
begin
	ul4on_pkg.begindict(c_out);
		ul4on_pkg.keystr(c_out, 'firstname', 'John');
		ul4on_pkg.keystr(c_out, 'lastname', 'Doe');
		ul4on_pkg.keydate(c_out, 'birthday', to_date('2000-02-29', 'YYYY-MM-DD'));
		ul4on_pkg.key(c_out, 'emails');
		ul4on_pkg.beginlist(c_out);
			ul4on_pkg.str(c_out, 'john@example.org');
			ul4on_pkg.str(c_out, 'jdoe@example.net');
		ul4on_pkg.endlist(c_out);
	ul4on_pkg.enddict(c_out);
	return c_out;
end;
```

Then you can call this function and parse the result with the following Python code:

```python
import oracledb

from ll import ul4on

db = oracledb.connect(...)
c = db.cursor()
c.execute("select ul4on_test from dual")
dump = c.fetchone()[0].read()
data = ul4on.loads(dump)
print(data)
```

This will print the parsed data::

```python
{
	'firstname': 'John',
	'lastname': 'Doe',
	'birthday': datetime.date(2000, 2, 29),
	'emails': ['john@example.org', 'jdoe@example.net']
}
```

# vSQL

vSQL provides a way to build Oracle SQL queries safely and dynamically using
UL4 expressions. Instead of manually concatenating strings,	you can express
query logic with vSQL (a variant of UL4), which is then compiled into proper
SQL. This approach eliminates the risky parts of query construction,
effectively preventing SQL injection attacks, while offering the expressive
power of an ORM without the overhead.


# Documentation

The Python documentation contains more info about UL4ON.

- http://www.livinglogic.de/Python/ul4on/index.html


# Authors

* Walter Dörwald
