DITAOT_VER=1.5.3
DITAOT_URL='http://downloads.sourceforge.net/project/dita-ot/DITA-OT%20Latest%20Test%20Build/DITA%20OT%201.5.3%20M4/DITA-OT1.5.3_full_easy_install_M4_bin.zip?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fdita-ot%2F&ts=1302421644&use_mirror=freefr'
DITA_HOME=`pwd`/dita

CLASSPATH="${DITA_HOME}/lib:${DITA_HOME}/lib/dost.jar:${DITA_HOME}/lib/resolver.jar:${DITA_HOME}/lib/icu4j.jar:${DITA_HOME}/lib/saxon/saxon9.jar:${DITA_HOME}/lib/saxon/saxon9-dom.jar:${DITA_HOME}/lib/saxon/saxon9-dom4j.jar:${DITA_HOME}/lib/saxon/saxon9-jdom.jar:${DITA_HOME}/lib/saxon/saxon9-s9api.jar:${DITA_HOME}/lib/saxon/saxon9-sql.jar:${DITA_HOME}/lib/saxon/saxon9-xom.jar:${DITA_HOME}/lib/saxon/saxon9-xpath.jar:${DITA_HOME}/lib/saxon/saxon9-xqj.jar:${DITA_HOME}/tools/ant/lib:${DITA_HOME}/tools/ant/lib/xercesImpl.jar:${DITA_HOME}/tools/ant/lib/xml-apis.jar:${DITA_HOME}/lib/saxon"
export ANT_OPTS
export CLASSPATH 

all: fr en de


fr: createEmpty dita
	./dita/tools/ant/bin/ant -Dlang=fr -f build/build.xml
	cp build/fr/fusioninventory.pdf fusioninventory-fr.pdf

en: dita
	./dita/tools/ant/bin/ant -Dlang=en -f build/build.xml
	cp build/en/fusioninventory.pdf fusioninventory-en.pdf

de: createEmpty dita
	./dita/tools/ant/bin/ant -Dlang=de -f build/build.xml
	cp build/de/fusioninventory.pdf fusioninventory-de.pdf

dita.tar.gz:
	wget -O dita.tar.gz.part ${DITAOT_URL}
	mv dita.tar.gz.part dita.tar.gz

dita: dita.tar.gz
	tar xfz dita.tar.gz
	mv DITA-OT${DITAOT_VER} dita

clean:
	rm -rf build/fr build/de build/en build/temp dita.tar.gz dita

createEmpty:
	perl tools/createEmptyDitaFile.pl

.PHONY: fr de en createEmpty
