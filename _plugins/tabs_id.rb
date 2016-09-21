require 'kramdown'
require 'nokogiri'
module Jekyll
  class UpcaseConverter < Converter
    safe true
    priority :low

    def matches(ext)
      ext =~ /^\.md$/i
    end

    def output_ext(ext)
      ".html"
    end

    def convert(content)
		content = convert(super(content))
    end
	
	def convert(content)
		doc = Nokogiri::HTML.fragment(content)
		@i=0
		doc.css('div.tabs').each do |tabs|
			@i = @i + 1
			if tabs['id'] == nil
				tabs['id'] = "code-snippet-"+@i.to_s
			end
		end
		return doc.to_s
	end
  end
end