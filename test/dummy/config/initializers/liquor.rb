# frozen_string_literal: true

Liquidum.setup do |config|
  config.i18n_store = lambda do |context, block|
    Scribo.i18n_store.with(context.registers['content'], &block) if context.registers['content']
  end
end
