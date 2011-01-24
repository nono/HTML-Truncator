require "nokogiri"
require "set"


class HTML_Truncator
  def self.truncate(text, max_words, ellipsis="...")
    doc = Nokogiri::HTML::DocumentFragment.parse(text)
    doc.truncate(max_words, ellipsis).first
  end

  class <<self
    attr_accessor :ellipsable_tags
  end
  self.ellipsable_tags = Set.new(%w(p ol ul li div header article nav section footer aside dd dt dl))
end


class Nokogiri::HTML::DocumentFragment
  def ellipsable?
    true
  end
end

class Nokogiri::XML::Node
  def truncate(max_words, ellipsis)
    return ["", 1, ellipsis] if max_words == 0 && !ellipsable?
    inner, remaining, ellipsis = inner_truncate(max_words, ellipsis)
    children.remove
    add_child Nokogiri::HTML::DocumentFragment.parse(inner)
    [to_xml(:indent => 0), max_words - remaining, ellipsis]
  end

  def inner_truncate(max_words, ellipsis)
    inner, remaining = "", max_words
    self.children.each do |node|
      txt, nb, ellipsis = node.truncate(remaining, ellipsis)
      remaining -= nb
      inner += txt
      next if remaining >= 0
      if ellipsable?
        inner += ellipsis
        ellipsis = ""
      end
      break
    end
    [inner, remaining, ellipsis]
  end

  def ellipsable?
    HTML_Truncator.ellipsable_tags.include? name
  end
end

class Nokogiri::XML::Text
  def truncate(max_words, ellipsis)
    words    = content.split
    nb_words = words.length
    return [to_xhtml, nb_words, ellipsis] if nb_words <= max_words && max_words > 0
    [words.slice(0, max_words).join(' '), nb_words, ellipsis]
  end
end

class String
  def truncate(max_words, ellipsis=nil)
    truncated_string = HTML_Truncator.truncate(self, max_words, ellipsis)
    if truncated_string != self
      truncated_string.define_singleton_method(:truncated?) do
        true
      end
    end
    truncated_string
  end

  def truncated?
    false
  end
end
