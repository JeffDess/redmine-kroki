# frozen_string_literal: true

PLUGIN_OPTIONS = %i[max_width max_height].freeze

# Utility functions for the Redmine-Kroki plugin
module RedmineKrokiHelper
  require 'net/http'
  require 'uri'

  def convert_diagram(kroki_url, diagram_type, diagram_content, diagram_options = nil)
    raise l('errors.missing_diagram_type') if diagram_type.nil? || diagram_type.empty?
    raise l('errors.missing_kroki_url') if kroki_url.nil? || kroki_url.empty?

    res = send_kroki_request(kroki_url, diagram_type, diagram_content, diagram_options)

    raise "#{l('errors.unknown_diagram_type')} \"#{diagram_type}\"" if res.code == '404'
    raise "#{l('errors.syntax_error')}#{res.body}" if res.code == '400'

    res.body
  end

  def send_kroki_request(kroki_url, diagram_type, diagram_content, diagram_options = nil)
    type = diagram_type.downcase.delete(' -')
    url = URI.parse("#{kroki_url}/#{type}/svg")
    http = Net::HTTP.new(url.host, url.port)
    req = Net::HTTP::Post.new(url.path)

    req.content_type = 'text/plain'
    req.body = sanitize_diagram(diagram_type, diagram_content)
    add_diagram_options(req, diagram_options) unless diagram_options.nil?

    http.request(req)
  end
end

def sanitize_diagram(diagram_type, diagram_content)
  return diagram_content.tr("\r", "\n") \
    if diagram_type == 'nomnoml' && !diagram_content.nil?

  diagram_content
end

def add_diagram_options(request, options)
  options.each do |k, v|
    request.add_field("Kroki-Diagram-Options-#{k.to_s.downcase.capitalize}", v) \
      unless PLUGIN_OPTIONS.include?(k)
  end
end

def parse_macro_options(options)
  return nil if options.empty?

  options.map { |option| option.split('=') }.to_h.transform_keys(&:to_sym)
end

def wrap_diagram(diagram, classes, options)
  version = Redmine::Plugin.registered_plugins[:redmine_kroki].version
  href = "/plugin_assets/redmine_kroki/stylesheets/redmine-kroki.css?v=#{version}"
  style_tag = "<link rel='stylesheet' type='text/css' href='#{href}' />"
  styles = convert_options_to_style(options)
  classes = classes.dup << ' resized' unless styles.empty?

  "#{style_tag}<div class=\"#{classes}\" style=\"#{styles}\">#{diagram}</div>"
end

def only_digits?(value)
  !!value.match?(/\A\d+\z/)
end

def convert_options_to_style(options)
  return '' if options.nil?

  plugin_options = options.select do |k, v|
    PLUGIN_OPTIONS.include?(k) && only_digits?(v)
  end

  return '' if plugin_options.empty?

  style = ''.dup
  plugin_options.reduce(style) do |acc, (k, v)|
    acc << "#{plugin_option_css_rule(k)}: #{v}px; "
  end

  style.strip
end

def plugin_option_css_rule(key)
  key == :max_width ? key.to_s.gsub('_', '-') : key.to_s.split('_').last
end

def css_class(is_dark_forced, dark_themes, user_theme)
  return 'kroki' unless user_theme && dark_themes.include?(user_theme) ||
                        is_dark_forced

  'kroki dark'
end

def get_user_theme(user)
  user.preference.respond_to?('theme') ? user.preference.theme : nil
end
