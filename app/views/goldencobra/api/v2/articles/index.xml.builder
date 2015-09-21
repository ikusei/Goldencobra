# encoding: utf-8

xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
xml.rss version: "2.0", "xmlns:atom"=>"http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.tag!("atom:link", {"href" => "http://#{Goldencobra::Setting.for_key('goldencobra.url').sub('http://','')}/api/v2/articles.xml", "rel"=>"self", "type"=>"application/rss+xml"})
    xml.title Nokogiri::HTML.parse(Goldencobra::Article.where(startpage: true).first.title).text
    xml.link Goldencobra::Article.where(startpage: true).first.absolute_public_url
    xml.description Goldencobra::Article.where(startpage: true).first.metatag_meta_description
    @articles.uniq.each do |article|
      xml.item do
        xml.title do
          xml.cdata!("#{Nokogiri::HTML.parse(article.title).text}")
        end
        xml.description do
          if article.teaser.present?
            template = Liquid::Template.parse(Nokogiri::HTML.parse(article.teaser).text)
          else
            template = Liquid::Template.parse(Nokogiri::HTML.parse(article.content).text)
          end
          xml.cdata!(template.render(Goldencobra::Article::LiquidParser))
        end
        xml.link "#{article.absolute_public_url}"
        xml.pubDate "#{article.created_at.strftime("%a, %d %b %Y %H:%M:%S %z")}"
        xml.guid "#{article.absolute_public_url}"
      end
    end
  end
end
