# frozen_string_literal: true

json.selector '#sites'
json.html render partial: 'sites', layout: false, locals: { site: @site }
