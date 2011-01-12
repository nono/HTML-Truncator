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
      if remaining < 0
        inner += txt
        if ellipsable?
          inner += ellipsis
          ellipsis = ""
        end
        break
      end
      inner += txt
    end
    [inner, remaining, ellipsis]
  end

  def ellipsable?
    %w(p ol ul li div header article nav section footer aside dd dt dl).include? name
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
