require 'sinatra'
require 'dotenv/load'
require 'contentful'
require 'json'
require 'rich_text_renderer'

set :show_exceptions, false

helpers do
  def client
    @client ||= client = Contentful::Client.new(
      space: ENV['CONTENTFUL_SPACE_ID'],
      access_token: ENV['CONTENTFUL_ACCESS_TOKEN']
    )
  end
end

get '/' do
  entries = client.entries(content_type: 'post')
  erb :index, locals: { entries: entries }
end

get '/posts/:id' do
  entry = client.entry(params[:id])
  renderer = RichTextRenderer::Renderer.new
  content = renderer.render(entry.fields[:content])
  erb :post, locals: { title: entry.fields[:title], content: content }
end

get '/posts' do
  entries = client.entries(content_type: 'post')
  renderer = RichTextRenderer::Renderer.new
  renderer.render(entries.first.fields[:content])
end
