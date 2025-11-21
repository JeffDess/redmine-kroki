# frozen_string_literal: true

Redmine::Plugin.register :redmine_kroki do
  name 'Redmine Kroki Plugin'
  author 'Jean-François Dessureault'
  description 'Render graphs in Redmine issues and wiki with Kroki'
  version '0.4.0'
  url 'https://github.com/jeffdess/redmine-kroki'
  author_url 'https://github.com/jeffdess'

  settings default: {
             'kroki_url' => 'http://kroki:8000',
             'dark_themes' => %w[dark dark-theme redmine-dark],
             'force_dark' => false,
             'fontawesome_css' => 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css'
           },
           partial: 'settings/redmine-kroki_settings'

  Redmine::WikiFormatting::Macros.register do
    desc "Renders a diagram from textual description with Kroki.\n" +
         "Provide the diagram type as the first argument and the options after.\n" +
         "Examples:\n\n" +
         "{{kroki(mermaid)\nflowchart LR\n  Hello --> World\n}}\n\n" +
         "{{kroki(mermaid, theme=dark)\nflowchart LR\n  Hello --> World\n}}"
    macro :kroki do |_obj, args, text|
      extend RedmineKrokiHelper
      kroki_url = Setting.plugin_redmine_kroki[:kroki_url]
      diagram_type = args.shift
      diagram_options = parse_macro_options(args)
      diagram = convert_diagram(kroki_url, diagram_type, text, diagram_options)
      css = css_class(
        Setting.plugin_redmine_kroki[:force_dark],
        Setting.plugin_redmine_kroki[:dark_themes],
        get_user_theme(User.current)
      )
      res = wrap_diagram(diagram, css, diagram_options, diagram_type)

      res.html_safe.force_encoding('UTF-8')
    end
  end
end
