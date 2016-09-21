require 'kramdown'
module Tags
    class TabsBlock < Liquid::Block
        def render(context)
			content = super(context)
			content = convert(content)
        end
		def convert(context)
			liArray = context.gsub(/<li role="presentation" class="">(.+)<\/li>/)
			nextLine = "\n"
			tabOpenTag = nextLine + '<div class="tabs">' + nextLine
			ulOpenTag = nextLine + '<ul class="nav nav-tabs" role="tablist">' + nextLine
			tabContentOpenTag = nextLine + '<div class="tab-content">' + nextLine
			closedivTag = nextLine + '</div>' + nextLine
			ulCloseTag = nextLine + '</ul>' + nextLine
			lis = '' + nextLine
			liArray.each do|li|
				lis = lis + li + nextLine
			end		
			return tabOpenTag + ulOpenTag + lis + ulCloseTag + tabContentOpenTag +context.gsub(/<li role="presentation" class="">(.+)<\/li>/,'') + closedivTag + ulCloseTag + closedivTag
		end
    end
end

Liquid::Template.register_tag("tabs", Tags::TabsBlock)