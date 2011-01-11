require "nokogiri"


class HTML_Truncator
  def self.truncate(text, max_words, ellipsis="...")
    doc = Nokogiri::HTML::DocumentFragment.parse(text)
    doc.truncate(max_words, ellipsis).first
  end
end


class Nokogiri::HTML::DocumentFragment
  def ellipsable?
    true
  end
end

class Nokogiri::XML::Node
  def truncate(max_words, ellipsis)
    inner, remaining, ellipsed = inner_truncate(max_words, ellipsis)
    children.remove
    add_child Nokogiri::HTML::DocumentFragment.parse(inner)
    [to_xml, max_words - remaining, ellipsed]
  end

  def inner_truncate(max_words, ellipsis)
    inner, remaining, ellipsed = "", max_words, false
    self.children.each do |node|
      txt, nb, ellipsed = node.truncate(remaining, ellipsis)
      remaining -= nb
      inner += txt if node.text? || node.ellipsable? || node.content.split.length != 0
      if remaining < 0
        if !ellipsed && ellipsable?
          inner += ellipsis
          ellipsed = true
        end
        break
      end
    end
    [inner, remaining, ellipsed]
  end

  def ellipsable?
    %w(p ol ul li div header article nav section footer aside dd dt dl).include? name
  end
end

class Nokogiri::XML::Text
  def truncate(max_words, ellipsis)
    words    = content.split
    nb_words = words.length
    return [to_xhtml, nb_words, false] if nb_words <= max_words
    [words.slice(0, max_words).join(' '), nb_words, false]
  end
end
