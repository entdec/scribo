# encoding: UTF-8
# frozen_string_literal: true

# Examples:
# = d.input :intake, as: :text, input_html: {value: @retailer.returns_call_to_actions&&@retailer.returns_call_to_actions['intake'], class: 'form-control codemirror', 'data-lang' => 'text/html'}, error: @retailer.errors.messages[:returns_call_to_actions]
# = f.input :settings, as: :text, input_html: {class: 'form-control codemirror', 'data-lang' => 'text/json', value: JSON.pretty_generate(@retailer.settings).html_safe}
class CodeMirrorInput < SimpleForm::Inputs::TextInput
  def input_html_classes
    super.push('codemirror')
  end

  def input(wrapper_options = nil)
    template.content_tag(:div, class: 'code-mirror-input') do
      template.concat super
      template.concat template.content_tag('span', 'cmd-F/ctrl-f: search; alt-g: goto line, ctrl-space: autocomplete')
    end
  end
end
