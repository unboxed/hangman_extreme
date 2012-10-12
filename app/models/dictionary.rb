# Holds all the words for the game
require 'open-uri'

class Dictionary < SortedSet

  attr_reader :clues
  WORDREF_API_KEY = "be388"

  def <<(value)
    super if valid_value?(value)
  end

  def add(value)
    super if valid_value?(value)
  end

  def set_clue(value,clue)
    @clues ||= {}
    @clues[value] = clue
  end

  def clue(value)
    @clues ||= {}
    @clues[value]
  end

  def clear
    @array = nil
    super
  end

  def self.instance
    @instance ||= self.new
  end

  def self.set_clue(value,clue)
    instance.set_clue(value,clue)
  end

  def self.clue(value)
    instance.clue(value)
  end

  def self.method_missing(m, *args, &block)
    instance.respond_to?(m, *args, &block) ? instance.send(m,*args,&block) : super
  end

  def self.respond_to?(m, *args, &block)
    instance.respond_to?(m,*args, &block) || super
  end

  def random_value
    (@array ||= self.to_a).sample || "missing"
  end

  def self.define(word)
    Rails.logger.info "Google define #{word}"
    parse(google_word(word))
  end

  private

  def valid_value?(value)
    value.present? && (value.downcase! || true) && (value.gsub!(/\s/,"") || true) && value.size >= 4 && value =~ /^\p{Lower}*$/
  end

  def google_word(word)
    open "https://www.google.com/search?q=define+#{word}&aq=f&oq=define&sugexp=chrome,mod=9&sourceid=chrome&ie=UTF-8"
  end

  def self.parse html
    doc = Nokogiri::HTML html

    doc.css('.ts td').first.children.collect{|c| c.text}
  end

end