# frozen_string_literal: true

require 'test_helper'

class HighlightTagTest < ActiveSupport::TestCase
  test 'does do highlighting' do
    contents       = scribo_sites(:main).contents
    subject        = contents.create!(path: '/test.html', kind: 'text', data: "{% highlight ruby %}\ndef foo\nputs 'foo'\nend\n{% endhighlight %}")

    result = Scribo::ContentRenderService.new(subject, self).call

    assert_equal "<figure class=\"highlight\"><pre><code class=\"language-ruby\" data-lang=\"ruby\"><span class=\"k\">def</span> <span class=\"nf\">foo</span>\n<span class=\"nb\">puts</span> <span class=\"s1\">'foo'</span>\n<span class=\"k\">end</span></code></pre></figure>", result
  end

  test 'does do highlighting too' do
    contents       = scribo_sites(:main).contents

    data = <<~CONTENT
      {% highlight ruby %}
      def print_hi(name)
        puts "Hi, #{name}"
      end
      print_hi('Tom')
      #=> prints 'Hi, Tom' to STDOUT.
      {% endhighlight %}
    CONTENT

    subject        = contents.create!(path: '/test.html', kind: 'text', data: data)

    result = Scribo::ContentRenderService.new(subject, self).call

    assert_equal "<figure class=\"highlight\"><pre><code class=\"language-ruby\" data-lang=\"ruby\"><span class=\"k\">def</span> <span class=\"nf\">print_hi</span><span class=\"p\">(</span><span class=\"nb\">name</span><span class=\"p\">)</span>\n  <span class=\"nb\">puts</span> <span class=\"s2\">\"Hi, test_does_do_highlighting_too\"</span>\n<span class=\"k\">end</span>\n<span class=\"n\">print_hi</span><span class=\"p\">(</span><span class=\"s1\">'Tom'</span><span class=\"p\">)</span>\n<span class=\"c1\">#=&gt; prints 'Hi, Tom' to STDOUT.</span></code></pre></figure>\n", result
  end


end
