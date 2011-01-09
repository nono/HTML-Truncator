HTML Truncator
==============

Wants to truncate an HTML string properly? This gem is for you.
It's powered by [Nokogiri](http://nokogiri.org/)!


How to use it
-------------

It's very simple. Install it with rubygems:

    gem install html_truncator

Or, if you use bundler, add it to your `Gemfile`:

    gem "html_truncator", :version => "~>0.1"

Then you can use it in your code:

    require "html_truncator"
	HTML_Truncator.truncate("<p>Lorem ipsum dolor sit amet.</p>", 3)
	# => "<p>Lorem ipsum dolor...</p>"

The HTML_Truncator class has only one method, `truncate`, with 3 arguments:

* the HTML-formatted string to truncate
* the number of words to keep (real words, tags and attributes aren't count)
* the ellipsis (optional, '...' by default).


Examples
--------

A simple example:

	HTML_Truncator.truncate("<p>Lorem ipsum dolor sit amet.</p>", 3)
	# => "<p>Lorem ipsum dolor...</p>"

If the text is too short to be truncated, it won't be modified:

    HTML_Truncator.truncate("<p>Lorem ipsum dolor sit amet.</p>", 5)
     => "<p>Lorem ipsum dolor sit amet.</p>"

You can customize the ellipsis:

    HTML_Truncator.truncate("<p>Lorem ipsum dolor sit amet.</p>", 3, " (truncated)")
     => "<p>Lorem ipsum dolor (truncated)</p>"

And even have HTML in the ellipsis:

    HTML_Truncator.truncate("<p>Lorem ipsum dolor sit amet.</p>", 3, '<a href="/more-to-read">...</a>')
     => "<p>Lorem ipsum dolor<a href="/more-to-read">...</a></p>"


Alternatives
------------

Rails has a `truncate` helper, but as the doc says:

> Care should be taken if text contains HTML tags or entities,
  because truncation may produce invalid HTML (such as unbalanced or incomplete tags).

I know there are some Ruby code to truncate HTML, like:

* https://github.com/hgimenez/truncate_html
* https://gist.github.com/101410
* http://henrik.nyh.se/2008/01/rails-truncate-html-helper
* http://blog.madebydna.com/all/code/2010/06/04/ruby-helper-to-cleanly-truncate-html.html

But I'm not pleased with these solutions: they are either based on regexp for
parsing the content (too fragile), they don't put the ellipsis where expected,
they cut words and sometimes leave empty DOM nodes. So I made my own gem ;-)


Issues or Suggestions
---------------------

Found an issue or have a suggestion? Please report it on
[Github's issue tracker](http://github.com/nono/HTML-Truncator/issues).

If you wants to make a pull request, please check the specs before:

    rspec spec


Copyright (c) 2011 Bruno Michel <bmichel@menfin.info>, released under the MIT license
