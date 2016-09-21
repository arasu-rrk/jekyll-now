require 'kramdown'

module Jekyll
  class SeeAlso < Liquid::Block
    def render(context)
      "<p class=\"seealso\"><h2 class=\"seealso\">See Also</h2>#{Kramdown::Document.new(super).to_html}</p>"
    end
  end
end
Liquid::Template.register_tag('seealso', Jekyll::SeeAlso)