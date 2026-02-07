require 'sinatra'

set :host_authorization, permitted_hosts: ['.fly.dev', '.domsamphier.com', '0.0.0.0']
set :erb, layout: :'layouts/main'
