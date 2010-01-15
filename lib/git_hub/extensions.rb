class String
  # Turns string into appropriate class constant, returns nil if class not found
  def to_class
    chain = self.split("::")
    chain.shift if chain.first == ''
    klass = chain.inject(Kernel) {|klass, const| klass.const_get const }
    klass.is_a?(Class) ? klass : nil
  rescue NameError
    nil
  end
end