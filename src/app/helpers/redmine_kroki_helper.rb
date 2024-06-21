# frozen_string_literal: true

# Utility functions for the Redmine-Kroki plugin
module RedmineKrokiHelper
  require 'net/http'
  require 'uri'

  def convert_diagram(kroki_url, diagram_type, diagram_content, diagram_options = nil)
    raise 'Missing diagram type' if diagram_type.nil? || diagram_type.empty?
    raise 'Missing Kroki URL' if kroki_url.nil? || kroki_url.empty?

    res = send_kroki_request(kroki_url, diagram_type, diagram_content, diagram_options)

    raise "Cannot find the diagram \"#{diagram_type}\"" if res.code == '404'
    raise res.body if res.code == '400'

    res.body
  end

  def send_kroki_request(kroki_url, diagram_type, diagram_content, diagram_options = nil)
    type = diagram_type.downcase.delete(' -')
    url = URI.parse("#{kroki_url}/#{type}/svg")
    http = Net::HTTP.new(url.host, url.port)
    req = Net::HTTP::Post.new(url.path)

    req.content_type = 'text/plain'
    req.body = diagram_content
    add_diagram_options(req, diagram_options) unless diagram_options.nil?

    http.request(req)
  end
end

def add_diagram_options(request, options)
  options.each do |k, v|
    request.add_field("Kroki-Diagram-Options-#{k.to_s.downcase.capitalize}", v)
  end
end

def parse_macro_options(options)
  return nil if options.empty?

  options.map { |option| option.split('=') }.to_h.transform_keys(&:to_sym)
end

def wrap_diagram(diagram, classes)
  href = '/plugin_assets/redmine_kroki/stylesheets/redmine-kroki.css'
  style_tag = "<link rel='stylesheet' type='text/css' href='#{href}' />"

  "#{style_tag}<div class=\"#{classes}\">#{diagram}</div>"
end

def css_class(is_dark_forced, dark_themes, user_theme)
  is_dark_forced || user_theme && dark_themes.include?(user_theme) ? 'kroki dark' : 'kroki'
end

def get_user_theme(user)
  user.preference.respond_to?('theme') ? user.preference.theme : nil
end
