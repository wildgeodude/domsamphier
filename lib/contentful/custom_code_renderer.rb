# NOTE(DS): Custom Renderer for 'code' node type
#
# This renderer parses the rich text document for 'code' nodes. For example it's looking for nodes like:
# {
#   "nodeType" => "paragraph",
#   "data" => {},
#   "content" => [
#     {
#       "nodeType" => "text",
#       "value" => "Rails.application.credentials.dig(:facebook, :api_key)",
#       "marks" => [{"type" => "code"}],
#       "data" => {}
#     }
#   ]
# }
#
# When it finds a 'code' mark like this, the renderer looks up 'code' in the mappings, and finds CustomCodeRenderer.
# It then calls `render`, which checks if the text contains a newline; if it does it wraps in <pre><code>, otherwise just <code>.
#
# The `pre` tag preserves whitespace formatting, essential for rendering code blocks correctly.
#
module Lib
  module Contentful
    class CustomCodeRenderer
      def initialize(mappings = {})
        @mappings = mappings
      end

      def render(content, _context = nil)
        text = content.is_a?(Hash) ? (content['value'] || '') : content.to_s

        if text.include?("\n")
          "<pre><code>#{text}</code></pre>"
        else
          "<code>#{text}</code>"
        end
      end
    end
  end
end
