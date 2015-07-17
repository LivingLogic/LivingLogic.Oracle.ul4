create or replace package ul4on_pkg
as
	procedure none(c_out in out nocopy clob);
	procedure bool(c_out in out nocopy clob, p_value in integer);
	procedure int(c_out in out nocopy clob, p_value in integer);
	procedure float(c_out in out nocopy clob, p_value in number);
	procedure color(c_out in out nocopy clob, p_red in integer, p_green in integer, p_blue in integer, p_alpha in integer);
	procedure datetime(c_out in out nocopy clob, p_value date);
	procedure datetime(c_out in out nocopy clob, p_value timestamp);
	procedure datetime(c_out in out nocopy clob, p_value timestamp with time zone);
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
	procedure keydatetime(c_out in out nocopy clob, p_key in varchar2, p_value timestamp with time zone);
	procedure keytimedelta(c_out in out nocopy clob, p_key in varchar2, p_days integer := 0, p_seconds integer := 0, p_microseconds integer := 0);
	procedure keymonthdelta(c_out in out nocopy clob, p_key in varchar2, p_months integer := 0);
	procedure keyslice(c_out in out nocopy clob, p_key in varchar2, p_start integer := null, p_stop integer := null);
	procedure keystr(c_out in out nocopy clob, p_key in varchar2, p_value in varchar2);
	procedure keystr(c_out in out nocopy clob, p_key in varchar2, p_value in clob);
	procedure beginlist(c_out in out nocopy clob);
	procedure endlist(c_out in out nocopy clob);
	procedure beginset(c_out in out nocopy clob);
	procedure endset(c_out in out nocopy clob);
	procedure begindict(c_out in out nocopy clob);
	procedure enddict(c_out in out nocopy clob);
	procedure beginobject(c_out in out nocopy clob, p_type varchar2);
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
		v_int varchar2(50);
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
		v_int varchar2(50);
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
	
	procedure datetime(c_out in out nocopy clob, p_value timestamp with time zone)
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
		v_int varchar2(50);
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

	procedure str(c_out in out nocopy clob, p_value in varchar2)
	as
		v_buf varchar2(10);
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
			for i in 1 .. length(p_value) loop
				v_buf := substr(p_value, i, 1);
				case v_buf
					when chr(8) then
						dbms_lob.writeappend(c_out, 2, '\b');
					when chr(9) then
						dbms_lob.writeappend(c_out, 2, '\t');
					when chr(10) then
						dbms_lob.writeappend(c_out, 2, '\n');
					when chr(12) then
						dbms_lob.writeappend(c_out, 2, '\f');
					when chr(13) then
						dbms_lob.writeappend(c_out, 2, '\r');
					when '"' then
						dbms_lob.writeappend(c_out, 2, '\"');
					when '\' then
						dbms_lob.writeappend(c_out, 2, '\\');
					else
						if ascii(v_buf) < 32 or (ascii(v_buf) >= 128 and ascii(v_buf) < 160) then
							v_buf := '\x' || replace(substr(to_char(ascii(v_buf), 'xx'), 2, 2), ' ', '0');
							dbms_lob.writeappend(c_out, length(v_buf), v_buf);
						else
							v_buf := replace(asciistr(v_buf), '\', '\u');
							dbms_lob.writeappend(c_out, length(v_buf), v_buf);
						end if;
				end case;
			end loop;
			dbms_lob.writeappend(c_out, 1, '"');
		end if;
	end;

	procedure str(c_out in out nocopy clob, p_value in clob)
	as
		v_buf varchar2(10);
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
			for i in 1 .. length(p_value) loop
				v_buf := substr(p_value, i, 1);
				case v_buf
					when chr(8) then
						dbms_lob.writeappend(c_out, 2, '\b');
					when chr(9) then
						dbms_lob.writeappend(c_out, 2, '\t');
					when chr(10) then
						dbms_lob.writeappend(c_out, 2, '\n');
					when chr(12) then
						dbms_lob.writeappend(c_out, 2, '\f');
					when chr(13) then
						dbms_lob.writeappend(c_out, 2, '\r');
					when '"' then
						dbms_lob.writeappend(c_out, 2, '\"');
					when '\' then
						dbms_lob.writeappend(c_out, 2, '\\');
					else
						if ascii(v_buf) < 32 or (ascii(v_buf) >= 128 and ascii(v_buf) < 160) then
							v_buf := '\x' || replace(substr(to_char(ascii(v_buf), 'xx'), 2, 2), ' ', '0');
							dbms_lob.writeappend(c_out, length(v_buf), v_buf);
						else
							v_buf := replace(asciistr(v_buf), '\', '\u');
							dbms_lob.writeappend(c_out, length(v_buf), v_buf);
						end if;
				end case;
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
	
	procedure keydatetime(c_out in out nocopy clob, p_key in varchar2, p_value timestamp with time zone)
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

	procedure begindict(c_out in out nocopy clob)
	as
	begin
		if c_out is null then
			dbms_lob.createtemporary(c_out, true);
		else
			dbms_lob.writeappend(c_out, 1, ' ');
		end if;
		dbms_lob.writeappend(c_out, 1, 'd');
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
