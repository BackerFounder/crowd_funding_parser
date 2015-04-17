module MethodBuilder
  def set_methods(&block)
    DefinitionProxy.new.instance_eval(&block)
  end

  class DefinitionProxy
    def insert_class(inserted_class)
      @inserted_class = "CrowdFundingParser::Parser::#{inserted_class}".constantize
    end

    def set_method(method_name, args = [:doc], &block)
      @inserted_class.send(:define_method, method_name) do
        begin
          block.call
        rescue
          ""
        end
      end
    end
  end
end