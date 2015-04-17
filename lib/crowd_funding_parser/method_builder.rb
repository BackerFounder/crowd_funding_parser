module MethodBuilder
  def self.set_methods(&block)
    ParserMethodProxy.new.instance_eval(&block)
  end

  class ParserMethodProxy
    def insert_class(inserted_class)
      @inserted_class = "CrowdFundingParser::Parser::#{inserted_class}".constantize
      @inserted_class_instance = @inserted_class.new
    end

    def set_variable(&block)
      block.call
    end

    def set_method(method_name, &block)
      @inserted_class.send(:define_method, method_name) do |arg|
        begin
          block.call(arg)
        rescue Exception => e
          puts "Error #{e.message}"
          puts e.backtrace.first
          ""
        end
      end
    end

    def get_string(elements)
      elements.first.text.strip
    end

    def money_string(money)
      money.gsub("$","").gsub(",", "").gsub("NT", "")
    end

    def convert_time(left_time)
      days = ((left_time / (60 * 60 * 24))).to_i
      hours = ((left_time / (60 * 60)) % 24).to_i
      minutes = ((left_time / 60) % 60).to_i
      "#{days}天#{hours}小時#{minutes}分鐘"
    end
  end
end