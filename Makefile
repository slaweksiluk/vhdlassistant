
INSTALL_DEST=~/.local/share/gedit/plugins/

all: vhdlparser snippetformatter checkpython

vhdlparser:
	make -C vhdlparser

snippetformatter:
	make -C snippetformatter

checkpython:
		python3 -m compileall -f PyVhdlUtil
		python3 -m compileall -f geditplugin/vhdlassistant

install: all
	mkdir -p $(INSTALL_DEST)
	cp geditplugin/vhdlassistant.plugin $(INSTALL_DEST)
	cp -r geditplugin/vhdlassistant $(INSTALL_DEST)
	cp -r PyVhdlUtil $(INSTALL_DEST)/vhdlassistant
	cp vhdlparser/vhdlparser $(INSTALL_DEST)/vhdlassistant/PyVhdlUtil
	cp snippetformatter/snippetformatter $(INSTALL_DEST)/vhdlassistant/PyVhdlUtil

clean:
	make clean -C vhdlparser
	make clean -C snippetformatter
	find . -depth -name "__pycache__" -exec rm -r '{}' \;

	
.PHONY: vhdlparser
.PHONY: checkpython
.PHONY: snippetformatter

