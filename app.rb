require 'sinatra'
require 'dotenv/load'
require 'contentful'
require 'json'
require 'rich_text_renderer'

require_relative './helpers/contentful_helpers'

helpers Helpers::ContentfulHelpers

get '/' do
  entries = client.entries(content_type: 'post')
  erb :index, locals: { entries: entries }, layout: 'layouts/main'.to_sym
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
