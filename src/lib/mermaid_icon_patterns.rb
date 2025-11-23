# frozen_string_literal: true

# HACK: Kroki doesn't correctly size boxes with icons, but padding with
# non-breaking spaces fixes most of it.
module MermaidIconPatterns
  PATTERNS = [
  # Double circle - no text ((( fa:fa-icon )))  WARN: Must come before circle
  {
    regex: /(\(\(\()fa:([\w-]+)\s*(\)\)\))/,
    replacement: '\1&nbsp; fa:\2 &nbsp;&nbsp;&nbsp;\3',
  },
  # Double circle - with text ((( fa:fa-icon Text )))  WARN: Must come before circle
  {
    regex: /(\(\(\()fa:([\w-]+)(\s+.*?)(\)\)\))/,
    replacement: '\1&nbsp; fa:\2\3 &nbsp;&nbsp;&nbsp;\4',
  },
  # Circle - no text (( fa:fa-icon ))
  {
    regex: /(\(\()fa:([\w-]+)\s*(\)\))/,
    replacement: '\1&nbsp;&nbsp; fa:\2 &nbsp;&nbsp;&nbsp;&nbsp;\3',
  },
  # Circle - with text (( fa:fa-icon Text ))
  {
    regex: /(\(\()fa:([\w-]+)(\s+.*?)(\)\))/,
    replacement: '\1&nbsp; fa:\2\3 &nbsp;&nbsp;&nbsp;\4',
  },
  # Stadium shapes ([ fa:fa-icon (Text)? ])
  {
    regex: /(\(\[)fa:([\w-]+)(\s+.*?)?(\]\))/,
    replacement: '\1&nbsp; fa:\2\3 &nbsp;&nbsp;\4',
  },
  # Subroutine shapes [[ fa:fa-icon (Text)? ]]
  {
    regex: /(\[\[)fa:([\w-]+)(\s+.*?)?(\]\])/,
    replacement: '\1&nbsp; fa:\2\3 &nbsp;&nbsp;&nbsp;\4',
  },
  # Cylindrical shapes [( fa:fa-icon (Text)? )]
  {
    regex: /(\[\()fa:([\w-]+)(\s+.*?)?(\)\])/,
    replacement: '\1&nbsp; fa:\2\3 &nbsp;&nbsp;&nbsp;\4',
  },
  # Hexagon shapes {{ fa:fa-icon (Text)? }}
  {
    regex: /(\{\{)fa:([\w-]+)(\s+.*?)?(\}\})/,
    replacement: '\1&nbsp;fa:\2\3&nbsp;&nbsp;\4',
  },
  # Parallelogram [/ fa:fa-icon (Text)? /]
  {
    regex: /(\[\/)fa:([\w-]+)(\s+.*?)?(\/\])/,
    replacement: '\1&nbsp;fa:\2\3 &nbsp;\4',
  },
  # Parallelogram [\ fa:fa-icon (Text)? \]
  {
    regex: /(\[\\)fa:([\w-]+)(\s+.*?)?(\\\])/,
    replacement: '\1&nbsp; fa:\2\3 &nbsp;&nbsp;\4',
  },
  # Trapezoid [/ fa:fa-icon (Text)? \]
  {
    regex: /(\[\/)fa:([\w-]+)(\s+.*?)?(\\\])/,
    replacement: '\1&nbsp; fa:\2\3 &nbsp;&nbsp;\4',
  },
  # Trapezoid [\ fa:fa-icon (Text)? /]
  {
    regex: /(\[\\)fa:([\w-]+)(\s+.*?)?(\/\])/,
    replacement: '\1fa:\2\3 &nbsp;\4',
  },
  # Asymmetrical shapes >fa:icon (Text)?]
  {
    regex: /(>)fa:([\w-]+)(\s+.*?)?(\])/,
    replacement: '\1&nbsp;&nbsp;fa:\2\3&nbsp;&nbsp;&nbsp;\4',
  },
  # Rhombus shapes - no text { fa:fa-icon }
  {
    regex: /(\{)fa:([\w-]+)(\s+)?(\})/,
    replacement: '\1&nbsp;&nbsp;fa:\2\3 &nbsp;\4',
  },
  # Rhombus shapes { fa:fa-icon Text }
  {
    regex: /(\{)fa:([\w-]+)(\s+.*?)(\})/,
    replacement: '\1fa:\2\3 &nbsp;&nbsp;\4',
  },
  # Simple shapes with no text  WARN: Must be last!
  {
    regex: /([(\[])fa:([\w-]+)\s*([)\]])/,
    replacement: '\1&nbsp; fa:\2 &nbsp;\3',
  }
  ].freeze
end

MERMAID_SHAPE_ICON_PATTERNS = MermaidIconPatterns::PATTERNS
