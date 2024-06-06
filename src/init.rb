# frozen_string_literal: true

Redmine::Plugin.register :redmine_kroki do
  name 'Redmine Kroki Plugin'
  author 'Jean-François Dessureault'
  description 'Render graphs in Redmine issues and wiki with Kroki'
  version '0.0.1'
  url 'https://github.com/jeffdess/redmine-kroki'
  author_url 'https://github.com/jeffdess'

  settings default: { 'kroki_url' => 'http://kroki:8000' },
           partial: 'settings/redmine-kroki_settings'

  Redmine::WikiFormatting::Macros.register do
    desc "Render graphs in wikis and issues with Kroki.\
         Use 'kroki' as the macro name and the diagram_type as the argument.\
         \
         Example:\
         {{kroki(mermaid)\
         flowchart LR\
           Hello --> World\
         }}"
    macro :kroki do |_obj, args, text|
      extend RedmineKrokiHelper
      diagram_type = args.first
      res = send_kroki_request(diagram_type, text)

      res.html_safe
    end
  end
end
