module WordsHelper

  def define_word(word)
    Dictionary.define(word).split("\n").join("<br/>").html_safe
  end

end
