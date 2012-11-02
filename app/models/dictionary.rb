# Holds all the words for the game
require 'open-uri'

class Dictionary < SortedSet

  attr_reader :clues

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

  def random_value
    (@array ||= self.to_a).sample || "missing"
  end

  def self.instance
    @instance ||= self.new
  end

  def self.method_missing(m, *args, &block)
    instance.respond_to?(m) ? instance.send(m,*args,&block) : super
  end

  def self.respond_to?(m, *args, &block)
    instance.respond_to?(m,*args, &block) || super
  end

  def self.define(word)

  end

  private

  def valid_value?(value)
    value.present? && (value.downcase! || true) && (value.gsub!(/\s/,"") || true) && value.size >= 4 && value =~ /^\p{Lower}*$/
  end

end