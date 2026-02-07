require_relative '../lib/contentful/custom_code_renderer'

module Helpers
  module ContentfulHelpers
    def client
      @client ||= Contentful::Client.new(
        space: ENV['CONTENTFUL_SPACE_ID'],
        access_token: ENV['CONTENTFUL_ACCESS_TOKEN']
      )
    end

    def rich_text_renderer
      @rich_text_renderer ||= RichTextRenderer::Renderer.new('code' => Lib::Contentful::CustomCodeRenderer)
    end
  end
end
