# frozen_string_literal: true

require 'test_helper'

class HighlightTagTest < ActiveSupport::TestCase
  test 'does do highlighting' do
    contents       = scribo_sites(:main).contents
    subject        = contents.create!(path: '/test.html', kind: 'text', data: "{% highlight ruby %}\ndef foo\nputs 'foo\nend\n{% endhighlight %}")

    result = Scribo::ContentRenderService.new(subject, self).call

    assert_equal "<figure class=\"highlight\"><pre><code class=\"language-ruby\" data-lang=\"ruby\"><span class=\"k\">def</span> <span class=\"nf\">foo</span>\n<span class=\"nb\">puts</span> <span class=\"err\">'</span><span class=\"n\">foo</span>\n<span class=\"k\">end</span></code></pre></figure>", result
  end
end
