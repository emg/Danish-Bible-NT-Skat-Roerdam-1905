# The mql program from Emdros.
#
# See http://emdros.org/ for more information.
#
MQL = /usr/bin/mql


CLEANFILES = *~ *.pyc *.pyo \
             MQL/NT_Skat_Roerdam_1905.mql \
             EmdrosDB/ntskatroerdam1905.sqlite3 \
             MQL/*~ BibleWorks/*~ OSIS/*~ USFM/*~


all: MQL/NT_Skat_Roerdam_1905.mql BibleWorks/DA_NT_Skat_Roerdam_1905_bibleworks.txt USFM/66REV.SFM

clean:
	rm -f $(CLEANFILES)


# Create an Emdros MQL script which can populate an Emdros database
# with the data from the Bible.
#
# Emdros is a general-purpose text database engine, especially well
# suited for creating digital libraries, such as most kinds of Bible
# software.
#
# For more information, see http://emdros.org/
#
mql: MQL/NT_Skat_Roerdam_1905.mql

MQL/NT_Skat_Roerdam_1905.mql: OSIS/Skat-Roerdam.OSIS.xml osis2mql.py 
	python osis2mql.py --NT $< >$@



# Create a BibleWorks file
bbw: BibleWorks/DA_NT_Skat_Roerdam_1905_bibleworks.txt

BibleWorks/DA_NT_Skat_Roerdam_1905_bibleworks.txt: OSIS/Skat-Roerdam.OSIS.xml osis2bibleworks.py
	python osis2bibleworks.py OSIS/Skat-Roerdam.OSIS.xml > $@



# Create an SQLite3 database in Emdros format from the MQL
db3: EmdrosDB/ntskatroerdam1905.sqlite3

EmdrosDB/ntskatroerdam1905.sqlite3: MQL/NT_Skat_Roerdam_1905.mql MQL/osis_schema.mql
	-echo "DROP DATABASE '${@}' GO" | $(MQL) -b 3
	echo "CREATE DATABASE '${@}' GO" | $(MQL) -b 3
	$(MQL) -b 3 -d $@ MQL/osis_schema.mql
	$(MQL) -b 3 -d $@ $<
	echo "CREATE OBJECT FROM MONADS={1-4000000}[db dbname:='DanskSkatRoerdam1905';friendly_dbname:='Dansk NT Skat Rørdam 1905';bible_parts:=(NT);language:=danish;dbtype:=bible;]" | $(MQL) -b 3 -n -d $@
	echo "VACUUM DATABASE ANALYZE GO" | $(MQL) -b 3 -d $@

.PHONY: db3 mql bbw


USFM/66REV.SFM: OSIS/Skat-Roerdam.OSIS.xml osis2usfm.py
	python osis2usfm.py $<
