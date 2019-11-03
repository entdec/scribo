# frozen_string_literal: true

if @parent
  json.selector "li.entry.directory[data-content=\"#{@parent.id}\"]"
  json.html render partial: 'scribo/shared/entry', layout: false, formats: [:html], locals: { site: @site, content: @parent }
else
  json.selector '.tree-view'
  json.html render partial: 'scribo/shared/tree-view', layout: false, locals: { site: @site }
end
