src/emq_custom_plugin_app.erl:: include/emq_custom_plugin.hrl src/emq_custom_plugin_mysql_cli.erl; @touch $@
src/emq_custom_plugin_mysql_cli.erl:: include/emq_custom_plugin.hrl; @touch $@
src/emq_custom_plugin_sup.erl:: include/emq_custom_plugin.hrl; @touch $@

COMPILE_FIRST += emq_custom_plugin_mysql_cli
