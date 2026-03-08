# frozen_string_literal: true

target :lib do
  signature "sig"

  check "lib"

  # The pure Ruby implementation uses metaprogramming patterns
  # (define_method, allocate, instance_variable_set) that steep
  # cannot fully type-check. Downgrade these to non-failing levels.
  configure_code_diagnostics do |hash|
    hash[Steep::Diagnostic::Ruby::NoMethod] = :information
    hash[Steep::Diagnostic::Ruby::UnknownConstant] = :information
    hash[Steep::Diagnostic::Ruby::UnannotatedEmptyCollection] = :information
    hash[Steep::Diagnostic::Ruby::UndeclaredMethodDefinition] = :information
    hash[Steep::Diagnostic::Ruby::MethodBodyTypeMismatch] = :information
    hash[Steep::Diagnostic::Ruby::UnexpectedPositionalArgument] = :information
    hash[Steep::Diagnostic::Ruby::ArgumentTypeMismatch] = :information
  end
end
