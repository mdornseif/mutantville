module Liquid

  # Strainer is the parent class for the filters system. 
  # New filters are mixed into the strainer class which is then instanciated for each liquid template render run. 
  #
  # One of the strainer's responsibilities is to keep malicious method calls out 
  class Strainer
    @@required_methods = ["__send__", "__id__"]
  
    def self.ok?(method)
      method_name = method.to_s
      return false if method_name =~ /^__/ 
      return false if @@required_methods.include?(method_name)
      return false unless instance_methods.include?(method_name)        
      true
    end
      
    # remove all standard methods from the bucket so circumvent security 
    # problems 
    instance_methods.each do |m| 
      unless @@required_methods.include?(m) 
        undef_method m 
      end
    end
  end
end