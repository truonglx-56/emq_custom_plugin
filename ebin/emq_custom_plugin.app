{application, emq_custom_plugin, [
	{description, "EMQ plugin with MySQL"},
	{vsn, "1.0.0"},
	{id, "80811e6-dirty"},
	{modules, ['emq_custom_plugin','emq_custom_plugin_app','emq_custom_plugin_sup']},
	{registered, [emq_custom_plugin_sup]},
	{applications, [kernel,stdlib,mysql,ecpool]},
	{mod, {emq_custom_plugin_app, []}}
]}.