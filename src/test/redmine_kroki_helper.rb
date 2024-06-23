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

  test 'convert_diagram with uppercase in diagram type still renders' do
    diagram = convert_diagram(url, 'Mermaid', 'flowchart LR;  a --> b')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram with spaces in diagram type still renders' do
    diagram = convert_diagram(url, 'c4 plantuml', '!include <C4/C4_Context>
      Person(a, "")')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram with hypen in diagram type still renders' do
    diagram = convert_diagram(url, 'vega-lite', '{
      "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
      "data": { "values": [{"name": 1, "value": 1}] },
      "mark": "arc"
    }')
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

  test 'convert_diagram renders seqdiag' do
    diagram = convert_diagram(url, 'seqdiag', 'seqdiag {a -> b}')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders actdiag' do
    diagram = convert_diagram(url, 'actdiag', 'actdiag {a -> b}')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders rackdiag' do
    diagram = convert_diagram(url, 'rackdiag', 'rackdiag {2U;1:A}')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders D2' do
    diagram = convert_diagram(url, 'd2', 'a -> b')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders C4' do
    diagram = convert_diagram(url, 'c4plantuml', '!include <C4/C4_Context>
      Person(a, "")')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders vegalite' do
    diagram = convert_diagram(url, 'vegalite', '{
      "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
      "data": { "values": [{"name": 1, "value": 1}] },
      "mark": "arc"
    }')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders nomnoml' do
    diagram = convert_diagram(url, 'nomnoml', '
      [Pirate|eyeCount: Int|raid();pillage()|
        [beard]--[parrot]
        [beard]-:>[foul mouth]
      ]

      [<abstract>Marauder]<:--[Pirate]
      [Pirate]- 0..7[mischief]
      [jollyness]->[Pirate]
      [jollyness]->[rum]
      [jollyness]->[singing]
      [Pirate]-> *[rum|tastiness: Int|swig()]
      [Pirate]->[singing]
      [singing]<->[rum]
    ')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders pikchr' do
    diagram = convert_diagram(url, 'pikchr', '
      $r = 0.2in
      linerad = 0.75*$r
      linewid = 0.25

      # Start and end blocks
      #
      box "element" bold fit
      line down 50% from last box.sw
      dot rad 250% color black
      X0: last.e + (0.3,0)
      arrow from last dot to X0
      move right 3.9in
      box wid 5% ht 25% fill black
      X9: last.w - (0.3,0)
      arrow from X9 to last box.w


      # The main rule that goes straight through from start to finish
      #
      box "object-definition" italic fit at 11/16 way between X0 and X9
      arrow to X9
      arrow from X0 to last box.w

      # The LABEL: rule
      #
      arrow right $r from X0 then down 1.25*$r then right $r
      oval " LABEL " fit
      arrow 50%
      oval "\":\"" fit
      arrow 200%
      box "position" italic fit
      arrow
      line right until even with X9 - ($r,0) \
        then up until even with X9 then to X9
      arrow from last oval.e right $r*0.5 then up $r*0.8 right $r*0.8
      line up $r*0.45 right $r*0.45 then right

      # The VARIABLE = rule
      #
      arrow right $r from X0 then down 2.5*$r then right $r
      oval " VARIABLE " fit
      arrow 70%
      box "assignment-operator" italic fit
      arrow 70%
      box "expr" italic fit
      line right until even with X9 - ($r,0) \
        then up until even with X9 then to X9

      # The PRINT rule
      #
      arrow right $r from X0 then down 3.75*$r then right $r
      oval "\"print\"" fit
      arrow
      box "print-args" italic fit
      line right until even with X9 - ($r,0) \
        then up until even with X9 then to X9
    ')
    assert_match(/<svg/, diagram)
  end

  test 'add_diagram_options appends single headers to request' do
    req = Net::HTTP::Get.new('http://test.test')
    add_diagram_options(req, { key: 'value' })
    assert_equal('value', req['Kroki-Diagram-Options-Key'])
  end

  test 'add_diagram_options with multiple headers appends them all to request' do
    req = Net::HTTP::Get.new('http://test.test')
    add_diagram_options(req, { key1: 'value1', key2: 'value2' })
    assert_equal('value1', req['Kroki-Diagram-Options-Key1'])
    assert_equal('value2', req['Kroki-Diagram-Options-Key2'])
  end

  test 'add_diagram_options with plugin options does not append to request' do
    req = Net::HTTP::Get.new('http://test.test')
    add_diagram_options(req, { max_height: '1px', max_width: '1px' })
    assert_nil(req['Kroki-Diagram-Options-Max_height'])
    assert_nil(req['Kroki-Diagram-Options-Max_width'])
  end

  test 'parse_macro_options returns correct values' do
    options = ['key1=value1', 'key2=value2']

    result = parse_macro_options(options)

    assert_equal({ key1: 'value1', key2: 'value2' }, result)
  end

  test 'parse_macro_options returns nil if no options' do
    options = []

    result = parse_macro_options(options)

    assert_nil(result)
  end
end
