# frozen_string_literal: true

module Lipgloss
  module Immutable
    private

    def dup_with
      copy = self.class.allocate
      instance_variables.each do |iv|
        val = instance_variable_get(iv)
        copy.instance_variable_set(iv, val.is_a?(Array) || val.is_a?(Hash) ? val.dup : val)
      end
      yield copy
      copy
    end
  end
end
