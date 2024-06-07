# frozen_string_literal: true

require File.expand_path('../app/helpers/redmine_kroki_helper.rb', __dir__)

# Integration tests with Kroki Server
class RedmineKrokiHelperTest < ActionView::TestCase
  url = 'http://kroki:8000'

  test 'convert_diagram with invalid diagram type raises' do
    assert_raises(RuntimeError, /Cannot find the diagram/) do
      convert_diagram(url, 'invalid', 'blockdiag {a -> b}')
    end
  end

  test 'convert_diagram with invalid diagram content raises' do
    assert_raises(RuntimeError, /syntax error/) do
      convert_diagram(url, 'mermaid', '{a -->')
    end
  end

  test 'convert_diagram with no diagram type raises' do
    assert_raises(RuntimeError, /Missing/) do
      convert_diagram(url, nil, 'blockdiag {a --> b}')
    end
  end

  test 'convert_diagram with empty diagram type raises' do
    assert_raises(RuntimeError, /Missing/) do
      convert_diagram(url, '', 'blockdiag {a --> b}')
    end
  end

  test 'convert_diagram with no diagram content raises' do
    assert_raises(RuntimeError, /Missing/) do
      convert_diagram(url, 'mermaid', nil)
    end
  end

  test 'convert_diagram with empty diagram content raises' do
    assert_raises(RuntimeError, /Missing/) do
      convert_diagram(url, 'mermaid', '')
    end
  end

  test 'convert_diagram with no url raises' do
    assert_raises(RuntimeError, /URL/) do
      convert_diagram(nil, 'mermaid', 'flowchart LR;  a --> b')
    end
  end

  test 'convert_diagram with empty url raises' do
    assert_raises(RuntimeError, /URL/) do
      convert_diagram('', 'mermaid', 'flowchart LR;  a --> b')
    end
  end

  test 'convert_diagram renders mermaid' do
    diagram = convert_diagram(url, 'mermaid', 'flowchart LR;  a --> b')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders graphviz' do
    diagram = convert_diagram(url, 'graphviz', 'digraph G {a->b}')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders blockdiag' do
    diagram = convert_diagram(url, 'blockdiag', 'blockdiag {a -> b}')
    assert_match(/<svg/, diagram)
  end
end
