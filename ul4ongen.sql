create or replace type UL4ONGEN as object
(
	/******************************************************************************\
	UL4ON is a lightweight text-based crossplatform data interchange format.

	As the name suggests its purpose is to transport the object types supported by
	UL4. For more info about UL4 see `http://python.livinglogic.de/UL4.html` and for
	more info about UL4ON see `http://python.livinglogic.de/UL4ON.html`.

	The `ul4ongen` type provides a third way for creating an UL4ON dump in PL/SQL.
	(the other two being the packages `ul4on_pkg` and `ul4onbuffer_pkg`.

	Example:

	create or replace function user_ful4on
	return clob
	as
		c_out ul4ongen;
	begin
		c_out := ul4ongen();
		c_out.begindict();
			c_out.keyint('id', 42);
			c_out.keystr('name', 'admin');
			c_out.keydatetime('created', sysdate);
			c_out.key('groups');
			c_out.beginlist();
				c_out.str('admins');
				c_out.str('users');
			c_out.endlist();
		c_out.enddict();
		return c_out.value;
	end;
	\******************************************************************************/

	-- Private attributes: Don't access directly
	out_private clob,
	buffer_private varchar2(32000),

	-- Constructor
	constructor function ul4ongen return self as result,

	-- Methods for outputting various objects into the UL4ON dump
	member procedure none(self in out nocopy ul4ongen),
	member procedure bool(self in out nocopy ul4ongen, p_value in integer),
	member procedure int(self in out nocopy ul4ongen, p_value in integer),
	member procedure float_(self in out nocopy ul4ongen, p_value in number),
	member procedure color(self in out nocopy ul4ongen, p_red in integer, p_green in integer, p_blue in integer, p_alpha in integer),
	member procedure datetime(self in out nocopy ul4ongen, p_value date),
	member procedure datetime(self in out nocopy ul4ongen, p_value timestamp),
	member procedure datetime(self in out nocopy ul4ongen, p_value timestamp with time zone),
	member procedure timedelta(self in out nocopy ul4ongen, p_days integer := 0, p_seconds integer := 0, p_microseconds integer := 0),
	member procedure monthdelta(self in out nocopy ul4ongen, p_months integer := 0),
	member procedure slice(self in out nocopy ul4ongen, p_start integer := null, p_stop integer := null),
	member procedure str(self in out nocopy ul4ongen, p_value in varchar2),
	member procedure str(self in out nocopy ul4ongen, p_value in clob),

	-- Method for outputting a string key (simply calls str())
	member procedure key(self in out nocopy ul4ongen, p_key in varchar2),

	-- Methods for outputting key/value pairs inside a dictionary
	member procedure keynone(self in out nocopy ul4ongen, p_key in varchar2),
	member procedure keybool(self in out nocopy ul4ongen, p_key in varchar2, p_value in integer),
	member procedure keyint(self in out nocopy ul4ongen, p_key in varchar2, p_value in integer),
	member procedure keyfloat(self in out nocopy ul4ongen, p_key in varchar2, p_value in number),
	member procedure keycolor(self in out nocopy ul4ongen, p_key in varchar2, p_red in integer, p_green in integer, p_blue in integer, p_alpha in integer),
	member procedure keydatetime(self in out nocopy ul4ongen, p_key in varchar2, p_value date),
	member procedure keydatetime(self in out nocopy ul4ongen, p_key in varchar2, p_value timestamp),
	member procedure keydatetime(self in out nocopy ul4ongen, p_key in varchar2, p_value timestamp with time zone),
	member procedure keytimedelta(self in out nocopy ul4ongen, p_key in varchar2, p_days integer := 0, p_seconds integer := 0, p_microseconds integer := 0),
	member procedure keymonthdelta(self in out nocopy ul4ongen, p_key in varchar2, p_months integer := 0),
	member procedure keyslice(self in out nocopy ul4ongen, p_key in varchar2, p_start integer := null, p_stop integer := null),
	member procedure keystr(self in out nocopy ul4ongen, p_key in varchar2, p_value in varchar2),
	member procedure keystr(self in out nocopy ul4ongen, p_key in varchar2, p_value in clob),

	-- Begin and end a list object
	member procedure beginlist(self in out nocopy ul4ongen),
	member procedure endlist(self in out nocopy ul4ongen),

	-- Begin and end a set object
	member procedure beginset(self in out nocopy ul4ongen),
	member procedure endset(self in out nocopy ul4ongen),

	-- Begin and end a dict object
	member procedure begindict(self in out nocopy ul4ongen),
	member procedure enddict(self in out nocopy ul4ongen),

	-- Begin and end a custom object
	member procedure beginobject(self in out nocopy ul4ongen, p_type varchar2),
	member procedure endobject(self in out nocopy ul4ongen),

	-- Append another UL4ON dump
	member procedure append(self in out nocopy ul4ongen, p_value in clob),

	-- Return the current UL4ON dump (flushes some internal buffers)
	member function value(self in out nocopy ul4ongen) return clob,

	-- private functions/procedures: Don't call in client code
	member procedure init_private(self in out nocopy ul4ongen),
	member procedure write_private(self in out nocopy ul4ongen, p_value in varchar2),
	member procedure writeescapedstring_private(self in out nocopy ul4ongen, p_value in varchar2)
);

/

create or replace type body UL4ONGEN as
	constructor function ul4ongen
	return self as result
	as
	begin
		self.out_private := null;
		self.buffer_private := null;
		return;
	end;

	member procedure none(self in out nocopy ul4ongen)
	as
	begin
		init_private;
		write_private('n');
	end;

	member procedure bool(self in out nocopy ul4ongen, p_value integer)
	as
	begin
		init_private;
		if p_value is null then
			write_private('n');
		elsif p_value != 0 then
			write_private('bT');
		else
			write_private('bF');
		end if;
	end;

	member procedure int(self in out nocopy ul4ongen, p_value in integer)
	as
	begin
		init_private;
		if p_value is null then
			write_private('n');
		else
			write_private('i');
			write_private(to_char(p_value));
		end if;
	end;

	member procedure float_(self in out nocopy ul4ongen, p_value in number)
	as
	begin
		init_private;
		if p_value is null then
			write_private('n');
		else
			write_private('f');
			write_private(trim(to_char(p_value, '999999999999999999999999999999.9999999999')));
		end if;
	end;

	member procedure color(self in out nocopy ul4ongen, p_red in integer, p_green in integer, p_blue in integer, p_alpha in integer)
	as
	begin
		init_private;
		write_private('c');
		int(p_red);
		int(p_green);
		int(p_blue);
		int(p_alpha);
	end;

	member procedure timedelta(self in out nocopy ul4ongen, p_days integer := 0, p_seconds integer := 0, p_microseconds integer := 0)
	as
	begin
		init_private;
		write_private('t');
		int(p_days);
		int(p_seconds);
		int(p_microseconds);
	end;

	member procedure monthdelta(self in out nocopy ul4ongen, p_months integer := 0)
	as
	begin
		init_private;
		write_private('m');
		int(p_months);
	end;

	member procedure datetime(self in out nocopy ul4ongen, p_value date)
	as
	begin
		init_private;
		if p_value is null then
			write_private('n');
		else
			write_private('z');
			int(extract(year from p_value));
			int(extract(month from p_value));
			int(extract(day from p_value));
			int(to_number(to_char(p_value, 'HH24')));
			int(to_number(to_char(p_value, 'MI')));
			int(to_number(to_char(p_value, 'SS')));
			int(0);
		end if;
	end;

	member procedure datetime(self in out nocopy ul4ongen, p_value timestamp)
	as
	begin
		init_private;
		if p_value is null then
			write_private('n');
		else
			write_private('z');
			int(extract(year from p_value));
			int(extract(month from p_value));
			int(extract(day from p_value));
			int(extract(hour from p_value));
			int(extract(minute from p_value));
			int(trunc(extract(second from p_value)));
			int(to_number(to_char(p_value, 'FF6')));
		end if;
	end;

	member procedure datetime(self in out nocopy ul4ongen, p_value timestamp with time zone)
	as
	begin
		init_private;
		if p_value is null then
			write_private('n');
		else
			write_private('z');
			int(extract(year from p_value));
			int(extract(month from p_value));
			int(extract(day from p_value));
			int(extract(hour from p_value));
			int(extract(minute from p_value));
			int(trunc(extract(second from p_value)));
			int(to_number(to_char(p_value, 'FF6')));
		end if;
	end;

	member procedure slice(self in out nocopy ul4ongen, p_start integer := null, p_stop integer := null)
	as
	begin
		init_private;
		write_private('r');
		int(p_start);
		int(p_stop);
	end;

	member procedure str(self in out nocopy ul4ongen, p_value in varchar2)
	as
	begin
		init_private;
		if p_value is null then
			write_private('n');
		else
			write_private('s');
			write_private('"');
			writeescapedstring_private(p_value);
			write_private('"');
		end if;
	end;

	member procedure str(self in out nocopy ul4ongen, p_value in clob)
	as
	begin
		init_private;
		if p_value is null then
			write_private('n');
		else
			write_private('s');
			write_private('"');
			for i in 0 .. trunc((dbms_lob.getlength(p_value) - 1)/10000) loop
				writeescapedstring_private(dbms_lob.substr(p_value, 10000, i * 10000 + 1));
			end loop;
			write_private('"');
		end if;
	end;

	member procedure key(self in out nocopy ul4ongen, p_key in varchar2)
	as
	begin
		str(p_key);
	end;

	member procedure keynone(self in out nocopy ul4ongen, p_key in varchar2)
	as
	begin
		key(p_key);
		none();
	end;

	member procedure keybool(self in out nocopy ul4ongen, p_key in varchar2, p_value in integer)
	as
	begin
		key(p_key);
		bool(p_value);
	end;

	member procedure keyint(self in out nocopy ul4ongen, p_key in varchar2, p_value in integer)
	as
	begin
		key(p_key);
		int(p_value);
	end;

	member procedure keyfloat(self in out nocopy ul4ongen, p_key in varchar2, p_value in number)
	as
	begin
		key(p_key);
		float_(p_value);
	end;

	member procedure keydatetime(self in out nocopy ul4ongen, p_key in varchar2, p_value date)
	as
	begin
		key(p_key);
		datetime(p_value);
	end;

	member procedure keydatetime(self in out nocopy ul4ongen, p_key in varchar2, p_value timestamp)
	as
	begin
		key(p_key);
		datetime(p_value);
	end;

	member procedure keydatetime(self in out nocopy ul4ongen, p_key in varchar2, p_value timestamp with time zone)
	as
	begin
		key(p_key);
		datetime(p_value);
	end;

	member procedure keytimedelta(self in out nocopy ul4ongen, p_key in varchar2, p_days integer := 0, p_seconds integer := 0, p_microseconds integer := 0)
	as
	begin
		key(p_key);
		timedelta(p_days, p_seconds, p_microseconds);
	end;

	member procedure keymonthdelta(self in out nocopy ul4ongen, p_key in varchar2, p_months integer := 0)
	as
	begin
		key(p_key);
		monthdelta(p_months);
	end;

	member procedure keyslice(self in out nocopy ul4ongen, p_key in varchar2, p_start integer := null, p_stop integer := null)
	as
	begin
		key(p_key);
		slice(p_start, p_stop);
	end;

	member procedure keycolor(self in out nocopy ul4ongen, p_key in varchar2, p_red in integer, p_green in integer, p_blue in integer, p_alpha in integer)
	as
	begin
		key(p_key);
		color(p_red, p_green, p_blue, p_alpha);
	end;

	member procedure keystr(self in out nocopy ul4ongen, p_key in varchar2, p_value in varchar2)
	as
	begin
		key(p_key);
		str(p_value);
	end;

	member procedure keystr(self in out nocopy ul4ongen, p_key in varchar2, p_value in clob)
	as
	begin
		key(p_key);
		str(p_value);
	end;

	member procedure beginlist(self in out nocopy ul4ongen)
	as
	begin
		init_private;
		write_private('l');
	end;

	member procedure endlist(self in out nocopy ul4ongen)
	as
	begin
		init_private;
		write_private(']');
	end;

	member procedure beginset(self in out nocopy ul4ongen)
	as
	begin
		init_private;
		write_private('y');
	end;

	member procedure endset(self in out nocopy ul4ongen)
	as
	begin
		init_private;
		write_private('}');
	end;

	member procedure begindict(self in out nocopy ul4ongen)
	as
	begin
		init_private;
		write_private('d');
	end;

	member procedure enddict(self in out nocopy ul4ongen)
	as
	begin
		init_private;
		write_private('}');
	end;

	member procedure beginobject(self in out nocopy ul4ongen, p_type varchar2)
	as
	begin
		init_private;
		write_private('o');
		str(p_type);
	end;

	member procedure endobject(self in out nocopy ul4ongen)
	as
	begin
		init_private;
		write_private(')');
	end;

	member procedure append(self in out nocopy ul4ongen, p_value in clob)
	as
	begin
		init_private;
		if p_value is not null and dbms_lob.getlength(p_value) != 0 then
			dbms_lob.append(out_private, p_value);
		end if;
	end;

	member function value(self in out nocopy ul4ongen)
	return clob
	as
	begin
		if buffer_private is not null then
			dbms_lob.writeappend(out_private, length(buffer_private), buffer_private);
			buffer_private := null;
		end if;
		return out_private;
	end;

	member procedure init_private(self in out nocopy ul4ongen)
	as
	begin
		if out_private is null then
			dbms_lob.createtemporary(self.out_private, true);
		else
			write_private(' ');
		end if;
	end;

	member procedure write_private(self in out nocopy ul4ongen, p_value in varchar2)
	as
	begin
		if buffer_private is not null and length(buffer_private) + length(p_value) >= 32000 then
			dbms_lob.writeappend(out_private, length(buffer_private), buffer_private);
			dbms_lob.writeappend(out_private, length(p_value), p_value);
			buffer_private := null;
		else
			buffer_private := buffer_private || p_value;
		end if;
	end;

	member procedure writeescapedstring_private(self in out nocopy ul4ongen, p_value in varchar2)
	as
		v_buf varchar2(32000);
	begin
		v_buf := p_value;
		v_buf := replace(v_buf, '\', '\\');
		v_buf := asciistr(v_buf);

		-- make proper unicode escapes
		v_buf := replace(v_buf, '\', '\u');

		-- revert backslash escape
		v_buf := replace(v_buf, '\u005C', '\');

		-- escape control characters
		for i in 1 .. 7 loop
			v_buf := replace(v_buf, chr(i), '\x' || replace(substr(to_char(ascii(chr(i)), 'xx'), 2, 2), ' ', '0'));
		end loop;
		v_buf := replace(v_buf, chr(8), '\b');
		v_buf := replace(v_buf, chr(9), '\t');
		v_buf := replace(v_buf, chr(10), '\n');
		v_buf := replace(v_buf, chr(11), '\x' || replace(substr(to_char(ascii(11), 'xx'), 2, 2), ' ', '0'));
		v_buf := replace(v_buf, chr(12), '\f');
		v_buf := replace(v_buf, chr(13), '\r');
		for i in 128 .. 159 loop
			v_buf := replace(v_buf, chr(i), '\x' || replace(substr(to_char(ascii(chr(i)), 'xx'), 2, 2), ' ', '0'));
		end loop;
		-- escape quote characters
		v_buf := replace(v_buf, '"', '\"');

		write_private(v_buf);
	end;
end;

/

