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