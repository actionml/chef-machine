module Machine
  module Nomad

    module TemplateMixin
      def write_hcl(json_or_node, opts={})
        spaces = ' ' * (opts[:spaces] || 0)

        lines = []
        json_or_node.inject(lines) do |acm, (key, value)|
          acm << "#{key} = #{value.to_json}"
          acm
        end

        if !lines.empty?
          lines = [lines.first] + lines[1..-1].map {|l| "#{spaces}#{l}"}
          lines.join("\n")
        end
      end
    end

  end
end
