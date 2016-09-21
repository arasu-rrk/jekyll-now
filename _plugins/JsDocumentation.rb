module Jekyll
  module Tags
    class Content < Liquid::Block
      
	  def initialize(tag_name, markup, tokens)
        super
        @markup = markup
		@attributes = {}
		markup.scan(::Liquid::TagAttributes) do |key, value|
			@attributes[key] = value
		end
      end
      
	  def render(context)
		@context = context
		output = ""
		output = "<div lang=" + @attributes['lang'].to_s + " class=\"row\">\n#{Kramdown::Document.new(super).to_html}\n</div>\n<hr />"
		return output
	  end
	  
    end
  end
end

Liquid::Template.register_tag('content', Jekyll::Tags::Content)