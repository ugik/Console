module ApplicationHelper

  # Return a title on a per-page basis.
  def title
    base_title = "Keas Console"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end
  
  def logo
    image_tag("logo2.png", :alt => "Console", :class => "round", :width => "30")
  end  

  def wait
    image_tag("CircularProgressAnimation.gif", :id => "busy-indicator", :alt => "Console", :class => "round", 
	:width => "35", :style =>"display:none")
  end

  def pop
    image_tag("PowerOfPlay.jpg", :alt => "Console", :class => "round", :width => "250")
  end  

  def sortable(column, title = nil)
    title ||= column.titleize
    direction = (column == params[:sort] && params[:direction] == "asc") ? "desc" : "asc"
    css_class = (column == params[:sort]) ? "current #{params[:direction]}" : nil
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end

end
