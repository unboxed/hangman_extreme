module GamesHelper
  def letter_link(game,letter)
    letter_already_included = game.choices.to_s.include?(letter)
    path = play_letter_game_path(game,letter)
    link_to_unless(letter_already_included,letter,path, id: letter)
  end
end
