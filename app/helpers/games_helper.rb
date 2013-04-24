module GamesHelper


  def letter_link(game,letter)
    letter_already_included = game.choices.to_s.include?(letter)
    path = play_letter_game_path(game,letter)
    options = {'data-role' => "button", 'data-inline' => "true", "data-mini" => "true"}
    if mxit_request?
      link_to_unless(letter_already_included,letter,path,options)
    elsif letter_already_included
      link_to(letter,"#",options.reverse_merge('data-theme' => "a"))
    else
      link_to(letter,path,options)
    end
  end

end
