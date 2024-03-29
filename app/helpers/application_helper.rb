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

  def image_set_tag(source, srcset = {}, options = {})
    srcset = srcset.map { |src, size| "#{path_to_image(src)} #{size}" }.join(', ')
    image_tag(source, options.merge(srcset: srcset))
  end

  def format_date(date)
    return "" if date.nil?
    return date.in_time_zone&.strftime("%b %d")
  end

  def format_full_date(date)
    return "" if date.nil?
    return date.in_time_zone&.strftime("%B %d, %Y")
  end
  
  def format_share_url(post)
    return "https://www.theteenmagazine.com/#{post.slug}"
  end

  def date_to_words(date)
    return "" if date.nil?
    if (date > Time.now)
      return "#{time_ago_in_words(date)}"
      ## future
    elsif ((1.week.ago)..(Time.now)).cover?(date)
      return "#{time_ago_in_words(date)} ago"
      ## within this year
    elsif ((Date.today.beginning_of_year)..(Time.now)).cover?(date)
      return date.in_time_zone&.strftime("%a, %B %d")
      ## year before
    else
      return date.in_time_zone&.strftime("%B %d, %Y")
    end
  end

  def format_large_number(number)
    if number >= 1000
      return "#{(number / 1000.0).round(1)}k".gsub(".0", "")
    else
      return number
    end
  end

  def format_number_category(number)
    if number >= 300000
      return "300k+"
    elsif number >= 250000
      return "250k+"
    elsif number >= 200000
      return "200k+"
    elsif number >= 150000
      return "150k+"
    elsif number >= 100000
      return "100k+"
    elsif number >= 50000
      return "50k+"
    elsif number >= 20000
      return "20k+"
    elsif number >= 10000
      return "10k+"
    elsif number >= 5000
      return "5k+"
    elsif number >= 2000
      return "2k+"
    elsif number >= 1000
      return "1k+"
    else
      return ""
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
