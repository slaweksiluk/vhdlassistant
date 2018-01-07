# vhdlassistant
gedit plugin
forked from https://bitbucket.org/fhuemer/vhdlassistant

vhdlassistant 
=============

vhdlassistant is a plugin for gedit 3.10.x and 3.14.x
The plugin itself is written in python3. However, the VHDL parser is implemented 
in C, using flex and bison.

Features:
---------
* code structure view in the editor's side panel,
* syntax checks
* code generation (testbenches, instances of entities/components, ... )
* snippet library (currently only a few snippets are available, but I'm 
  planning to add more.)   

Installation:
-------------
To build and install vhdlassistant the following tools are required

 * flex
 * bison  
 * gcc  

run the following commands:
~~~~
  git clone https://bitbucket.org/fhuemer/vhdlassistant.git
  cd vhdlassistant 
  make install #no root privileges required
~~~~

Do not use root privileges for the "make install" command. The plugin is
installed in the plugins directory of gedit in your home directory
(~/.local/share/gedit/plugins).

You can use "make uninstall" to remove the plugin.


