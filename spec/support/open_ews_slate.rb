module RspecApiDocumentation
  module Writers
    class OpenEWSSlateWriter < SlateWriter
      def markup_example_class
        OpenEWSSlateExample
      end
    end
  end
end
