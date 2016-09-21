module Jekyll
  module Tags
    class HighlightBlock < Liquid::Block
      include Liquid::StandardFilters

      # The regular expression syntax checker. Start with the language specifier.
      # Follow that by zero or more space separated options that take one of three
      # forms: name, name=value, or name="<quoted list>"
      #
      # <quoted list> is a space-separated list of numbers
      SYNTAX = /^([a-zA-Z0-9.+#-]+)((\s+\w+(=(\w+|"([0-9]+\s)*[0-9]+"))?)*)$/

      def initialize(tag_name, markup, tokens)
        super
        if markup.strip =~ SYNTAX
          @lang = $1.downcase
		  @displayLanguage = @lang.to_s.gsub("+", "-")
		  originalLang(@displayLanguage.downcase)
		  if(@lang.to_s.gsub("+", "-").downcase == "cshtml"||@lang.to_s.gsub("+", "-").downcase == "razor")
			@lang = "aspx-cs"
		  elsif(@lang.to_s.gsub("+", "-").downcase == "vb"||@lang.to_s.gsub("+", "-").downcase == "vb.net")
			@lang = "vbnet"
		  elsif(@lang.to_s.gsub("+", "-").downcase == "web.config" || @lang.to_s.gsub("+", "-").downcase == "xaml")
			@lang = "xml"
		  elsif(@lang.to_s.gsub("+", "-").downcase == "c#" || @lang.to_s.gsub("+", "-").downcase == "cs")
			@lang = "csharp"
		  end
          @options = {}
          if defined?($2) && $2 != ''
            # Split along 3 possible forms -- key="<quoted list>", key=value, or key
            $2.scan(/(?:\w="[^"]*"|\w=\w|\w)+/) do |opt|
              key, value = opt.split('=')
              # If a quoted list, convert to array
              if value && value.include?("\"")
                  value.gsub!(/"/, "")
                  value = value.split
              end
              @options[key.to_sym] = value || true
            end
          end
          @options[:linenos] = "inline" if @options.key?(:linenos) and @options[:linenos] == true
        else
          raise SyntaxError.new <<-eos
Syntax Error in tag 'highlight' while parsing the following markup:

  #{markup}

Valid syntax: highlight <lang> [linenos]
eos
        end
      end

      def render(context)
        prefix = context["highlighter_prefix"] || ""
        suffix = context["highlighter_suffix"] || ""
        code = super.to_s.strip

        is_safe = !!context.registers[:site].safe

        output =
          case context.registers[:site].highlighter
            when 'pygments'
              render_pygments(code, is_safe)
            when 'rouge'
              render_rouge(code)
            else
              render_codehighlighter(code)
            end
		id = Array.new(32){rand(36).to_s(36)}.join
		prefix = prefix + '<li role="presentation" class=""><a data-target="#'+ id + "-" + @lang.to_s.gsub("+", "-") +'" aria-controls="home" role="tab" data-toggle="tab" data-original-lang="'+@originalLang+'">'+ @displayLanguage +'</a></li>'
        prefix = prefix + '<div role="tabpanel" class="tab-pane" id="'+ id + "-" + @lang.to_s.gsub("+", "-") +'" data-original-lang = "'+@originalLang+'" >' 
		suffix = suffix + '</div>'
		rendered_output = add_code_tag(output)
        prefix + rendered_output + suffix
      end

      def sanitized_opts(opts, is_safe)
        if is_safe
          Hash[[
            [:startinline, opts.fetch(:startinline, nil)],
            [:hl_linenos,  opts.fetch(:hl_linenos, nil)],
            [:linenos,     opts.fetch(:linenos, nil)],
            [:encoding,    opts.fetch(:encoding, 'utf-8')],
            [:cssclass,    opts.fetch(:cssclass, nil)]
          ].reject {|f| f.last.nil? }]
        else
          opts
        end
      end

      def render_pygments(code, is_safe)
        require 'pygments'
		
        @options[:encoding] = 'utf-8'

        highlighted_code = Pygments.highlight(
          code,
          :lexer   => @lang,
          :options => sanitized_opts(@options, is_safe)
        )

        if highlighted_code.nil?
          Jekyll.logger.error "There was an error highlighting your code:"
          puts
          Jekyll.logger.error code
          puts
          Jekyll.logger.error "While attempting to convert the above code, Pygments.rb" +
            " returned an unacceptable value."
          Jekyll.logger.error "This is usually a timeout problem solved by running `jekyll build` again."
          raise ArgumentError.new("Pygments.rb returned an unacceptable value when attempting to highlight some code.")
        end

        highlighted_code
      end

      def render_rouge(code)
        require 'rouge'
        formatter = Rouge::Formatters::HTML.new(line_numbers: @options[:linenos], wrap: false)
        lexer = Rouge::Lexer.find_fancy(@lang, code) || Rouge::Lexers::PlainText
        code = formatter.format(lexer.lex(code))
        "<div class=\"highlight\"><pre>#{code}</pre></div>"
      end

      def render_codehighlighter(code)
        "<div class=\"highlight\"><pre>#{h(code).strip}</pre></div>"
      end

      def add_code_tag(code)
        # Add nested <code> tags to code blocks
        code = code.sub(/<pre>\n*/,'<pre><code class="language-' + @lang.to_s.gsub("+", "-") + '" data-lang="' + @lang.to_s + '">')
        code = code.sub(/\n*<\/pre>/,"</code></pre>")
        code.strip
      end
	  
	  def originalLang(displayLanguage)
		case displayLanguage
			when "f#"
				@originalLang = "fsharp"
			when "c++"
				@originalLang = "cpp"
			when "c#" , "cs" 
				@originalLang = "csharp"
			when "vb.net" , "vbnet"
				@originalLang = "vb"
			when "web.config" , "config"
				@originalLang = "config"
			when "java script" , "javascript"
				@originalLang = "js"
			when "objectivec" , "objective c" , "obj-c" , "objc"
				@originalLang = "objective-c"
			when "aspx-cs" , "aspxcs"
				@originalLang = "aspx"
			when "cshtml" , "razor"
				@originalLang = "razor"
			when "aspx-cs" , "aspxcs"
				@originalLang = "aspx"
			when "angularjs" , "angular js"
				@originalLang = "angular-js"
			when "nodejs" , "node js"
				@originalLang = "node-js"
			when "knockdownjs" , "knock down js", "Knock-down-js"
				@originalLang = "knockdown-js"
			else 
				@originalLang = displayLanguage	
		end
	  end
    end
  end
end

Liquid::Template.register_tag('highlight', Jekyll::Tags::HighlightBlock)
