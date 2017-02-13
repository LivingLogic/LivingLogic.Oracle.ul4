create or replace package ul4on_pkg
as
	type backrefregistry is table of integer index by varchar2(300);

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
	procedure str(c_out in out nocopy clob, p_value in varchar2);
	procedure str(c_out in out nocopy clob, p_value in clob);
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
	function beginobject(c_out in out nocopy clob, p_type in varchar2, p_registry in out nocopy backrefregistry, p_id in varchar2) return boolean;
	procedure endobject(c_out in out nocopy clob);
	procedure append(c_out in out nocopy clob, p_value in clob);
end;
/

create or replace package body ul4on_pkg
as
	procedure none(c_out in out nocopy clob)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		dbms_lob.writeappend(c_out, 1, 'n');
	end;

	procedure bool(c_out in out nocopy clob, p_value in integer)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		if p_value is null then
			dbms_lob.writeappend(c_out, 1, 'n');
		elsif p_value != 0 then
			dbms_lob.writeappend(c_out, 2, 'bT');
		else
			dbms_lob.writeappend(c_out, 2, 'bF');
		end if;
	end;

	procedure int(c_out in out nocopy clob, p_value in integer)
	as
		v_strvalue varchar2(50);
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		if p_value is null then
			dbms_lob.writeappend(c_out, 1, 'n');
		else
			v_strvalue := to_char(p_value);
			dbms_lob.writeappend(c_out, 1, 'i');
			dbms_lob.writeappend(c_out, length(v_strvalue), v_strvalue);
		end if;
	end;

	procedure float(c_out in out nocopy clob, p_value in number)
	as
		v_strvalue varchar2(50);
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		if p_value is null then
			dbms_lob.writeappend(c_out, 1, 'n');
		else
			v_strvalue := trim(to_char(p_value, '999999999999999999999999999999.9999999999'));
			dbms_lob.writeappend(c_out, 1, 'f');
			dbms_lob.writeappend(c_out, length(v_strvalue), v_strvalue);
		end if;
	end;

	procedure color(c_out in out nocopy clob, p_red in integer, p_green in integer, p_blue in integer, p_alpha in integer)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		dbms_lob.writeappend(c_out, 1, 'c');
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
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		dbms_lob.writeappend(c_out, 1, 't');
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
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		dbms_lob.writeappend(c_out, 1, 'm');
		int(c_out, p_months);
	end;

	procedure datetime(c_out in out nocopy clob, p_value date)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		if p_value is null then
			dbms_lob.writeappend(c_out, 1, 'n');
		else
			dbms_lob.writeappend(c_out, 1, 'z');
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
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		if p_value is null then
			dbms_lob.writeappend(c_out, 1, 'n');
		else
			dbms_lob.writeappend(c_out, 1, 'z');
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
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		dbms_lob.writeappend(c_out, 1, 'r');
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

		v_buf := p_value;
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

		dbms_lob.writeappend(c_out, length(v_buf), v_buf);
	end;

	procedure str(c_out in out nocopy clob, p_value in varchar2)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		if p_value is null then
			dbms_lob.writeappend(c_out, 1, 'n');
		else
			dbms_lob.writeappend(c_out, 1, 's');
			dbms_lob.writeappend(c_out, 1, '"');

			writeul4onstr(c_out, p_value);

			dbms_lob.writeappend(c_out, 1, '"');
		end if;
	end;

	procedure str(c_out in out nocopy clob, p_value in clob)
	as
		v_buf varchar2(32000);
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		if p_value is null then
			dbms_lob.writeappend(c_out, 1, 'n');
		else
			dbms_lob.writeappend(c_out, 1, 's');

			dbms_lob.writeappend(c_out, 1, '"');

			for i in 0 .. trunc((dbms_lob.getlength(p_value) - 1 )/10000) loop
				v_buf := dbms_lob.substr(p_value, 10000, i * 10000 + 1);
				writeul4onstr(c_out, v_buf);
			end loop;

			dbms_lob.writeappend(c_out, 1, '"');
		end if;
	end;

	procedure key(c_out in out nocopy clob, p_key in varchar2)
	as
	begin
		str(c_out, p_key);
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
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		dbms_lob.writeappend(c_out, 1, 'l');
	end;

	procedure endlist(c_out in out nocopy clob)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		dbms_lob.writeappend(c_out, 1, ']');
	end;

	procedure beginset(c_out in out nocopy clob)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		dbms_lob.writeappend(c_out, 1, 'y');
	end;

	procedure endset(c_out in out nocopy clob)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		dbms_lob.writeappend(c_out, 1, '}');
	end;

	procedure begindict(c_out in out nocopy clob, p_ordered integer := 0)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		dbms_lob.writeappend(c_out, 1, case when p_ordered = 0 then 'd' else 'e' end);
	end;

	procedure enddict(c_out in out nocopy clob)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		dbms_lob.writeappend(c_out, 1, '}');
	end;

	procedure beginobject(c_out in out nocopy clob, p_type varchar2)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		dbms_lob.writeappend(c_out, 1, 'o');
		str(c_out, p_type);
	end;

	function beginobject(c_out in out nocopy clob, p_type in varchar2, p_registry in out nocopy backrefregistry, p_id in varchar2)
	return boolean
	as
		v_strindex varchar2(50);
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		if p_registry.exists(p_type || ':' || p_id) then
			v_strindex := to_char(p_registry(p_type || ':' || p_id));
			dbms_lob.writeappend(c_out, 1, '^');
			dbms_lob.writeappend(c_out, length(v_strindex), v_strindex);
			return false;
		else
			dbms_lob.writeappend(c_out, 1, 'O');
			p_registry(p_type || ':' || p_id) := p_registry.count;

			if p_registry.exists('str:' || p_type) then
				v_strindex := to_char(p_registry('str:' || p_type));
				dbms_lob.writeappend(c_out, 2, ' ^');
				dbms_lob.writeappend(c_out, length(v_strindex), v_strindex);
			else
				dbms_lob.writeappend(c_out, 3, ' S"');
				writeul4onstr(c_out, p_type);
				dbms_lob.writeappend(c_out, 1, '"');
				p_registry('str:' || p_type) := p_registry.count;
			end if;
			return true;
		end if;
	end;

	procedure endobject(c_out in out nocopy clob)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		dbms_lob.writeappend(c_out, 1, ')');
	end;

	procedure append(c_out in out nocopy clob, p_value in clob)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		if p_value is not null and dbms_lob.getlength(p_value) != 0 then
			dbms_lob.append(c_out, p_value);
		end if;
	end;
end;
/
