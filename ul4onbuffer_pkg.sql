create or replace package UL4ONBUFFER_PKG
as
	/******************************************************************************\
	UL4ON is a lightweight text-based crossplatform data interchange format.

	As the name suggests its purpose is to transport the object types supported by
	UL4. For more info about UL4 see `http://python.livinglogic.de/UL4.html` and for
	more info about UL4ON see `http://python.livinglogic.de/UL4ON.html`.
	\******************************************************************************/

	-- Initialized some internal buffers and variables (must be called before any other procedures)
	procedure init(c_out in out nocopy clob);

	-- Flush all internal buffers (must be call before the CLOB value `c_out` is used/returned)
	procedure flush(c_out in out nocopy clob);

	-- Methods for outputting various objects into the UL4ON dump
	procedure none(c_out in out nocopy clob);
	procedure bool(c_out in out nocopy clob, p_value in integer);
	procedure int(c_out in out nocopy clob, p_value in integer);
	procedure float(c_out in out nocopy clob, p_value in number);
	procedure color(c_out in out nocopy clob, p_red in integer, p_green in integer, p_blue in integer, p_alpha in integer);
	procedure date_(c_out in out nocopy clob, p_value date);
	procedure date_(c_out in out nocopy clob, p_value timestamp);
	procedure datetime(c_out in out nocopy clob, p_value date);
	procedure datetime(c_out in out nocopy clob, p_value timestamp);
	procedure timedelta(c_out in out nocopy clob, p_days integer := 0, p_seconds integer := 0, p_microseconds integer := 0);
	procedure monthdelta(c_out in out nocopy clob, p_months integer := 0);
	procedure slice(c_out in out nocopy clob, p_start integer := null, p_stop integer := null);
	procedure str(c_out in out nocopy clob, p_value in varchar2, p_backref boolean := false);
	procedure str(c_out in out nocopy clob, p_value in clob);
	procedure template(
		c_out in out nocopy clob,
		p_name varchar2,
		p_source in clob,
		p_signature varchar2 := null,
		p_whitespace varchar2 := 'keep',
		p_startdelim varchar2 := '<?',
		p_enddelim varchar2 := '?>'
	);

	-- Method for outputting a string key (simply calls str())
	procedure key(c_out in out nocopy clob, p_key in varchar2);

	-- Methods for outputting key/value pairs inside a dictionary
	procedure keynone(c_out in out nocopy clob, p_key in varchar2);
	procedure keybool(c_out in out nocopy clob, p_key in varchar2, p_value in integer);
	procedure keyint(c_out in out nocopy clob, p_key in varchar2, p_value in integer);
	procedure keyfloat(c_out in out nocopy clob, p_key in varchar2, p_value in number);
	procedure keycolor(c_out in out nocopy clob, p_key in varchar2, p_red in integer, p_green in integer, p_blue in integer, p_alpha in integer);
	procedure keydate(c_out in out nocopy clob, p_key in varchar2, p_value date);
	procedure keydate(c_out in out nocopy clob, p_key in varchar2, p_value timestamp);
	procedure keydatetime(c_out in out nocopy clob, p_key in varchar2, p_value date);
	procedure keydatetime(c_out in out nocopy clob, p_key in varchar2, p_value timestamp);
	procedure keytimedelta(c_out in out nocopy clob, p_key in varchar2, p_days integer := 0, p_seconds integer := 0, p_microseconds integer := 0);
	procedure keymonthdelta(c_out in out nocopy clob, p_key in varchar2, p_months integer := 0);
	procedure keyslice(c_out in out nocopy clob, p_key in varchar2, p_start integer := null, p_stop integer := null);
	procedure keystr(c_out in out nocopy clob, p_key in varchar2, p_value in varchar2, p_backref boolean := false);
	procedure keystr(c_out in out nocopy clob, p_key in varchar2, p_value in clob);

	-- Begin and end a list object
	procedure beginlist(c_out in out nocopy clob);
	procedure endlist(c_out in out nocopy clob);

	-- Begin and end a set object
	procedure beginset(c_out in out nocopy clob);
	procedure endset(c_out in out nocopy clob);

	-- Begin and end a dict object
	procedure begindict(c_out in out nocopy clob, p_ordered integer := 0);
	procedure enddict(c_out in out nocopy clob);

	-- Begin and end a custom object
	procedure beginobject(c_out in out nocopy clob, p_type varchar2);
	function beginobject(c_out in out nocopy clob, p_type in varchar2, p_id in varchar2) return boolean;
	procedure endobject(c_out in out nocopy clob);
end;

/

create or replace package body UL4ONBUFFER_PKG
as
	type backrefregistry is table of integer index by varchar2(300);
	registry backrefregistry;
	buffer varchar2(32000);
	buffer_len integer;

	procedure init(c_out in out nocopy clob)
	as
	begin
		registry.delete;
		buffer := null;
		buffer_len := 0;
	end;

	procedure flush(c_out in out nocopy clob)
	as
	begin
		dbms_lob.writeappend(c_out, length(buffer), buffer);
		buffer := null;
		buffer_len := 0;
	end;

	procedure write(c_out in out nocopy clob, p_value in varchar2)
	as
		v_addlen integer;
	begin
		v_addlen := length(p_value);
		if buffer_len + v_addlen >= 32000 then
			flush(c_out);
		end if;
		buffer := buffer || p_value;
		buffer_len := buffer_len + v_addlen;
	end;

	procedure none(c_out in out nocopy clob)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		write(c_out, 'n');
	end;

	procedure bool(c_out in out nocopy clob, p_value in integer)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		if p_value is null then
			write(c_out, 'n');
		elsif p_value != 0 then
			write(c_out, 'bT');
		else
			write(c_out, 'bF');
		end if;
	end;

	procedure int(c_out in out nocopy clob, p_value in integer)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		if p_value is null then
			write(c_out, 'n');
		else
			write(c_out, 'i');
			write(c_out, to_char(p_value));
		end if;
	end;

	procedure float(c_out in out nocopy clob, p_value in number)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		if p_value is null then
			write(c_out, 'n');
		else
			write(c_out, 'f');
			write(c_out, trim(to_char(p_value, '999999999999999999999999999999.9999999999')));
		end if;
	end;

	procedure color(c_out in out nocopy clob, p_red in integer, p_green in integer, p_blue in integer, p_alpha in integer)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		write(c_out, 'c');
		int(c_out, p_red);
		int(c_out, p_green);
		int(c_out, p_blue);
		int(c_out, p_alpha);
	end;

	procedure timedelta(c_out in out nocopy clob, p_days integer := 0, p_seconds integer := 0, p_microseconds integer := 0)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		write(c_out, 't');
		int(c_out, p_days);
		int(c_out, p_seconds);
		int(c_out, p_microseconds);
	end;

	procedure monthdelta(c_out in out nocopy clob, p_months integer := 0)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		write(c_out, 'm');
		int(c_out, p_months);
	end;

	procedure date_(c_out in out nocopy clob, p_value date)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		if p_value is null then
			write(c_out, 'n');
		else
			write(c_out, 'x');
			int(c_out, extract(year from p_value));
			int(c_out, extract(month from p_value));
			int(c_out, extract(day from p_value));
		end if;
	end;

	procedure date_(c_out in out nocopy clob, p_value timestamp)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		if p_value is null then
			write(c_out, 'n');
		else
			write(c_out, 'x');
			int(c_out, extract(year from p_value));
			int(c_out, extract(month from p_value));
			int(c_out, extract(day from p_value));
		end if;
	end;

	procedure datetime(c_out in out nocopy clob, p_value date)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		if p_value is null then
			write(c_out, 'n');
		else
			write(c_out, 'z');
			int(c_out, extract(year from p_value));
			int(c_out, extract(month from p_value));
			int(c_out, extract(day from p_value));
			int(c_out, to_number(to_char(p_value, 'HH24')));
			int(c_out, to_number(to_char(p_value, 'MI')));
			int(c_out, to_number(to_char(p_value, 'SS')));
			int(c_out, 0);
		end if;
	end;

	procedure datetime(c_out in out nocopy clob, p_value timestamp)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		if p_value is null then
			write(c_out, 'n');
		else
			write(c_out, 'z');
			int(c_out, extract(year from p_value));
			int(c_out, extract(month from p_value));
			int(c_out, extract(day from p_value));
			int(c_out, extract(hour from p_value));
			int(c_out, extract(minute from p_value));
			int(c_out, trunc(extract(second from p_value)));
			int(c_out, to_number(to_char(p_value, 'FF6')));
		end if;
	end;

	procedure slice(c_out in out nocopy clob, p_start integer := null, p_stop integer := null)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		write(c_out, 'r');
		int(c_out, p_start);
		int(c_out, p_stop);
	end;

	procedure writeul4onstr(c_out in out nocopy clob, p_value in varchar2)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		end if;
		if length(p_value) <= 16000 then
			write(c_out, replace(replace(p_value, '\', '\\'), '"', '\"'));
		else
			for i in 0 .. trunc((length(p_value) - 1)/16000) loop
				write(c_out, replace(replace(substr(p_value, i * 16000 + 1, 16000), '\', '\\'), '"', '\"'));
			end loop;
		end if;
	end;

	procedure str(c_out in out nocopy clob, p_value in varchar2, p_backref boolean := false)
	as
		v_regkey varchar2(300);
		v_buf varchar2(16000 char);
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		if p_value is null then
			write(c_out, 'n');
		elsif p_backref and length(p_value) < 300-4 then -- the key must fit in the backrefregistry, so we refuse to store long strings in the registry
			v_regkey := 'str:' || p_value;
			if registry.exists(v_regkey) then
				write(c_out, '^');
				write(c_out, to_char(registry(v_regkey)));
			else
				write(c_out, 'S"');
				writeul4onstr(c_out, p_value);
				write(c_out, '"');
				registry(v_regkey) := registry.count;
			end if;
		else
			write(c_out, 's"');
			writeul4onstr(c_out, p_value);
			write(c_out, '"');
		end if;
	end;

	procedure str(c_out in out nocopy clob, p_value in clob)
	as
		v_buf varchar2(16000 char);
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		if p_value is null then
			write(c_out, 'n');
		else
			write(c_out, 's"');

			for i in 0 .. trunc((dbms_lob.getlength(p_value) - 1 )/16000) loop
				v_buf := dbms_lob.substr(p_value, 16000, i * 16000 + 1);
				writeul4onstr(c_out, v_buf);
			end loop;

			write(c_out, '"');
		end if;
	end;

	procedure template(
		c_out in out nocopy clob,
		p_name varchar2,
		p_source in clob,
		p_signature varchar2 := null,
		p_whitespace varchar2 := 'keep',
		p_startdelim varchar2 := '<?',
		p_enddelim varchar2 := '?>'
	)
	as
	begin
		beginobject(c_out, 'de.livinglogic.ul4.template');
			none(c_out); -- The version ``None`` means that the template must be compiled from source
			str(c_out, p_name);
			str(c_out, p_source);
			str(c_out, p_signature);
			str(c_out, p_whitespace);
			str(c_out, p_startdelim);
			str(c_out, p_enddelim);
		endobject(c_out);
	end;

	procedure key(c_out in out nocopy clob, p_key in varchar2)
	as
	begin
		str(c_out, p_key, true);
	end;

	procedure keynone(c_out in out nocopy clob, p_key in varchar2)
	as
	begin
		key(c_out, p_key);
		none(c_out);
	end;

	procedure keybool(c_out in out nocopy clob, p_key in varchar2, p_value in integer)
	as
	begin
		key(c_out, p_key);
		bool(c_out, p_value);
	end;

	procedure keyint(c_out in out nocopy clob, p_key in varchar2, p_value in integer)
	as
	begin
		key(c_out, p_key);
		int(c_out, p_value);
	end;

	procedure keyfloat(c_out in out nocopy clob, p_key in varchar2, p_value in number)
	as
	begin
		key(c_out, p_key);
		float(c_out, p_value);
	end;

	procedure keydate(c_out in out nocopy clob, p_key in varchar2, p_value date)
	as
	begin
		key(c_out, p_key);
		date_(c_out, p_value);
	end;

	procedure keydate(c_out in out nocopy clob, p_key in varchar2, p_value timestamp)
	as
	begin
		key(c_out, p_key);
		date_(c_out, p_value);
	end;

	procedure keydatetime(c_out in out nocopy clob, p_key in varchar2, p_value date)
	as
	begin
		key(c_out, p_key);
		datetime(c_out, p_value);
	end;

	procedure keydatetime(c_out in out nocopy clob, p_key in varchar2, p_value timestamp)
	as
	begin
		key(c_out, p_key);
		datetime(c_out, p_value);
	end;

	procedure keytimedelta(c_out in out nocopy clob, p_key in varchar2, p_days integer := 0, p_seconds integer := 0, p_microseconds integer := 0)
	as
	begin
		key(c_out, p_key);
		timedelta(c_out, p_days, p_seconds, p_microseconds);
	end;

	procedure keymonthdelta(c_out in out nocopy clob, p_key in varchar2, p_months integer := 0)
	as
	begin
		key(c_out, p_key);
		monthdelta(c_out, p_months);
	end;

	procedure keyslice(c_out in out nocopy clob, p_key in varchar2, p_start integer := null, p_stop integer := null)
	as
	begin
		key(c_out, p_key);
		slice(c_out, p_start, p_stop);
	end;

	procedure keycolor(c_out in out nocopy clob, p_key in varchar2, p_red in integer, p_green in integer, p_blue in integer, p_alpha in integer)
	as
	begin
		key(c_out, p_key);
		color(c_out, p_red, p_green, p_blue, p_alpha);
	end;

	procedure keystr(c_out in out nocopy clob, p_key in varchar2, p_value in varchar2, p_backref boolean := false)
	as
	begin
		key(c_out, p_key);
		str(c_out, p_value, p_backref);
	end;

	procedure keystr(c_out in out nocopy clob, p_key in varchar2, p_value in clob)
	as
	begin
		key(c_out, p_key);
		str(c_out, p_value);
	end;

	procedure beginlist(c_out in out nocopy clob)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		write(c_out, 'l');
	end;

	procedure endlist(c_out in out nocopy clob)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		write(c_out, ']');
	end;

	procedure beginset(c_out in out nocopy clob)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		write(c_out, 'y');
	end;

	procedure endset(c_out in out nocopy clob)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		write(c_out, '}');
	end;

	procedure begindict(c_out in out nocopy clob, p_ordered integer := 0)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		write(c_out, case when p_ordered = 0 then 'd' else 'e' end);
	end;

	procedure enddict(c_out in out nocopy clob)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		write(c_out, '}');
	end;

	procedure beginobject(c_out in out nocopy clob, p_type varchar2)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		write(c_out, 'o');
		str(c_out, p_type);
	end;

	function beginobject(c_out in out nocopy clob, p_type in varchar2, p_id in varchar2)
	return boolean
	as
	begin
		if p_id is null then
			none(c_out);
			return false;
		else
			if c_out is null then
				dbms_lob.createtemporary(c_out, true);
			else
				write(c_out, ' ');
			end if;
			if registry.exists(p_type || ':' || p_id) then
				write(c_out, '^');
				write(c_out, to_char(registry(p_type || ':' || p_id)));
				return false;
			else
				write(c_out, 'O');
				registry(p_type || ':' || p_id) := registry.count;
				str(c_out, p_type, true);
				return true;
			end if;
		end if;
	end;

	procedure endobject(c_out in out nocopy clob)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		write(c_out, ')');
	end;
end;

/

