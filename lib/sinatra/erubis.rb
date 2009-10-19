require 'sinatra/base'
require 'erubis'

module Sinatra
  module ErubisTemplate

    def erubis(template=nil, options={}, locals={}, &block)
      options, template = template, nil if template.is_a?(Hash)
      template = block if template.nil?

      if options[:sublayout]
        orig_layout = options.delete(:layout)

        options[:layout] = options.delete(:sublayout)

        blending = render :erubis, template, options, locals

        template = lambda { blending }

        options[:layout] = orig_layout
        erubis template, options, locals
      else
        render :erubis, template, options, locals
      end
    end

    protected

#    def render_erubis(template, data, options,locals, &block) # <-- v0.9.2
    def render_erubis( data, options, locals, &block )
      options[:preamble]  = false
      options[:postamble] = false
      locals_assigns = locals.to_a.collect { |k,v| "#{k} = locals[:#{k}]" }
      render_binding = binding
      eval locals_assigns.join("\n"), render_binding
      _buf = ""
      ::Erubis::Eruby.new(data, options).result(render_binding) { block }
      _buf
    end

  end

  helpers ErubisTemplate
end
