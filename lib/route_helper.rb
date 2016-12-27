module RouteHelper
  def link_to(text, route)
    <<-HTML
      <a href="#{route}">#{text}</a>
    HTML
  end

  def button_to(text, route, options = {})
    <<-HTML
      <form method="post" action="#{route}" class="button">
        #{"<input type='hidden' name='_method' value='#{ options[:method] }'>" if options[:method]}
        <input value=#{text} type="submit">
      </form>
    HTML
  end
end
