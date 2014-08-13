module MenuHelper

  def menu_items
    return @menu_items if @menu_items
    @menu_items = []
    @menu_items << ['Home', root_path, id: 'home'] unless current_page?(root_path)
    if params[:action] == 'index' || (params[:controller] != 'games'  && params[:action] != 'new')
      @menu_items << ['Play', play_games_path, id: 'play_game', style: 'color:green;']
    end
    @menu_items
  end

  def menu_item(*args)
    menu_items.push(args)
  end

  def grouped_menu_items
    items = menu_items.clone
    grouped_items = []
    Rails.logger.debug items.inspect
    while(!items.empty?)
      if items.size == 1 || (items[0].first.size + items[1].first.size > 20)
        grouped_items << [items[0]]
        items.shift
      else
        grouped_items << [items[0],items[1]]
        items.shift(2)
      end
    end
    grouped_items
  end

  def menu
    render :partial => 'layouts/menu', :locals => {:grouped_menu_items => grouped_menu_items}
  end

end
