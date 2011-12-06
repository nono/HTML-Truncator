# encoding: utf-8
path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
require "html_truncator"


describe HTML_Truncator do
  let(:short_text) { "<p>Foo <b>Bar</b> Baz</p>" }
  let(:long_text)  { "<p>Foo " +  ("<b>Bar Baz</b> " * 100) + "Quux</p>" }
  let(:list_text)  { "<p>Foo:</p><ul>" +  ("<li>Bar Baz</li>\n" * 100) + "</ul>" }

  it "should not modify short text" do
    HTML_Truncator.truncate(short_text, 10).should == short_text
  end

  it "should truncate long text to the given number of words" do
    words = HTML_Truncator.truncate(long_text, 10, :ellipsis => "").gsub(/<[^>]*>/, ' ').split
    words.should have(10).items
    words = HTML_Truncator.truncate(long_text, 11, :ellipsis => "").gsub(/<[^>]*>/, '').split
    words.should have(11).items
  end

  it "should not contains empty DOM nodes" do
    HTML_Truncator.truncate(long_text, 10, :ellipsis => "...").should_not =~ /<b>\s*<\/b>/
    HTML_Truncator.truncate(long_text, 11, :ellipsis => "...").should_not =~ /<b>\s*<\/b>/
    HTML_Truncator.truncate(list_text, 10, :ellipsis => "...").should_not =~ /<li>\s*<\/li>/
    HTML_Truncator.truncate(list_text, 11, :ellipsis => "...").should_not =~ /<li>\s*<\/li>/
  end

  it "should truncate long text with an ellipsis inside the last DOM node" do
    HTML_Truncator.truncate(list_text, 10, :ellipsis => "...").should =~ /\.\.\.<\/li>\s*<\/ul>$/
  end

  it "should accept an ellipsis as last argument (not an options hash)" do
    HTML_Truncator.truncate(long_text, 3, "...").should == "<p>Foo <b>Bar Baz</b>...</p>"
    HTML_Truncator.truncate(long_text, 4, "...").should == "<p>Foo <b>Bar Baz</b> <b>Bar</b>...</p>"
  end

  it "should truncate long text" do
    HTML_Truncator.truncate(long_text, 3, :ellipsis => "...").should == "<p>Foo <b>Bar Baz</b>...</p>"
    HTML_Truncator.truncate(long_text, 4, :ellipsis => "...").should == "<p>Foo <b>Bar Baz</b> <b>Bar</b>...</p>"
    HTML_Truncator.truncate(list_text, 3, :ellipsis => "...").should == "<p>Foo:</p><ul>\n<li>Bar Baz</li>\n<li>...</li>\n</ul>"
    HTML_Truncator.truncate(list_text, 4, :ellipsis => "...").should == "<p>Foo:</p><ul>\n<li>Bar Baz</li>\n<li>Bar...</li>\n</ul>"
  end

  it "should be possible to truncate with HTML in the ellipsis" do
    HTML_Truncator.truncate(long_text, 2, :ellipsis => ' <a href="/more">...</a>').should == '<p>Foo <b>Bar</b> <a href="/more">...</a></p>'
  end

  it "should preserve spaces inside a node" do
    HTML_Truncator.truncate("<p>bla bla bla bla bla</p>", 2, :ellipsis => "...").should == "<p>bla bla...</p>"
  end

  it "should not bug on pre" do
    HTML_Truncator.truncate("<p>foo bar</p><pre>foo bar</pre>", 3, :ellipsis => "...").should == "<p>foo bar</p><pre>foo</pre>..."
  end

  it "should not bug on françois test" do
    HTML_Truncator.truncate("<p>foo bar</p><pre>foo bar</pre>plop", 3, :ellipsis => "...").should == "<p>foo bar</p><pre>foo</pre>..."
    HTML_Truncator.truncate("<p>Foo <b>Bar Baz</b> plop<b>Foo Bar</b></p>", 3, :ellipsis => "...").should == "<p>Foo <b>Bar Baz</b>...</p>"
  end

  it "should consider <p> as an element that can contains the ellipsis" do
    HTML_Truncator.ellipsable_tags.should include("p")
  end

  it "should be possible to mark a tag as ellipsable" do
    HTML_Truncator.ellipsable_tags << "blockquote"
    HTML_Truncator.truncate("<blockquote>Foo bar baz quux</blockquote>", 3, :ellipsis => "...").should == "<blockquote>Foo bar baz...</blockquote>"
  end

  it "should not bug on deep nested tags" do
    txt = "<article><ul><li>Foo Bar</li><li><b><u><s>baz</s> quux</u></b></li></ul></article>"
    truncated = HTML_Truncator.truncate(txt, 3, :ellipsis => "...").gsub("\n", "")
    truncated.should == "<article><ul><li>Foo Bar</li><li><b><u><s>baz</s></u></b>...</li></ul></article>"
  end

  it "uses … as the default ellipsis" do
    HTML_Truncator.truncate(long_text, 3).should == "<p>Foo <b>Bar Baz</b>…</p>"
  end

  it "can truncate with a characters length" do
    HTML_Truncator.truncate(long_text, 11, :ellipsis => "...", :length_in_chars => true).should == "<p>Foo <b>Bar Baz</b>...</p>"
    HTML_Truncator.truncate(long_text, 15, :ellipsis => "...", :length_in_chars => true).should == "<p>Foo <b>Bar Baz</b> <b>Bar</b>...</p>"
  end

  it "can truncate with a characters length to the last word before the limit was reached" do
    HTML_Truncator.truncate(long_text, 5, :ellipsis => '...', :length_in_chars => true).should == "<p>Foo...</p>"
    HTML_Truncator.truncate(long_text, 10, :ellipsis => '...', :length_in_chars => true).should == "<p>Foo <b>Bar</b>...</p>"
    HTML_Truncator.truncate(long_text, 14, :ellipsis => '...', :length_in_chars => true).should == "<p>Foo <b>Bar Baz</b>...</p>"
  end

  it "should always truncate at characters length if only a single word is present or length is shorter than the first word" do
    HTML_Truncator.truncate(long_text, 1, :ellipsis => '...', :length_in_chars => true).should == "<p>F...</p>"
    HTML_Truncator.truncate("<p>Honorificabilitudinitatibus</p>", 5, :ellipsis => '...', :length_in_chars => true).should == "<p>Honor...</p>"
  end

  it "says if a string was truncated" do
    HTML_Truncator.truncate(short_text, 10).should_not be_html_truncated
    HTML_Truncator.truncate(long_text, 10).should be_html_truncated
  end

  it "doesn't unescape html entities" do
    txt = <<EOS
<p>Dans le wiki, le \"titre\" <strong>Log des modifications</strong> s'étale sur toute la largeur de l'écran et la barre de saisie dépasse allégrement la taille dudit écran.<br />
Je pense qu'ils devraient être en fait même sur la même ligne… Sans doute un problème de <em>float</em> ou de <em>display</em>.</p>

<p>Dans les journaux (et sans doute partout ailleurs) <strong>Sujet du commentaire</strong> aussi s'étale trop.</p>

<p>Les paragraphes ne sont pas séparés. Il faut rajouter des <em>margin</em> à &lt;p&gt;…&lt;/p&gt;, sinon quoi les sauts de ligne et retours à la ligne sont indistinguables.</p>
EOS
    HTML_Truncator.truncate(txt, 80).should =~ /&lt;p&gt;…&lt;\/p&gt;/
  end

  it "keeps spaces after links" do
    txt = <<EOS
<p>Depuis 1995 l'humanité est véritablement entrée dans une nouvelle ère. Alors que, depuis l'aube des temps, nous ne savions pas si d'autres planètes existaient autour des étoiles lointaines, voilà que soudain la première d'entre elle était découverte en orbite autour de <a href=\"http://fr.wikipedia.org/wiki/51_Pegasi\">51 Pegasi</a>.<br />
Après 2 500 ans de spéculations nous avions enfin une réponse ! Six siècles après la condamnation à mort de <a href=\"http://fr.wikipedia.org/wiki/Giordano_Bruno\">Giordano Bruno</a> nous savions enfin qu'il avait eu raison ! <a href=\"http://fr.wikipedia.org/wiki/Exoplan%C3%A8te\">Les exoplanètes</a> existent bel et bien et notre système solaire n'est pas une exception cosmique.</p>
EOS
    HTML_Truncator.truncate(txt, 80).should =~ /Les exoplanètes<\/a> existent/
  end

  it "should preserve <br> tags" do
    txt = <<EOS
<p>Bonjour</p>
<blockquote>
On 11/06/11 11:12, JP wrote:<br />
&gt; Nom : JP<br />
&gt; Message : Problème<br />
</blockquote>
EOS
    HTML_Truncator.truncate(txt, 10).should =~ /wrote:<br/
  end

  it "should preserve <img> tags" do
    txt = <<EOS
<p>Bonjour</p>
<img src="/foo.png" />
<p>Foo bar baz</p>
EOS
    HTML_Truncator.truncate(txt, 2).should =~ /<img src="\/foo.png"/
  end
end
