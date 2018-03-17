class OpenGraph
  attr_accessor :url, :html, :document

  def initialize(url)
    @url = url
    @html = Typhoeus.get(@url).body
    @document = Nokogiri::HTML.parse(@html)
  end

  def site_name
    if @document.css('//meta[property="og:site_name"]/@content').empty?
      @document.title.to_s
    else
      @document.css('//meta[property="og:site_name"]/@content').to_s
    end
  end

  def description
    if @document.css('//meta[property="og:description"]/@content').empty?
      @document.css('//meta[name$="escription"]/@content').to_s
    else
      @document.css('//meta[property="og:description"]/@content').to_s
    end
  end

  def image_url
    @document.css('//meta[property="og:image"]/@content').to_s
  end
end
