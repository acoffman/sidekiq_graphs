module StringHelpers
  def self.constantize(string)
    string.split("::").inject(Module) {|acc, val| acc.const_get(val)}
  end
end
