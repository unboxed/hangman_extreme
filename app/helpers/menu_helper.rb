module MenuHelper

  def menu_items
    @menu_items ||= []
  end

  def menu_item(*args)
    menu_items.push(args)
  end

  def grouped_menu_items
    items = menu_items.clone
    grouped_items = []
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
    content_tag("ul", :class => "menu") do
      item = 0
      grouped_menu_items.collect do |menu_items|
        content_tag("li", :class => "item#{item += 1}") do
          menu_items.collect{|menu_item|smart_link_to(*menu_item)}.join(" | ").html_safe
        end
      end.join("\n").html_safe
    end
  end

end
