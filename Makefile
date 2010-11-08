DITAOT_VER=1.5.1
DITAOT_URL='http://downloads.sourceforge.net/project/dita-ot/DITA-OT%20Stable%20Release/DITA%20Open%20Toolkit%20${DITAOT_VER}/DITA-OT1.5.1_full_easy_install_bin.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fdita-ot%2Ffiles%2FDITA-OT%2520Stable%2520Release%2F&ts=1288886576&use_mirror=ovh'
DITA_HOME=`pwd`/dita

CLASSPATH="${DITA_HOME}/lib:${DITA_HOME}/lib/dost.jar:${DITA_HOME}/lib/resolver.jar:${DITA_HOME}/lib/icu4j.jar:${DITA_HOME}/lib/saxon/saxon9.jar:${DITA_HOME}/lib/saxon/saxon9-dom.jar:${DITA_HOME}/lib/saxon/saxon9-dom4j.jar:${DITA_HOME}/lib/saxon/saxon9-jdom.jar:${DITA_HOME}/lib/saxon/saxon9-s9api.jar:${DITA_HOME}/lib/saxon/saxon9-sql.jar:${DITA_HOME}/lib/saxon/saxon9-xom.jar:${DITA_HOME}/lib/saxon/saxon9-xpath.jar:${DITA_HOME}/lib/saxon/saxon9-xqj.jar"

export ANT_OPTS
export CLASSPATH 

all: fr en de


fr: dita
	ant -Dlang=fr -f build/build.xml

en: dita
	ant -Dlang=en -f build/build.xml

de: dita
	ant -Dlang=de -f build/build.xml

dita.tar.gz:
	wget -O dita.tar.gz.part ${DITAOT_URL}
	mv dita.tar.gz.part dita.tar.gz

dita: dita.tar.gz
	tar xfz dita.tar.gz
	mv DITA-OT${DITAOT_VER} dita

clean:
	rm -rf build/fr build/de build/en build/temp

.PHONY: fr de en
