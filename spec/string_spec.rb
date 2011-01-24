# encoding: utf-8
path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
require "html_truncator"

describe String do
  let(:short_text) { "<p>Foo <b>Bar</b> Baz</p>" }
  let(:long_text)  { "<p>Foo " +  ("<b>Bar Baz</b> " * 100) + "Quux</p>" }
  let(:list_text)  { "<p>Foo:</p><ul>" +  ("<li>Bar Baz</li>\n" * 100) + "</ul>" }

  it "should not truncate short text" do
    short_text.html_truncate(10).should == short_text
  end

  it "should truncate long text" do
    long_text.html_truncate(3, "...").should == "<p>Foo <b>Bar Baz</b>...</p>"
    long_text.html_truncate(4, "...").should == "<p>Foo <b>Bar Baz</b> <b>Bar</b>...</p>"
    list_text.html_truncate(3, "...").should == "<p>Foo:</p><ul><li>Bar Baz</li>\n<li>...</li>\n</ul>"
    list_text.html_truncate(4, "...").should == "<p>Foo:</p><ul><li>Bar Baz</li>\n<li>Bar...</li></ul>"
  end

  context "#truncated?" do
    it "should be true if truncated" do
      long_text.html_truncate(3, "...").should be_html_truncated
    end

    it "should be false if not truncated" do
      short_text.html_truncate(10).should_not be_html_truncated
    end
  end
end
