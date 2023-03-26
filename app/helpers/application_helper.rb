module ApplicationHelper
  include Pagy::Frontend

  def link_helper(link)
    @link = link.strip
    if @link[0..3] == "http" or @link[0..4] == "https"
      @link
    else
      "//#{@link}"
    end
  end

  def date_to_words(date)
    return "" if date.nil?
    ## recent
    if ((1.week.ago)..(Time.now)).cover?(date)
      return "#{time_ago_in_words(date)} ago"
      ## within this year
    elsif ((Date.today.beginning_of_year)..(Time.now)).cover?(date)
      return date.in_time_zone&.strftime("%A, %B %d")
      ## year before
    else
      return date.in_time_zone&.strftime("%B %d, %Y")
    end
  end

  def format_large_number(number)
    if number >= 1000
      return "#{(number / 1000.0).round(1)}k"
    else
      return number
    end
  end

  def markdown(content)
    renderer =
      Redcarpet::Render::HTML.new(
        hard_wrap: true,
        autolink: true,
        no_intra_empasis: true,
        disable_indented_code_blocks: true,
        fenced_code_blocks: true,
        strikethough: true,
        superscirpt: true,
      )
    Redcarpet::Markdown.new(renderer).render(content).html_safe
  end
end
