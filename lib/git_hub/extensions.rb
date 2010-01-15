class String
  # Turns string into appropriate class constant, returns nil if class not found
  def to_class
    klass = self.split("::").inject(Kernel) do |namespace, const|
      const == '' ? namespace : namespace.const_get(const)
    end
    klass.is_a?(Class) ? klass : nil
  rescue NameError
    nil
  end
end

class Array

  # Splits (arguments) Array into two components: enum for args and options Hash
  # options Hash (if any) should be the last component of Array
  def args_and_options 
      if self.last.is_a?(Hash)
        [self[0..-2].to_enum, self.last]
      else
        [self.to_enum, {}]
      end
    end
end