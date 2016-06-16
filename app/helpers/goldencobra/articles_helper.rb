# encoding: utf-8

module Goldencobra
  module ArticlesHelper

    # 'Read on' link to article for index-pages
    # If external_url_redirect is set and a link_title is given,
    # display this link title. Otherwise display a generic link title.
    def read_on(article, options={})
      target_window = article.redirection_target_in_new_window ? "_blank" : "_top"
      html_class = "more #{options[:class]}".strip
      if article.redirect_link_title.present?
        link_to article.redirect_link_title, article.external_url_redirect, class: html_class, target: target_window
      else
        link_to t(:read_on, scope: [:articles]), article.public_url, class: html_class, target: target_window, title: article.title
      end
    end

    #Ausgabe aller Hauptbestandteile eines Artikels über "content_for :xy"
    def render_article_content_parts(article)
      render partial: "/goldencobra/articles/show", locals: {article: article}
    end


    #Parse text for a single Word and make a link to an Article to this Word as a Subarticle of a given Article
    def parse_glossar_entries(content,tag_name, parent_article_id=nil)
      glossar_parent = nil
      if parent_article_id
        glossar_parent = Goldencobra::Article.find_by_id(parent_article_id)
        glossar_article = glossar_parent.children.where(breadcrumb: tag_name).first
      else
        glossar_article = Goldencobra::Article.where(breadcrumb: tag_name).first
      end
      unless glossar_article
        glossar_article = Goldencobra::Article.create(title: tag_name, breadcrumb: tag_name, article_type: "Default Show", parent: glossar_parent)
      end

      if glossar_article.present?
        replace_with = "<a href='#{glossar_article.public_url}' class='glossar'>#{tag_name}</a>"
        content = content.gsub(/\b(?<!\/)#{tag_name}(?!<)\b/, "#{replace_with}")
      end
    end


    # [render_article_image_gallery description]
    # @param options={} [Hash] {link_image_size: :thumb, target_image_size: :large}
    #
    # @return [HTML] ImageGallery
    def render_article_image_gallery(options = {})
      if @article && @article.image_gallery_tags.present?
        tags = @article.image_gallery_tags.split(",")
        uploads = Goldencobra::Upload.tagged_with(tags)
        list_items = ""
        uploads.order(:sorter_number).each do |upload|
          list_items << content_tag("li") do
            link_to upload.image.url(options[:target_image_size] || :large), title: raw(upload.description) do
              image_tag(upload.image.url(options[:link_image_size] || :thumb), alt: upload.alt_text)
            end
          end
        end
        content_tag("ul", raw(list_items), class: "goldencobra_article_image_gallery")
      elsif @article
        content_tag("ul", raw(""), class: "goldencobra_article_image_gallery")
      end
    end

    # Deprecated Helper Method, will be removed in GC 2.1
    def index_of_articles(options={})
      warn "Deprecated helper method 'index_of_articles'. Will be removed in GC 2.1"
      if @article && @article.article_for_index_id.present? && master_index_article = Goldencobra::Article.find_by_id(@article.article_for_index_id)
        result_list = ""
        result_list += content_tag(:h2, raw("&nbsp;"), class: "boxheader")
        result_list += content_tag(:h1, "#{master_index_article.title}", class: "headline")
        dom_element = (options[:wrapper]).present? ? options[:wrapper] : :div
        master_index_article.descendants.order(:created_at).limit(@article.article_for_index_limit).each do |art|
          if @article.article_for_index_levels.to_i == 0 || (@article.depth + @article.article_for_index_levels.to_i > art.depth)
            rendered_article_list_item = render_article_list_item(art)
            result_list += content_tag(dom_element, rendered_article_list_item, id: "article_index_list_item_#{art.id}", class: "article_index_list_item")
          end
        end
        return content_tag(:article, raw(result_list), id: "article_index_list")
      end
    end

    def render_article_type_content(options={})
      if @article
        if @article.article_type.present? && @article.kind_of_article_type.present?
         render partial: "articletypes/#{@article.article_type_form_file.underscore.parameterize.downcase}/#{@article.kind_of_article_type.downcase}"
        else
          render partial: "articletypes/default/show"
        end
      end
    end

    def render_article_widgets(options={})
      custom_css = options[:class] || ""
      tags = options[:tagged_with] || ""

      #include default widgets?
      include_defaults = options[:default].to_s == "true" || false

      #include article widgets?
      if options[:article].present?
        include_articles = options[:article].to_s == "true"
      else
        include_articles = true
      end

      widget_wrapper = options[:wrapper] || "section"
      result = ""
      if params[:frontend_tags] && params[:frontend_tags].class != String && params[:frontend_tags][:format] && params[:frontend_tags][:format] == "email"
        #Wenn format email, dann gibt es keinen realen webseit besucher
        ability = Ability.new()
      else
        if !defined?(current_user).nil? || !defined?(current_visitor).nil?
          operator = current_user || current_visitor
          ability = Ability.new(operator)
        else
          ability = Ability.new()
        end
      end

      # Get article Widgets
      if @article && include_articles
        article_widgets = @article.widgets.active.tagged_with(tags.split(","))
      else
        article_widgets = []
      end

      #Get default widgets
      if include_defaults == true
        default_widgets = Goldencobra::Widget.active.where(default: true)
        default_widgets = default_widgets.tagged_with(tags.split(",")) if tags.present?
      else
        default_widgets = []
      end

      # merge article and default widgets
      widgets = [default_widgets] + [article_widgets]
      widgets = widgets.flatten.uniq.compact

      #Sort widgets bei global sorter id
      widgets = widgets.sort_by(&:sorter)

      #render Widgets
      widgets.each do |widget|
        #check if current user has permissions to see this widget
        if ability.can?(:read, widget)
          template = Liquid::Template.parse(widget.content)
          html_data_options = {"class" => "#{widget.css_name} #{custom_css} goldencobra_widget",
                                "id" => widget.id_name.present? ? widget.id_name : "widget_id_#{widget.id}",
                                'data-id' => widget.id
                              }
          result << content_tag(widget_wrapper, raw(template.render(Goldencobra::Article::LiquidParser)), html_data_options)
        end
      end

      return raw(result)
    end

    private

    def render_article_list_item(article_item)
      result = ""
      result += content_tag(:div, link_to(article_item.title, article_item.public_url), :class=> "title")
      result += content_tag(:div, article_item.created_at.strftime("%d.%m.%Y %H:%M"), :class=>"created_at")
      if @article.article_for_index_images == true && article_item.images.count > 0
        result += content_tag(:div, image_tag(article_item.images.first.image(:thumb)), class: "article_image")
      end
      result += content_tag(:div, raw(article_item.public_teaser), class: "teaser")
      result += content_tag(:div, link_to(s("goldencobra.article.article_index.link_to_article"), article_item.public_url), :class=> "link_to_article")
      return raw(result)
    end

  end
end
