# frozen_string_literal: true

require File.expand_path('../../../lib/kroki_block_indentation.rb', __dir__)
require File.expand_path('../../../app/helpers/redmine_kroki_helper.rb', __dir__)
require File.expand_path('../../../../../test/test_helper', __dir__)

class KrokiBlockIndentationTest < ActiveSupport::TestCase
  test 'preserve inserts marker after kroki opening line' do
    result = KrokiBlockIndentation.preserve("{{kroki(ditaa)\n  +--+\n}}")
    assert_equal("{{kroki(ditaa)\n​  +--+\n}}", result)
  end

  test 'preserve handles CRLF line endings' do
    result = KrokiBlockIndentation.preserve("{{kroki(ditaa)\r\n  +--+\r\n}}")
    assert_equal("{{kroki(ditaa)\r\n​  +--+\r\n}}", result)
  end

  test 'preserve handles macro options' do
    result = KrokiBlockIndentation.preserve("{{kroki(ditaa, max_width=200)\n  +--+\n}}")
    assert_equal("{{kroki(ditaa, max_width=200)\n​  +--+\n}}", result)
  end

  test 'preserve is case insensitive on macro name' do
    result = KrokiBlockIndentation.preserve("{{Kroki(ditaa)\n  +--+\n}}")
    assert_equal("{{Kroki(ditaa)\n​  +--+\n}}", result)
  end

  test 'preserve does not modify escaped kroki macros' do
    input = "!{{kroki(ditaa)\n  +--+\n}}"
    assert_equal(input, KrokiBlockIndentation.preserve(input))
  end

  test 'preserve does not modify other macros' do
    input = "{{collapse(Details)\n  text\n}}"
    assert_equal(input, KrokiBlockIndentation.preserve(input))
  end

  test 'preserve does not modify kroki macros without block' do
    input = '{{kroki(ditaa)}}'
    assert_equal(input, KrokiBlockIndentation.preserve(input))
  end

  test 'restore removes marker and leading blank lines but keeps indentation' do
    result = KrokiBlockIndentation.restore("​\n  \r\n      +--+\n  |  |")
    assert_equal("      +--+\n  |  |", result)
  end

  test 'restore does not modify unmarked text' do
    input = "\n      +--+"
    assert_equal(input, KrokiBlockIndentation.restore(input))
  end

  test 'restore handles nil' do
    assert_nil KrokiBlockIndentation.restore(nil)
  end
end

# Redmine strips macro blocks, which breaks whitespace-sensitive diagrams
class KrokiBlockIndentationApplicationHelperPatchTest < Redmine::HelperTest
  include ERB::Util
  include ApplicationHelper
  include RedmineKrokiHelper

  url = 'http://kroki:8000'
  ditaa = [
    '      +--------+',
    '      |        |',
    '      |  User  |',
    '      |        |',
    '      +--------+',
    '          ^',
    '  request |',
    '          v',
    '  +-------------+',
    '  |    Kroki    |',
    '  +-------------+'
  ].join("\n")
  diagrams = {
    'ditaa' => ditaa,
    'svgbob' => [
      '    .---.',
      '    | A |',
      "    `---'",
      '  .---.',
      '  | B |',
      "  `---'"
    ].join("\n"),
    'goat' => [
      '    +---+',
      '    | A |',
      '    +---+',
      '      |',
      '      v',
      '  +-------+',
      '  |   B   |',
      '  +-------+'
    ].join("\n")
  }

  test 'patch is prepended to ApplicationHelper' do
    assert_includes ApplicationHelper.ancestors, KrokiBlockIndentation::ApplicationHelperPatch
  end

  test 'catch_macros keeps first line indentation through Redmine strip' do
    text = "{{kroki(ditaa)\n\n#{ditaa}\n}}".dup
    macros = catch_macros(text)

    macros[0] =~ ApplicationHelper::MACROS_RE
    assert_equal(ditaa, KrokiBlockIndentation.restore(::Regexp.last_match(7).strip))
  end

  diagrams.each do |type, diagram|
    test "kroki macro renders #{type} with first line indentation" do
      expected = convert_diagram(url, type, diagram)
      refute_equal(expected, convert_diagram(url, type, diagram.strip))

      text = "{{kroki(#{type})\n\n#{diagram}\n}}".dup
      with_settings plugin_redmine_kroki: { kroki_url: url }.with_indifferent_access do
        macros = catch_macros(text)
        inject_macros(text, nil, macros)
      end

      assert_includes text, expected
    end
  end
end
