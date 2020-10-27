# frozen_string_literal: true

Liquor.setup do |config|
  config.i18n_store = lambda do |context, block|
    if context.registers['content']
      Scribo.i18n_store.with(context.registers['content'], &block)
    end
  end
end
