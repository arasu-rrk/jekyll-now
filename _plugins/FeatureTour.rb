module Jekyll
  module Tags
    class SingleColumn < Liquid::Block
      
	  def initialize(tag_name, markup, tokens)
        super
        @markup = markup
		@testHAsh=Hash[markup.split(",").collect{|x| x.strip.split("=")}]
      end
      
	  def render(context)
		"<div class=\"row\">\n#{Kramdown::Document.new(super).to_html}\n</div>\n<hr />"
	  end
    end
  end
end

Liquid::Template.register_tag('col_1', Jekyll::Tags::SingleColumn)

module Jekyll
  module Tags
    class TwoColumn < Liquid::Block
      
	  def initialize(tag_name, markup, tokens)
        super
        @markup = markup
      end
	  
      def render(context)
				output=""
		values = super.split(/^!(.+)/)
		values.each do |value|
			if value.length > 1
				if ((value.match(/^\[(.+)/))&& (value.include? "(images/"))
					value="!"+value
				end
				output += "<div class=\"col-lg-6 col-md-6 col-sm-12 col-xs-12\">\n#{Kramdown::Document.new(value).to_html}\n</div>\n"
			end
		end
		#output = "\n<div class=\"image\">#{Kramdown::Document.new(super).to_html}</div>\n"
        "<div class=\"row\">\n#{output}\n</div>\n<hr />"
      end
    end
  end
end

Liquid::Template.register_tag('col_2', Jekyll::Tags::TwoColumn)

module Jekyll
  module Tags
    class OneColumnParallelImage < Liquid::Block
      
	  def initialize(tag_name, markup, tokens)
        super
        @markup = markup
      end
	  
      def render(context)
		output = ""
		image = Array.new  
		appended = false
		values = super.split(/^!(.+)/)
		values.each do |value|
			if value.length > 1
				if ((value.match(/^\[(.+)/))&& (value.include? "(images/"))
					value="!"+value
					image.push(value)
				end
				if image.count==3 && !appended
					output += "<ul class=\"row\">\n"
					image.each do|img|
						output += "<li class=\"col-lg-4 col-md-4 col-sm-12 col-xs-12\">\n#{Kramdown::Document.new(img).to_html}\n</li>\n"
					end
					output += "</ul>\n"
					appended=true
				end
				if !value.match(/^!(.+)/)
					output += "<div class=\"col-lg-12 col-md-12 col-sm-12 col-xs-12\">\n#{Kramdown::Document.new(value).to_html}\n</div>\n"
				end
			end
		end
		#output = "\n<div class=\"image\">#{Kramdown::Document.new(super).to_html}</div>\n"
        "<div class=\"row\">\n#{output}\n</div>"
      end
    end
  end
end

Liquid::Template.register_tag('col_1_parallel', Jekyll::Tags::OneColumnParallelImage)

module Jekyll
  module Tags
    class TwoColumnParallelImage < Liquid::Block
      
	  def initialize(tag_name, markup, tokens)
        super
        @markup = markup
      end
	  
      def render(context)
		output = ""
		image = Array.new  
		appended = false
		values = super.split(/^!(.+)/)
		values.each do |value|
			if value.length > 1
				if ((value.match(/^\[(.+)/))&& (value.include? "(images/"))
					value="!"+value
					image.push(value)
				end
				if image.count==2 && !appended
					output += "<ul class=\"row\">\n"
					image.each do|img|
						output += "<li class=\"col-lg-6 col-md-6 col-sm-12 col-xs-12\">\n#{Kramdown::Document.new(img).to_html}\n</li>\n"
					end
					output += "</ul>\n"
					appended=true
				end
				if !value.match(/^!(.+)/)
					output += "<div class=\"col-lg-12 col-md-12 col-sm-12 col-xs-12\">\n#{Kramdown::Document.new(value).to_html}\n</div>\n"
				end
			end
		end
		#output = "\n<div class=\"image\">#{Kramdown::Document.new(super).to_html}</div>\n"
        "<div class=\"row\">\n#{output}\n</div>"
      end
    end
  end
end

Liquid::Template.register_tag('col_2_parallel', Jekyll::Tags::TwoColumnParallelImage)