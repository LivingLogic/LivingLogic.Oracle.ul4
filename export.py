import sys

from ll import orasql

db = orasql.connect(sys.argv[1])


def export(f, obj):
	print(obj.createsql(db, True), file=f)


with open("ul4on_pkg.sql", "w") as f:
	export(f, orasql.Package("UL4ON_PKG"))
	export(f, orasql.PackageBody("UL4ON_PKG"))


with open("ul4onbuffer_pkg.sql", "w") as f:
	export(f, orasql.Package("UL4ONBUFFER_PKG"))
	export(f, orasql.PackageBody("UL4ONBUFFER_PKG"))


with open("ul4onblobbuffer_pkg.sql", "w") as f:
	export(f, orasql.Package("UL4ONBLOBBUFFER_PKG"))
	export(f, orasql.PackageBody("UL4ONBLOBBUFFER_PKG"))


with open("ul4ongen.sql", "w") as f:
	export(f, orasql.Type("UL4ONGEN"))
	export(f, orasql.TypeBody("UL4ONGEN"))