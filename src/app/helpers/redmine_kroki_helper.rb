# frozen_string_literal: true

# Utility functions for the Redmine-Kroki plugin
module RedmineKrokiHelper
  require 'net/http'
  require 'uri'

  def send_kroki_request(diagram_type, diagram_content)
    raise 'Missing diagram type' if diagram_type.nil?

    endpoint = Setting.plugin_redmine_kroki['kroki_url']
    url = URI.parse("#{endpoint}/#{diagram_type}/svg")
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Post.new(url.path)

    request.content_type = 'text/plain'
    request.body = diagram_content

    response = http.request(request)

    raise "Cannot find the diagram \"#{diagram_type}\"" if response.code == '404'

    response.body
  end
end
