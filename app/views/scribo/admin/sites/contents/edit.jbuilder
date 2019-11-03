# frozen_string_literal: true

json.content do |content|
  content.id @content.id
  content.path @content.path
  content.full_path @content.full_path
  content.url = admin_site_content_path(@site, @content)
end
json.html render partial: 'scribo/admin/sites/contents/form', layout: false, formats: [:html]
