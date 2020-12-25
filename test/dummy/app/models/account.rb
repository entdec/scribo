class Account < ApplicationRecord
  scribable

  def current!
    self.class.instance_variable_set(:@account, self)
  end

  class << self
    def current
      instance_variable_get(:@account)
    end

    def reset_current!
      instance_variable_set(:@account, nil)
    end
  end
end
