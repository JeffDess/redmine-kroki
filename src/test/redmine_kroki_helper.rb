# frozen_string_literal: true

require File.expand_path('../app/helpers/redmine_kroki_helper.rb', __dir__)
require File.expand_path("#{File.dirname(__FILE__)}/../../../test/test_helper")

# Integration tests with Kroki Server
class RedmineKrokiHelperTest < ActionView::TestCase
  url = 'http://kroki:8000'
  def RedmineKrokiHelper.l
    'error'
  end

  test 'convert_diagram with invalid diagram type raises' do
    error = assert_raises(RuntimeError) do
      convert_diagram(url, 'invalid', 'blockdiag {a -> b}')
    end
    assert_equal 'Unknown diagram type "invalid"', error.message
  end

  test 'convert_diagram with invalid diagram content raises' do
    error = assert_raises(RuntimeError) do
      convert_diagram(url, 'mermaid', '{a -->')
    end
    assert_match(/^Syntax error:/, error.message)
  end

  test 'convert_diagram with no diagram type raises' do
    error = assert_raises(RuntimeError) do
      convert_diagram(url, nil, 'blockdiag {a --> b}')
    end

    assert_equal 'Missing diagram type', error.message
  end

  test 'convert_diagram with empty diagram type raises' do
    error = assert_raises(RuntimeError) do
      convert_diagram(url, '', 'blockdiag {a --> b}')
    end
    assert_equal 'Missing diagram type', error.message
  end

  test 'convert_diagram with no diagram content raises' do
    error = assert_raises(RuntimeError, /Missing/) do
      convert_diagram(url, 'mermaid', nil)
    end
    assert_match(/Request body must not be empty/, error.message)
  end

  test 'convert_diagram with empty diagram content raises' do
    error = assert_raises(RuntimeError, /Missing/) do
      convert_diagram(url, 'mermaid', '')
    end
    assert_match(/Request body must not be empty/, error.message)
  end

  test 'convert_diagram with no url raises' do
    error = assert_raises(RuntimeError, /URL/) do
      convert_diagram(nil, 'mermaid', 'flowchart LR;  a --> b')
    end
    assert_equal 'Missing Kroki URL', error.message
  end

  test 'convert_diagram with empty url raises' do
    error = assert_raises(RuntimeError, /URL/) do
      convert_diagram('', 'mermaid', 'flowchart LR;  a --> b')
    end
    assert_equal 'Missing Kroki URL', error.message
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

  test 'convert_diagram renders actdiag' do
    diagram = convert_diagram(url, 'actdiag', 'actdiag {a -> b}')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders blockdiag' do
    diagram = convert_diagram(url, 'blockdiag', 'blockdiag {a -> b}')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders bytefield' do
    diagram = convert_diagram(url, 'bytefield', '
        (defattrs :bg-green {:fill "#a0ffa0"})

        (defn draw-group-label-header
          [span label]
          (draw-box (text label [:math {:font-size 12}]) {:span span :borders #{} :height 14}))

        (draw-box 0x11)
        (draw-box (text "length" [:math] [:sub 2]) {:span 4})
        (draw-box 0x14)
        (draw-box (text "length" [:math] [:sub 2]) {:span 4})
        (draw-gap "Unknown bytes" {:min-label-columns 6})
        (draw-bottom)
      ')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders C4' do
    diagram = convert_diagram(url, 'c4plantuml', '!include <C4/C4_Context>
      Person(a, "")')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders D2' do
    diagram = convert_diagram(url, 'd2', 'a -> b')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders DBML' do
    diagram = convert_diagram(url, 'dbml', '
Table users {
  id integer
  username varchar
}

Table posts {
  id integer [primary key]
  title varchar
  user_id integer
}

Ref: posts.user_id > users.id // many-to-one')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders Ditaa' do
    diagram = convert_diagram(url, 'ditaa', "
      +--------+
      |        |
      |  User  |
      |        |
      +--------+
    ")
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders erd' do
    diagram = convert_diagram(url, 'erd', "
      [Person]
      *name
      height
      weight
      +birth_location_id

      [Location]
      *id
      city
      state
      country

      Person *--1 Location
    ")
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders graphviz' do
    diagram = convert_diagram(url, 'graphviz', 'digraph G {a->b}')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders nwdiag' do
    diagram = convert_diagram(url, 'nwdiag', '
      nwdiag {
        network dmz {
          address = "210.x.x.x/24"

          web01 [address = "210.x.x.1"];
          web02 [address = "210.x.x.2"];
        }
        network internal {
          address = "172.x.x.x/24";

          web01 [address = "172.x.x.1"];
          web02 [address = "172.x.x.2"];
          db01;
          db02;
        }
      }
    ')
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

  test 'convert_diagram renders packetDiag' do
    diagram = convert_diagram(url, 'packetdiag', "
      packetdiag {
        colwidth = 32;
        node_height = 72;

        0-15: Source Port;
        16-31: Destination Port;
        32-63: Sequence Number;
        64-95: Acknowledgment Number;
        96-99: Data Offset;
        100-105: Reserved;
        106: URG [rotate = 270];
        107: ACK [rotate = 270];
        108: PSH [rotate = 270];
        109: RST [rotate = 270];
        110: SYN [rotate = 270];
        111: FIN [rotate = 270];
        112-127: Window;
        128-143: Checksum;
        144-159: Urgent Pointer;
        160-191: (Options and Padding);
        192-223: data [colheight = 3];
      }
    ")
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

  test 'convert_diagram renders PlantUML' do
    diagram = convert_diagram(url, 'plantuml', '
      skinparam ranksep 20
      skinparam dpi 125
      skinparam packageTitleAlignment left

      rectangle "Main" {
        (main.view)
        (singleton)
      }
      rectangle "Base" {
        (base.component)
        (component)
        (model)
      }
      rectangle "<b>main.ts</b>" as main_ts

      (component) ..> (base.component)
      main_ts ==> (main.view)
      (main.view) --> (component)
      (main.view) ...> (singleton)
      (singleton) ---> (model)
    ')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders rackdiag' do
    diagram = convert_diagram(url, 'rackdiag', 'rackdiag {2U;1:A}')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders seqdiag' do
    diagram = convert_diagram(url, 'seqdiag', 'seqdiag {a -> b}')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders structurizr' do
    diagram = convert_diagram(url, 'structurizr', '
       workspace {
          model {
              user = person "User"
              softwareSystem = softwareSystem "Software System" {
                  webapp = container "Web Application" {
                      user -> this "Uses!!!"
                  }
                  database = container "Database" {
                      webapp -> this "Reads from and writes to"
                  }
              }
          }
          views {
              systemContext softwareSystem {
                  include *
                  autolayout lr
              }
              container softwareSystem {
                  include *
                  autolayout lr
              }
              theme default
          }
      }
    ')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders svgbob' do
    diagram = convert_diagram(url, 'svgbob', "
                      .-,(  ),-.
      ___  *.-(          )-.
      [___]|=| -->(                )      __________
      /::/ |*|     '-(          ).-' --->[_...__... ]
                      '-.( ).-'
                              \      ____   __
                              '--->|    | |==|
                                    |____| |  |
                                    /::::/ |__|
    ")
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders symbolator' do
    diagram = convert_diagram(url, 'symbolator', '
      module demo_device #(
          //# {{}}
          parameter SIZE = 8,
          parameter RESET_ACTIVE_LEVEL = 1
      ) (
          //# {{clocks|Clocking}}
          input wire clock,
          //# {{control|Control signals}}
          input wire reset,
          input wire enable,
          //# {{data|Data ports}}
          input wire [SIZE-1:0] data_in,
          output wire [SIZE-1:0] data_out
      );
        // ...
      endmodule
    ')
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

  test 'convert_diagram renders wavedrom' do
    diagram = convert_diagram(url, 'wavedrom', '{
      signal: [
        { name: "clk",         wave: "p.....|..." },
        { name: "Data",        wave: "x.345x|=.x", data: ["head", "body", "tail", "data"] },
        { name: "Request",     wave: "0.1..0|1.0" },
        {},
        { name: "Acknowledge", wave: "1.....|01." }
      ]
    }')
    assert_match(/<svg/, diagram)
  end

  test 'convert_diagram renders wireviz' do
    diagram = convert_diagram(url, 'wireviz', '
      connectors:
        X1:
          type: D-Sub
          subtype: female
          pinlabels: [DCD, RX, TX, DTR, GND, DSR, RTS, CTS, RI]
        X2:
          type: Molex KK 254
          subtype: female
          pinlabels: [GND, RX, TX]

      cables:
        W1:
          gauge: 0.25 mm2
          length: 0.2
          color_code: DIN
          wirecount: 3
          shield: true

      connections:
        -
          - X1: [5,2,3]
          - W1: [1,2,3]
          - X2: [1,3,2]
        -
          - X1: 5
          - W1: s
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

  test 'convert_options_to_style returns correct max-height' do
    result = convert_options_to_style({ max_height: '1' })

    assert_equal('height: 1px;', result)
  end

  test 'convert_options_to_style returns correct max-width' do
    result = convert_options_to_style({ max_width: '1' })

    assert_equal('max-width: 1px;', result)
  end

  test 'convert_options_to_style returns correct both max-height & max-width' do
    result = convert_options_to_style({ max_height: '1', max_width: '2' })

    assert_equal('height: 1px; max-width: 2px;', result)
  end

  test 'convert_options_to_style with no options returns empty string' do
    result = convert_options_to_style(nil)

    assert_equal('', result)
  end

  test 'convert_options_to_style with diagram option returns empty string' do
    result = convert_options_to_style({ key1: 'value1' })

    assert_equal('', result)
  end

  test 'only_digits? with one digit returns true' do
    assert_equal(true, only_digits?('1'))
  end

  test 'only_digits? with multi-digits returns true' do
    assert_equal(true, only_digits?('123456'))
  end

  test 'only_digits? with % returns false' do
    assert_equal(false, only_digits?('1%'))
  end

  test 'only_digits? with px returns false' do
    assert_equal(false, only_digits?('1px'))
  end

  test 'only_digits? with multi-digit % returns false' do
    assert_equal(false, only_digits?('123456%'))
  end

  test 'only_digits? with multi-digit px returns false' do
    assert_equal(false, only_digits?('123456px'))
  end
end
