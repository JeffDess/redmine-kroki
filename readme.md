# Redmine-Kroki Plugin

This plugin renders plain text diagrams to images in Redmine issues and
wiki pages.

![PlantUML Mindmap Example](doc/img/wiki-plantuml_mindmap.png)

## Features

* 📊 Renders 30+ diagram types including Mermaid, PlantUML, BPMN, Excalidraw and
  Draw.io/Diagrams.net (experimental).
* 🎨 Customize the look and feel with diagram options.
* 🌘 Auto dark mode on diagrams, everything stays readable.
* 🚀 Offloads the rendering of diagrams to external servers. No dependencies
to download.
* 🙈 Kroki URL is not disclosed in the frontend, so public instances can
keep their server secret.
* 📥 Embeds SVG markup in the page, so it's versioned at every save and
there are no files to deal with!

## Prerequisites

* A Redmine installation (v5 or v6, untested with earlier versions)
* A Kroki server with optional services (Mermaid, BPML, Excalidraw and
  Diagrams.net)

### Suggested setup

The easiest way to get this initial setup is to run your Redmine instance along
with the Kroki servers from a Docker Compose project (you can just include the
[compose.kroki](compose.kroki.yml) file in your existing project). Have
a look at the [example compose file](doc/compose.example.yml) in the source code
to get you started.

### Other setups

Other options include Podman, Kubernetes, bare metal or external provider. Read
[Kroki documentation](https://docs.kroki.io/kroki/setup/install/) for more
information on how to setup the service. It doesn't really matter how you do it,
just make sure the Kroki server is reachable from your Redmine instance.

## Installation

1. Meet the prerequisites if you haven't done so already.
1. Download a [release](//github.com/JeffDess/redmine-kroki/releases).
1. Extract the archive into the _/plugins_ directory of your Redmine server.
1. Restart your Redmine server.

## Configuration

### Kroki server

Head to _Administration > Plugins > Redmine-Kroki_ and input your Kroki server
URL, including the protocol (_http://_ or _https://_) and the port number
(typically 8000). If you have the suggested setup, then the default configuration
should be working for you, just save the settings without any changes.

   Examples:

* Docker Compose: `http://kroki:8000`
* Local Kroki server: `http://127.0.0.1:8000`
* External provider: `https://example.com:8000`

### Display

You can modify two display settings, both related to dark themes. You can ignore
this section if you aren't using any.

* **Force dark mode**: Invert light and dark colors on all themes. If you have
  a dark theme enforced for everybody on the server, you might want to check
  this box. Default: `false`
* **Dark themes names:** This will apply dark mode only when the theme
  selected by the current user matches one value of the list. This option was
  made with [Redmine Theme Changer](https://github.com/haru/redmine_theme_changer)
  in mind. Enter theme names separated by a single spaces (same as in the path
  `redmine/public/themes/...` in Redmine <= 5 or `redmine/themes/...` in
  Redmine 6).
  Default: `dark-theme redmine-theme-dark`

<details>
  <summary>Visual Example</summary>
  For instance, let's consider this diagram on a light theme:

  ![Mermaid diagram on light background](doc/img/config_light-light.png)

  If you were to apply a dark theme on this page, the lines and text on the
  background would become quite unreadable:

  ![Unreadble Mermaid diagram on dark background](doc/img/config_dark-light.png)

  Let's fix it by adding the theme name in the configuration. If we reload the
  page, we'll get:

  ![Mermaid diagram on dark background](doc/img/config_dark-dark.png)

  Ah, much better! The dark mode changed the colors a bit, but every element
  has adequate contrast.
</details>

## Usage

Input a diagram in a kroki macro and pass the diagram type as the first argument.

### Diagram Type

* Choose from this list of [supported diagram types](https://kroki.io/#support)
  \+ `diagramsnet`
* Enter the diagram type as alpha-numeric characters

### Diagram Options

Optionally, you can add [diagram options](https://docs.kroki.io/kroki/setup/diagram-options/)
to change how the diagram is displayed.

* Enter the options in the format `key=value`
* If a key or a value has more than one word, replace the spaces by a dash and
keep it lowercase (_kebab-case_)
* You can add as many as you want

### Diagram Size

In some situations, diagrams may be too large. You can limit their size with
these options:

* `max_width`: Integer in pixels. The diagram will fill available space
unless the screen is narrower than the provided value.
* `max_height`: Integer in pixels. The diagram will fill the space up
to that limit or until it reaches 100% width.

✅ Correct

```markdown
{{kroki(mermaid)
...
}}

{{kroki(c4plantuml)
...
}}

{{kroki(vegalite)
...
}}

{{kroki(mermaid, theme=dark)
...
}}

{{kroki(mermaid, theme=dark, font-family=serif)
...
}}

{{kroki(mermaid, max_width=500)
...
}}

{{kroki(mermaid, max_height=500)
...
}}

{{kroki(mermaid, theme=dark, max_width=500)
...
}}
```

❌ Incorrect

```markdown
{{kroki
...
}}

{{kroki(mermaid, theme:dark)
...
}}

{{kroki(theme=dark)
...
}}

{{kroki(mermaid theme=dark font-family=serif)
...
}}

{{kroki(mermaid, fontFamily=serif)
...
}}

{{kroki(mermaid, max-width=500px)
...
}}

{{kroki(mermaid, max-width=500%)
...
}}

{{kroki(mermaid, max-width=0)
...
}}
```

## Troubleshooting

1. **The page with the macro loads for a long time then I get an
   error.**

   Most likely, the request times out. Check the Kroki URL in the configuration
   and make sure your Kroki server is running. It could also be linked to
   network condition (such as firewall blocking the request or a server ban).

   Test with `curl <Your Kroki URL>/graphviz/svg --data-raw 'digraph G {A->B}'`
   from your Redmine server and it should return a 200 response within a few
   milliseconds.

1. **When I insert a diagram with the macro, I get a 400 error.**

   You have a syntax error in your diagram, the error message should help you
   to spot it. Review your content and try again.

1. **Most diagram types work, except for
   Mermaid/BPMN/Excalidraw/Diagrams.net.**

   The corresponding service is either not installed, not running or unreachable
   from your Kroki server. Check their status and try again.

If you run into other problems, please feel free to [open an issue](//github.com/JeffDess/redmine-kroki/issues/new/choose).

## Development Environment

### Quickstart

**Prerequisite**: Docker and Docker Compose installed

1. Clone this repository
2. Execute `make run`
3. Visit:
   * Redmine 5: <http://localhost:8085>
   * Redmine 6: <http://localhost:8086>

### Tests

* Tests can be run with `make test`.
* It will spawn test containers so it won't interfere with your development
  environment.
* These containers will keep running after the test has completed, so invoke
  the command again to rerun it quickly.
* When you are done, run `make test-stop` to kill the containers.

## References

* [Kroki.io](https://kroki.io/): Creates diagrams from textual descriptions!
* [Redmine Theme Changer](https://github.com/haru/redmine_theme_changer):
A plugin which lets each user select theme from their account page.
* [BS Redmine theme Dark](https://github.com/martin-svoboda/bs-redmine-theme-dark):
Modern dark theme for Redmine based on material design. This theme was used to
demonstrate dark theme settings.
