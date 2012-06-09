module ApplicationHelper
  def if_current?(path, klass)
    if current_page? path
      klass
    else
      ''
    end
  end

  def active_if_current path
    if_current? path, 'active'
  end
end
