# frozen_string_literal: true

# Utility functions for the Redmine-Kroki plugin
module RedmineKrokiHelper
  require 'net/http'
  require 'uri'

  def convert_diagram(kroki_url, diagram_type, diagram_content)
    raise 'Missing diagram type' if diagram_type.nil? || diagram_type.empty?
    raise 'Missing Kroki URL' if kroki_url.nil? || kroki_url.empty?

    res = send_kroki_request(kroki_url, diagram_type, diagram_content)

    raise "Cannot find the diagram \"#{diagram_type}\"" if res.code == '404'
    raise res.body if res.code == '400'

    res.body
  end

  def send_kroki_request(kroki_url, diagram_type, diagram_content)
    url = URI.parse("#{kroki_url}/#{diagram_type}/svg")
    http = Net::HTTP.new(url.host, url.port)
    req = Net::HTTP::Post.new(url.path)

    req.content_type = 'text/plain'
    req.body = diagram_content

    http.request(req)
  end
end
