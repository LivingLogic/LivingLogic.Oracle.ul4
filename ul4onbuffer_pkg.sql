create or replace package ul4onbuffer_pkg
as

	procedure init(c_out in out nocopy clob);
	procedure flush(c_out in out nocopy clob);
	procedure none(c_out in out nocopy clob);
	procedure bool(c_out in out nocopy clob, p_value in integer);
	procedure int(c_out in out nocopy clob, p_value in integer);
	procedure float(c_out in out nocopy clob, p_value in number);
	procedure color(c_out in out nocopy clob, p_red in integer, p_green in integer, p_blue in integer, p_alpha in integer);
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
	procedure key(c_out in out nocopy clob, p_key in varchar2);
	procedure keynone(c_out in out nocopy clob, p_key in varchar2);
	procedure keybool(c_out in out nocopy clob, p_key in varchar2, p_value in integer);
	procedure keyint(c_out in out nocopy clob, p_key in varchar2, p_value in integer);
	procedure keyfloat(c_out in out nocopy clob, p_key in varchar2, p_value in number);
	procedure keycolor(c_out in out nocopy clob, p_key in varchar2, p_red in integer, p_green in integer, p_blue in integer, p_alpha in integer);
	procedure keydatetime(c_out in out nocopy clob, p_key in varchar2, p_value date);
	procedure keydatetime(c_out in out nocopy clob, p_key in varchar2, p_value timestamp);
	procedure keytimedelta(c_out in out nocopy clob, p_key in varchar2, p_days integer := 0, p_seconds integer := 0, p_microseconds integer := 0);
	procedure keymonthdelta(c_out in out nocopy clob, p_key in varchar2, p_months integer := 0);
	procedure keyslice(c_out in out nocopy clob, p_key in varchar2, p_start integer := null, p_stop integer := null);
	procedure keystr(c_out in out nocopy clob, p_key in varchar2, p_value in varchar2);
	procedure keystr(c_out in out nocopy clob, p_key in varchar2, p_value in clob);
	procedure beginlist(c_out in out nocopy clob);
	procedure endlist(c_out in out nocopy clob);
	procedure beginset(c_out in out nocopy clob);
	procedure endset(c_out in out nocopy clob);
	procedure begindict(c_out in out nocopy clob, p_ordered integer := 0);
	procedure enddict(c_out in out nocopy clob);
	procedure beginobject(c_out in out nocopy clob, p_type varchar2);
	function beginobject(c_out in out nocopy clob, p_type in varchar2, p_id in varchar2) return boolean;
	procedure endobject(c_out in out nocopy clob);
end;
/

create or replace package body ul4onbuffer_pkg
as
	type backrefregistry is table of integer index by varchar2(300);
	registry backrefregistry;
	buffer varchar2(32000);
	procedure init(c_out in out nocopy clob)
	as
	begin
		registry.delete;
		buffer := null;
	end;

	procedure flush(c_out in out nocopy clob)
	as
	begin
		dbms_lob.writeappend(c_out, length(buffer), buffer);
		buffer := null;
	end;

	procedure write(c_out in out nocopy clob, p_value in varchar2)
	as
	begin
		if buffer is not null and length(buffer) + length(p_value) >= 32000 then
			flush(c_out);
		end if;
		buffer := buffer || p_value;
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
		v_buf varchar2(32000);
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		end if;
--		write(c_out, p_value);

		v_buf := p_value;
--		v_buf := replace(v_buf, '''', '''''');

		v_buf := replace(v_buf, '\', '\\');
		v_buf := asciistr(v_buf);
		v_buf := replace(v_buf, '\', '\u');

		-- escaped-Backslash zurück
		v_buf := replace(v_buf, '\u005C', '\');

		for i in 1 .. 7 loop
			v_buf := replace(v_buf, chr(i), '\x' || replace(substr(to_char(ascii(chr(i)), 'xx'), 2, 2), ' ', '0'));
		end loop;
		v_buf := replace(v_buf, chr(8), '\b');
		v_buf := replace(v_buf, chr(9), '\t');
		v_buf := replace(v_buf, chr(10), '\n');
		v_buf := replace(v_buf, chr(11), '\x' || replace(substr(to_char(ascii(11), 'xx'), 2, 2), ' ', '0'));
		v_buf := replace(v_buf, chr(12), '\f');
		v_buf := replace(v_buf, chr(13), '\r');
		v_buf := replace(v_buf, '"', '\"');
		for i in 128 .. 159 loop
			v_buf := replace(v_buf, chr(i), '\x' || replace(substr(to_char(ascii(chr(i)), 'xx'), 2, 2), ' ', '0'));
		end loop;

		write(c_out, v_buf);
	end;

	procedure str(c_out in out nocopy clob, p_value in varchar2, p_backref boolean := false)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			write(c_out, ' ');
		end if;
		if p_value is null then
			write(c_out, 'n');
		elsif p_backref and length(p_value) < 300-4 then -- the key must fit in the backrefregistry, so we refuse to store long string in the registry
			if registry.exists('str:' || p_value) then
				write(c_out, '^');
				write(c_out, to_char(registry('str:' || p_value)));
			else
				write(c_out, 'S"');
				writeul4onstr(c_out, p_value);
				write(c_out, '"');
				registry('str:' || p_value) := registry.count;
			end if;
		else
			write(c_out, 's"');

			writeul4onstr(c_out, p_value);

			write(c_out, '"');
		end if;
	end;

	procedure str(c_out in out nocopy clob, p_value in clob)
	as
		v_buf varchar2(32000);
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

			for i in 0 .. trunc((dbms_lob.getlength(p_value) - 1 )/10000) loop
				v_buf := dbms_lob.substr(p_value, 10000, i * 10000 + 1);
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

	procedure keystr(c_out in out nocopy clob, p_key in varchar2, p_value in varchar2)
	as
	begin
		key(c_out, p_key);
		str(c_out, p_value);
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
