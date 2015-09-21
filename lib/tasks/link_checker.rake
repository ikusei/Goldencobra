# encoding: utf-8

namespace :link_checker do
  desc 'Checks Links for a given Article'
  task :article => :environment do
    article_id = ENV['ID']

    if article_id.present?
      article = Goldencobra::Article.find(article_id)
      if article
        Goldencobra::LinkChecker.set_link_checker(article)
      end
    else
      puts "Missing Attributes! e.g.:"
      puts "rake link_checker:article ID=8"
    end
  end


  desc 'Checks Links for all Articles'
  task :all => :environment do
    Goldencobra::Article.all.each do |article|
      begin
        Goldencobra::LinkChecker.set_link_checker(article)
      rescue
        puts "Artikel konnte nicht geprüft werden: #{article.id}"
      end
    end
  end

end