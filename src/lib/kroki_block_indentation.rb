# frozen_string_literal: true

# NOTE: Prevent Redmine from stripping leading whitespaces from macro content
# This is particularly important for ditaa, svgbob and GoAT diagrams which are
# more of a drawing than markup
module KrokiBlockIndentation
  MARKER = "\u200B"
  KROKI_BLOCK_OPENING_RE = /\A(\{\{kroki(?:\([^\n\r]*?\))?(?:\r\n|\r|\n))/i
  LEADING_BLANK_LINES_RE = /\A(?:[ \t]*(?:\r\n|\r|\n))+/

  def self.preserve(macro)
    macro.sub(KROKI_BLOCK_OPENING_RE, "\\1#{MARKER}")
  end

  def self.restore(text)
    return text unless text&.start_with?(MARKER)

    text.delete_prefix(MARKER).sub(LEADING_BLANK_LINES_RE, '')
  end

  module ApplicationHelperPatch
    def catch_macros(text)
      super.transform_values! { |macro| KrokiBlockIndentation.preserve(macro) }
    end
  end
end
