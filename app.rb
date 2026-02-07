require 'sinatra'
require 'dotenv/load'
require 'contentful'
require 'json'
require 'rich_text_renderer'

set :show_exceptions, false

class PreCodeRenderer
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
    @rich_text_renderer ||= RichTextRenderer::Renderer.new('code' => PreCodeRenderer)
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
