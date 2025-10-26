# frozen_string_literal: true

module Utils
  module Callable
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def call(*args, **kwargs, &block)
        new(*args, **kwargs).call(&block)
      end
    end

    def call(&block)
      raise NotImplementedError
    end
  end
end
