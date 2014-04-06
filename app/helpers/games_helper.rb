module GamesHelper


  def letter_link(game,letter)
    letter_already_included = game.choices.to_s.include?(letter)
    path = play_letter_game_path(game,letter)
    if mxit_request?
      link_to_unless(letter_already_included,letter,path, id: letter)
    elsif letter_already_included
      link_to(letter, '#',class: 'btn btn-inverse disabled')
    else
      link_to(letter,path,class: 'btn', id: letter)
    end
  end

end
