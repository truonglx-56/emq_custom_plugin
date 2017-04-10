{application, emq_plugin_template, [
	{description, "EMQ Plugin Template"},
	{vsn, "2.1.0"},
	{id, "80811e6"},
	{modules, ['emq_acl_demo','emq_auth_demo','emq_cli_demo','emq_plugin_template','emq_plugin_template_app','emq_plugin_template_sup']},
	{registered, [emq_plugin_template_sup]},
	{applications, [kernel,stdlib]},
	{mod, {emq_plugin_template_app, []}}
]}.