create or replace package UL4ONBLOBBUFFER_PKG
as
	/******************************************************************************\
	UL4ON is a lightweight text-based crossplatform data interchange format.

	As the name suggests its purpose is to transport the object types supported by
	UL4. For more info about UL4 see `http://python.livinglogic.de/UL4.html` and for
	more info about UL4ON see `http://python.livinglogic.de/UL4ON.html`.

	`ul4onblobbuffer_pkg` can be used for creating UL4ON dumps iteratively. For
	example creating an UL4ON dump of a list with two strings can be done like this::

		begin
			ul4onblobbuffer_pkg.init();
			ul4onblobbuffer_pkg.beginlist();
				ul4onblobbuffer_pkg.str('foo');
				ul4onblobbuffer_pkg.str('bar');
			ul4onblobbuffer_pkg.endlist();
			ul4onblobbuffer_pkg.flush();
		end;

	The BLOB `ul4onblobbuffer_pkg.output` generated by this will contain
	`l s"foo" s"bar" ]`. Any implementation of UL4ON will be able to deserialize
	this dump back into the original string list.
	\******************************************************************************/

	-- The `BLOB` where the UL4ON dump is collected
	output blob;

	-- Initialized some internal buffers and variables (must be called before any other procedures)
	procedure init;

	-- Flush all internal buffers (must be call before the `BLOB` value `output` is used/returned)
	procedure flush;

	-- Methods for outputting various objects into the UL4ON dump
	procedure none;
	procedure bool(p_value in integer);
	procedure int(p_value in integer);
	procedure float(p_value in number);
	procedure color(p_red in integer, p_green in integer, p_blue in integer, p_alpha in integer);
	procedure date_(p_value date);
	procedure datetime(p_value date);
	procedure datetime(p_value timestamp);
	procedure timedelta(p_days integer := 0, p_seconds integer := 0, p_microseconds integer := 0);
	procedure monthdelta(p_months integer := 0);
	procedure slice(p_start integer := null, p_stop integer := null);
	procedure str(p_value in varchar2, p_backref boolean := false);
	procedure str(p_value in clob);
	procedure template(
		p_name varchar2,
		p_source in clob,
		p_signature varchar2 := null,
		p_whitespace varchar2 := 'keep',
		p_startdelim varchar2 := '<?',
		p_enddelim varchar2 := '?>'
	);

	-- Method for outputting a string key (simply calls `str()` with `p_backref=true`)
	procedure key(p_key in varchar2);

	-- Methods for outputting key/value pairs inside a dictionary
	procedure keynone(p_key in varchar2);
	procedure keybool(p_key in varchar2, p_value in integer);
	procedure keyint(p_key in varchar2, p_value in integer);
	procedure keyfloat(p_key in varchar2, p_value in number);
	procedure keycolor(p_key in varchar2, p_red in integer, p_green in integer, p_blue in integer, p_alpha in integer);
	procedure keydatetime(p_key in varchar2, p_value date);
	procedure keydatetime(p_key in varchar2, p_value timestamp);
	procedure keytimedelta(p_key in varchar2, p_days integer := 0, p_seconds integer := 0, p_microseconds integer := 0);
	procedure keymonthdelta(p_key in varchar2, p_months integer := 0);
	procedure keyslice(p_key in varchar2, p_start integer := null, p_stop integer := null);
	procedure keystr(p_key in varchar2, p_value in varchar2, p_backref boolean := false);
	procedure keystr(p_key in varchar2, p_value in clob);

	-- Begin and end a list object
	procedure beginlist;
	procedure endlist;

	-- Begin and end a set object
	procedure beginset;
	procedure endset;

	-- Begin and end a dict object
	procedure begindict(p_ordered integer := 0);
	procedure enddict;

	-- Begin, test for and end a custom object
	procedure beginobject(p_type varchar2);
	function needobject(p_key in varchar2, p_id in varchar2) return boolean;
	procedure beginobject(p_type in varchar2, p_key in varchar2, p_id in varchar2);
	procedure endobject;

	-- Return the current size of the output blob
	function outputsize return integer;
end;

/

create or replace package body UL4ONBLOBBUFFER_PKG
as
	-- FIXME: The key size can be reduced once we switch to prefixed keys
	-- and get rid of the current logic for lookup items.
	type backrefregistry is table of integer index by varchar2(1000 char);
	registry backrefregistry;
	buffer varchar2(32767 char);
	buffer_len integer;

	procedure init
	as
	begin
		output := null;
		registry.delete;
		buffer := null;
		buffer_len := 0;
	end;

	procedure flush
	as
	begin
		dbms_lob.append(output, utl_raw.cast_to_raw(buffer));
		buffer := null;
		buffer_len := 0;
	end;

	procedure write(p_value in varchar2)
	as
		v_addlen integer;
	begin
		v_addlen := lengthb(p_value);
		if buffer_len + v_addlen >= 32767 then
			flush();
		end if;
		buffer := buffer || p_value;
		buffer_len := buffer_len + v_addlen;
	end;

	procedure pad
	as
	begin
		if output is null then
			dbms_lob.createtemporary(output, true);
		else
			write(' ');
		end if;
	end;

	procedure none
	as
	begin
		pad();
		write('n');
	end;

	procedure bool(p_value in integer)
	as
	begin
		pad();
		if p_value is null then
			write('n');
		elsif p_value != 0 then
			write('bT');
		else
			write('bF');
		end if;
	end;

	procedure int(p_value in integer)
	as
	begin
		pad();
		if p_value is null then
			write('n');
		else
			write('i');
			write(to_char(p_value));
		end if;
	end;

	procedure float(p_value in number)
	as
	begin
		pad();
		if p_value is null then
			write('n');
		else
			write('f');
			write(trim(to_char(p_value, '999999999999999999999999999999.9999999999')));
		end if;
	end;

	procedure color(p_red in integer, p_green in integer, p_blue in integer, p_alpha in integer)
	as
	begin
		pad();
		write('c');
		int(p_red);
		int(p_green);
		int(p_blue);
		int(p_alpha);
	end;

	procedure timedelta(p_days integer := 0, p_seconds integer := 0, p_microseconds integer := 0)
	as
	begin
		pad();
		write('t');
		int(p_days);
		int(p_seconds);
		int(p_microseconds);
	end;

	procedure monthdelta(p_months integer := 0)
	as
	begin
		pad();
		write('m');
		int(p_months);
	end;

	procedure date_(p_value date)
	as
	begin
		pad();
		if p_value is null then
			write('n');
		else
			write('x');
			int(extract(year from p_value));
			int(extract(month from p_value));
			int(extract(day from p_value));
		end if;
	end;

	procedure datetime(p_value date)
	as
	begin
		pad();
		if p_value is null then
			write('n');
		else
			write('z');
			int(extract(year from p_value));
			int(extract(month from p_value));
			int(extract(day from p_value));
			int(to_number(to_char(p_value, 'HH24')));
			int(to_number(to_char(p_value, 'MI')));
			int(to_number(to_char(p_value, 'SS')));
			int(0);
		end if;
	end;

	procedure datetime(p_value timestamp)
	as
	begin
		pad();
		if p_value is null then
			write('n');
		else
			write('z');
			int(extract(year from p_value));
			int(extract(month from p_value));
			int(extract(day from p_value));
			int(extract(hour from p_value));
			int(extract(minute from p_value));
			int(trunc(extract(second from p_value)));
			int(to_number(to_char(p_value, 'FF6')));
		end if;
	end;

	procedure slice(p_start integer := null, p_stop integer := null)
	as
	begin
		pad();
		write('r');
		int(p_start);
		int(p_stop);
	end;

	procedure writeul4onstr(p_value in varchar2)
	as
	begin
		if output is null then
			dbms_lob.createtemporary(output, true);
		end if;
		if length(p_value) <= 16000 then
			write(replace(replace(p_value, '\', '\\'), '"', '\"'));
		else
			for i in 0 .. trunc((length(p_value) - 1)/16000) loop
				write(replace(replace(substr(p_value, i * 16000 + 1, 16000), '\', '\\'), '"', '\"'));
			end loop;
		end if;
	end;

	procedure str(p_value in varchar2, p_backref boolean := false)
	as
		v_regkey varchar2(300 char);
	begin
		pad();
		if p_value is null then
			write('n');
		elsif p_backref and length(p_value) < 300-4 then -- the key must fit in the backrefregistry, so we refuse to store long strings in the registry
			v_regkey := 'str:' || p_value;
			if registry.exists(v_regkey) then
				write('^');
				write(to_char(registry(v_regkey)));
			else
				write('S"');
				writeul4onstr(p_value);
				write('"');
				registry(v_regkey) := registry.count;
			end if;
		else
			write('s"');
			writeul4onstr(p_value);
			write('"');
		end if;
	end;

	procedure str(p_value in clob)
	as
		v_buf varchar2(16000 char);
	begin
		pad();
		if p_value is null then
			write('n');
		else
			write('s"');

			for i in 0 .. trunc((dbms_lob.getlength(p_value) - 1 )/16000) loop
				v_buf := dbms_lob.substr(p_value, 16000, i * 16000 + 1);
				writeul4onstr(v_buf);
			end loop;

			write('"');
		end if;
	end;

	procedure template(
		p_name varchar2,
		p_source in clob,
		p_signature varchar2 := null,
		p_whitespace varchar2 := 'keep',
		p_startdelim varchar2 := '<?',
		p_enddelim varchar2 := '?>'
	)
	as
	begin
		beginobject('de.livinglogic.ul4.template');
			none(); -- The version ``None`` means that the template must be compiled from source
			str(p_name);
			str(p_source);
			str(p_signature);
			str(p_whitespace);
			str(p_startdelim);
			str(p_enddelim);
		endobject();
	end;

	procedure key(p_key in varchar2)
	as
	begin
		str(p_key, true);
	end;

	procedure keynone(p_key in varchar2)
	as
	begin
		key(p_key);
		none();
	end;

	procedure keybool(p_key in varchar2, p_value in integer)
	as
	begin
		key(p_key);
		bool(p_value);
	end;

	procedure keyint(p_key in varchar2, p_value in integer)
	as
	begin
		key(p_key);
		int(p_value);
	end;

	procedure keyfloat(p_key in varchar2, p_value in number)
	as
	begin
		key(p_key);
		float(p_value);
	end;

	procedure keydatetime(p_key in varchar2, p_value date)
	as
	begin
		key(p_key);
		datetime(p_value);
	end;

	procedure keydatetime(p_key in varchar2, p_value timestamp)
	as
	begin
		key(p_key);
		datetime(p_value);
	end;

	procedure keytimedelta(p_key in varchar2, p_days integer := 0, p_seconds integer := 0, p_microseconds integer := 0)
	as
	begin
		key(p_key);
		timedelta(p_days, p_seconds, p_microseconds);
	end;

	procedure keymonthdelta(p_key in varchar2, p_months integer := 0)
	as
	begin
		key(p_key);
		monthdelta(p_months);
	end;

	procedure keyslice(p_key in varchar2, p_start integer := null, p_stop integer := null)
	as
	begin
		key(p_key);
		slice(p_start, p_stop);
	end;

	procedure keycolor(p_key in varchar2, p_red in integer, p_green in integer, p_blue in integer, p_alpha in integer)
	as
	begin
		key(p_key);
		color(p_red, p_green, p_blue, p_alpha);
	end;

	procedure keystr(p_key in varchar2, p_value in varchar2, p_backref boolean := false)
	as
	begin
		key(p_key);
		str(p_value, p_backref);
	end;

	procedure keystr(p_key in varchar2, p_value in clob)
	as
	begin
		key(p_key);
		str(p_value);
	end;

	procedure beginlist
	as
	begin
		pad();
		write('l');
	end;

	procedure endlist
	as
	begin
		pad();
		write(']');
	end;

	procedure beginset
	as
	begin
		pad();
		write('y');
	end;

	procedure endset
	as
	begin
		pad();
		write('}');
	end;

	procedure begindict(p_ordered integer := 0)
	as
	begin
		pad();
		write(case when p_ordered = 0 then 'd' else 'e' end);
	end;

	procedure enddict
	as
	begin
		pad();
		write('}');
	end;

	procedure beginobject(p_type varchar2)
	as
	begin
		pad();
		write('o');
		str(p_type);
	end;

	function needobject(p_key in varchar2, p_id in varchar2)
	return boolean
	as
	begin
		if p_id is null then
			none();
			return false;
		else
			if registry.exists(p_key || ':' || p_id) then
				pad();
				write('^');
				write(to_char(registry(p_key || ':' || p_id)));
				return false;
			else
				return true;
			end if;
		end if;
	end;

	procedure beginobject(p_type in varchar2, p_key in varchar2, p_id in varchar2)
	as
	begin
		pad();
		write('P');
		registry(p_key || ':' || p_id) := registry.count;
		str(p_type, true);
		str(p_id, true);
	end;

	procedure endobject
	as
	begin
		pad();
		write(')');
	end;

	function outputsize
	return integer
	as
	begin
		if output is null then
			return 0;
		else
			return length(output);
		end if;
	end;
end;

/

