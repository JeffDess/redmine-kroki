# frozen_string_literal: true

Redmine::Plugin.register :redmine_kroki do
  name 'Redmine Kroki Plugin'
  author 'Jean-François Dessureault'
  description 'Render graphs in Redmine issues and wiki with Kroki'
  version '0.0.1'
  url 'https://github.com/jeffdess/redmine-kroki'
  author_url 'https://github.com/jeffdess'

  settings default: {
             'kroki_bpmn' => true,
             'kroki_excalidraw' => true,
             'kroki_mermaid' => true,
             'kroki_diagramsnet' => true
           },
           partial: 'settings/redmine-kroki_settings'

  Redmine::WikiFormatting::Macros.register do
    desc "Add Kroki graphs with a macro. \
         Example:\
         {{kroki-plantuml\
            ...\
         }}"
    macro :kroki do |_obj, _args, text|
      divid = "kroki_#{SecureRandom.alphanumeric(16)}"
      out = ''.html_safe
      out << content_tag(:div, text, id: divid, class: 'kroki')
      out
    end
  end
end
