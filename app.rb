require 'sinatra'
require 'dotenv/load'
require 'contentful'
require 'json'
require 'rich_text_renderer'

require_relative './config/settings'
require_relative './helpers/contentful_helpers'

helpers Helpers::ContentfulHelpers

get '/' do
  entries = client.entries(content_type: 'post')
  erb :index, locals: { entries: entries }
end

get '/about' do
  erb :about
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

get '/posts/tags/:id' do
  entries = client.entries(
    content_type: 'post',
    links_to_entry: params[:id]
  )
  erb :'posts/tag', locals: { entries: entries }
end

# Contentful allows previewing entries in an iframe on their site.
# To enable this, we need to adjust the security headers accordingly.
# Also I'm validating the preview token passed in the URL.
#
get '/posts/preview/:id' do
  headers 'X-Frame-Options' => '',
          'Content-Security-Policy' => "frame-ancestors 'self' https://app.contentful.com"

  url_preview_token = params['preview_token']
  if url_preview_token.to_s.empty?
    halt 401, 'Unauthorized: Missing preview token'
  elsif url_preview_token != ENV['CONTENTFUL_PREVIEW_ACCESS_TOKEN']
    halt 403, 'Forbidden: Invalid preview token'
  else
    entry = client.entry(params[:id])
    content = rich_text_renderer.render(entry.fields[:content])
    erb :post, locals: { title: entry.fields[:title], content: content }
  end
end
