require 'sinatra'
require 'dotenv/load'
require 'contentful'
require 'json'
require 'rich_text_renderer'

set :show_exceptions, false

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

helpers do
  def client
    @client ||= Contentful::Client.new(
      space: ENV['CONTENTFUL_SPACE_ID'],
      access_token: ENV['CONTENTFUL_ACCESS_TOKEN']
    )
  end

  def rich_text_renderer
    @rich_text_renderer ||= RichTextRenderer::Renderer.new('code' => CustomCodeRenderer)
  end
end

get '/' do
  entries = client.entries(content_type: 'post')
  erb :index, locals: { entries: entries }
end

get '/posts/:id' do
  entry = client.entry(params[:id])
  content = rich_text_renderer.render(entry.fields[:content])

  if request.accept?('text/html')
    erb :post, locals: { title: entry.fields[:title], content: content }
  elsif request.accept?('application/json')
    content_type :json
    { title: entry.fields[:title], content: content }.to_json
  else
    error 406
  end
end
