# encoding: utf-8

require "spec_helper"

describe Goldencobra::Article do
  describe "moving article in articles-tree" do
    before(:each) do
      @attr = { title: "Testartikel", article_type: "Default Show", breadcrumb: "bc_testarticle" }
    end

    it "should have a valid public_url before saving" do
      a = Goldencobra::Article.new(@attr)
      a.breadcrumb = "article1"
      expect(a.public_url).to eql("/")
      a.save
    end

    it "should have a valid public_url after saving" do
      a = Goldencobra::Article.new(@attr)
      a.breadcrumb = "article1"
      a.save
      expect(a.public_url).to eql("/article1")
    end

    it "should have a valid public_url after saving and reloading from db" do
      a = Goldencobra::Article.new(@attr)
      a.breadcrumb = "article1"
      a.save
      expect(Goldencobra::Article.find_by_id(a.id).public_url).to eq("/article1")
    end

    it "should have a valid url_path before saving" do
      a = Goldencobra::Article.new(@attr)
      a.breadcrumb = "article1"
      expect(a.url_path).to eql(nil)
      a.save
    end

    it "should have a valid url_path after saving" do
      a = Goldencobra::Article.new(@attr)
      a.url_name = "article1"
      a.save
      expect(a.url_path).to eql("/article1")
    end

    it "should have a valid url_path after saving and reloading from db" do
      a = Goldencobra::Article.new(@attr)
      a.url_name = "article1"
      a.save
      expect(Goldencobra::Article.find_by_id(a.id).url_path).to eql("/article1")
    end
  end

  describe "creating an article" do
    before(:each) do
      @attr = { title: "Testartikel",
                url_name: "testartikel",
                article_type: "Default Show",
                breadcrumb: "bc_testarticle" }
    end

    describe "url_name" do
      it "should be uniq in siblings or appendend by higher number" do
        parent_article = Goldencobra::Article.create!(@attr)
        Goldencobra::Article.create!(@attr.merge(url_name: "news", parent_id: parent_article.id))
        Goldencobra::Article.create!(@attr.merge(url_name: "news--2", parent_id: parent_article.id))
        Goldencobra::Article.create!(@attr.merge(url_name: "news--5", parent_id: parent_article.id))
        Goldencobra::Article.create!(@attr.merge(url_name: "news--8"))
        Goldencobra::Article.create!(@attr.merge(url_name: "archiv", parent_id: parent_article.id))

        a = Goldencobra::Article.create(@attr.merge(url_name: "news", parent_id: parent_article.id))
        expect(a.url_name).to eq "news--6"

        a.save
        expect(a.url_name).to eq "news--6"

        b = Goldencobra::Article.create(@attr.merge(url_name: "test", parent_id: parent_article.id))
        expect(b.url_name).to eq "test"
      end

      it "should be the same if appending number is modified by user" do
        parent_article = Goldencobra::Article.create!(@attr)
        Goldencobra::Article.create!(@attr.merge(url_name: "news--2", parent_id: parent_article.id))
        a = Goldencobra::Article.create(@attr.merge(url_name: "news--2", parent_id: parent_article.id))
        expect(a.url_name).to eq "news--2"
      end
    end

    describe "redirection value" do
      it "should have a valid redirect url by inserting an url without http" do
        a = Goldencobra::Article.create!(@attr)
        a.external_url_redirect = "www.google.de"
        a.save
        expect(Goldencobra::Article.find_by_id(a.id).external_url_redirect).to eq "http://www.google.de"
      end

      it "should have a valid redirect url by inserting an url with http" do
        a = Goldencobra::Article.create!(@attr)
        a.external_url_redirect = "http://www.google.de"
        a.save
        expect(Goldencobra::Article.find_by_id(a.id).external_url_redirect).to eq "http://www.google.de"
      end

      it "should have a valid redirect url by inserting an url with https" do
        a = Goldencobra::Article.create!(@attr)
        a.external_url_redirect = "https://www.google.de"
        a.save
        expect(Goldencobra::Article.find_by_id(a.id).external_url_redirect).to eq "https://www.google.de"
      end

      it "should have no redirection if redirect url is empty" do
        a = Goldencobra::Article.create!(@attr)
        a.external_url_redirect = ""
        a.save
        expect(Goldencobra::Article.find_by_id(a.id).external_url_redirect).to eq ""
      end
    end

    it "should create a new article given valid attributes" do
      Goldencobra::Article.create!(@attr)
    end

    it "should set active_since to the created_at datetime" do
      article = create :article
      expect(article.active_since).to eq(article.created_at)
    end

    it "should not require a url_name because it is filled automatically" do
      no_url_name_article = Goldencobra::Article.new(@attr.merge(url_name: ""))
      expect(no_url_name_article).to be_valid
    end

    it "should not display partial in templatefiles" do
      File.new("#{::Rails.root}/app/views/layouts/tim_test.html.erb", "w")
      File.new("#{::Rails.root}/app/views/layouts/_partial.html.erb", "w")
      File.new("#{::Rails.root}/app/views/layouts/_partial_2.html.erb", "w")
      File.new("#{::Rails.root}/app/views/layouts/12layout.html.erb", "w")

      expect(Goldencobra::Article.templates_for_select.include?("tim_test")).to eq true
      expect(Goldencobra::Article.templates_for_select.include?("_partial")).to eq false
      expect(Goldencobra::Article.templates_for_select.include?("_partial_2")).to eq false
      expect(Goldencobra::Article.templates_for_select.include?("application")).to eq true
      expect(Goldencobra::Article.templates_for_select.include?("12layout")).to eq true

      File.delete("#{::Rails.root}/app/views/layouts/tim_test.html.erb")
      File.delete("#{::Rails.root}/app/views/layouts/_partial.html.erb")
      File.delete("#{::Rails.root}/app/views/layouts/_partial_2.html.erb")
      File.delete("#{::Rails.root}/app/views/layouts/12layout.html.erb")
    end

    it "should return a list of 5 last modified articles" do
      1.upto(5) { |i|
        Goldencobra::Article.create!(@attr)
      }
      expect(Goldencobra::Article.recent(5).collect.count).to eq 5
    end

    context "of article_type_kind INDEX" do
      it "displays its children as index if no value is given" do
        article = create :article, article_for_index_id: nil, article_type: "Default Index"

        expect(article.id).not_to eq(nil)
        expect(article.article_for_index_id).not_to eq(nil)
        expect(article.article_for_index_id).to eq(article.id)
      end

      it "display children of a specific article if value is given" do
        article = create :article, article_for_index_id: 42, article_type: "Default Index"

        expect(article.id).not_to eq(nil)
        expect(article.article_for_index_id).not_to eq(nil)
        expect(article.article_for_index_id).to eq(42)
        expect(article.article_for_index_id).not_to eq(article.id)
      end
    end

    context "of article_type_kind SHOW" do
      it "does not get article_for_index_id set" do
        article = create :article, article_for_index_id: nil, article_type: "Default Show"

        expect(article.id).not_to eq(nil)
        expect(article.article_for_index_id).to eq(nil)
        expect(article.article_for_index_id).not_to eq(article.id)
      end
    end
  end

  describe "updating an article" do
    it "should have a new url_path" do
      article = create :article, url_name: "seite1"
      sub_article = create :article, url_name: "sub_seite", parent: article

      expect(article.public_url.include?("seite1")).to eq true
      expect(sub_article.public_url.include?("seite1/sub_seite")).to eq true

      article.url_name = "seite2"
      article.save

      expect(article.public_url.include?("seite2")).to eq true
      expect(sub_article.public_url.include?("seite2/sub_seite")).to eq true
    end
  end

  describe "state of an article" do
    before(:each) do
      @article = create :article, url_name: "seite1"
    end

    it "should have a state empty on create" do
      expect(@article.empty?).to eq(true)
    end

    it "should have a state draft" do
      @article.draft!
      expect(@article.draft?).to eq(true)
    end

    it "should have a state in_review" do
      @article.in_review!
      expect(@article.in_review?).to eq(true)
    end

    it "should have a state waiting" do
      @article.waiting!
      expect(@article.waiting?).to eq(true)
    end

    it "should have a state published" do
      @article.published!
      expect(@article.published?).to eq(true)
    end

    it "should have a state discarded" do
      @article.discarded!
      expect(@article.discarded?).to eq(true)
    end
  end
end
