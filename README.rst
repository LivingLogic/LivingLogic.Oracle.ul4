UL4ON
=====

UL4ON is a lightweight text-based cross-platform object serialization format.


Oracle
======

This Oracle package makes it possible to output UL4ON encoded data that can
then be parsed by any of the UL4ON implementations in Python_, Java_ and
Javascript_.

.. _Python: https://github.com/LivingLogic/LivingLogic.Python.xist
.. _Java: https://github.com/LivingLogic/LivingLogic.Java.ul4
.. _Javascript: https://github.com/LivingLogic/LivingLogic.Javascript.ul4


Example
=======

Define the following Oracle function::

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

Then you can call this function and parse the result with the following Python code::

	import cx_Oracle

	from ll import ul4on

	db = cx_Oracle.connect(...)
	c = db.cursor()
	c.execute("select ul4on_test from dual")
	dump = c.fetchone()[0].read()
	data = ul4on.loads(dump)
	print(data)

This will print the parsed data::

	{
		'firstname': 'John',
		'lastname': 'Doe',
		'birthday': datetime.date(2000, 2, 29),
		'emails': ['john@example.org', 'jdoe@example.net']
	}


Documentation
=============

The Python documentation contains more info about UL4ON_.

.. _UL4ON: http://www.livinglogic.de/Python/ul4on/index.html


Authors
=======

* Walter Dörwald
