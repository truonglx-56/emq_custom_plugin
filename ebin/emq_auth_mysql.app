{application, emq_auth_mysql, [
	{description, "EMQ plugin with MySQL"},
	{vsn, "1.0.0"},
	{id, "80811e6-dirty"},
	{modules, ['emq_custom_plugin','emq_custom_plugin_app','emq_custom_plugin_sup']},
	{registered, []},
	{applications, [kernel,stdlib,mysql,ecpool]}
]}.