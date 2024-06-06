include RedmineKrokiHelper
# frozen_string_literal: true

Redmine::Plugin.register :redmine_kroki do
  name 'Redmine Kroki Plugin'
  author 'Jean-François Dessureault'
  description 'Render graphs in Redmine issues and wiki with Kroki'
  version '0.0.1'
  url 'https://github.com/jeffdess/redmine-kroki'
  author_url 'https://github.com/jeffdess'

  settings default: { 'kroki_endpoint' => 'http://kroki' },
           partial: 'settings/redmine-kroki_settings'

  Redmine::WikiFormatting::Macros.register do
    desc "Add Kroki graphs with a macro. \
         Example:\
         {{kroki(mermaid)\
            ...\
         }}"
    macro :kroki do |_obj, args, text|
      diagram_type = args.first
      res = send_kroki_request(diagram_type, text)

      out = res.html_safe
      out
    end
  end
end
