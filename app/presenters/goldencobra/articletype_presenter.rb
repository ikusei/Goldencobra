# encoding: utf-8

module Goldencobra
  class ArticletypePresenter
    def initialize(f, articletype)
      @f = f
      @articletype = articletype
    end

    # Info: breadcrumb muss hier, obwohl default Feld, extra definiert werden, da es einen
    # NavigationHelper gibt mit selbigem Namen. Somit greift method_missing nicht.
    def breadcrumb
      input_form_for(:breadcrumb)
    end

    def content
      input_form_for(:content, input_html: { class: "html-textarea" })
    end

    def teaser
      input_form_for(:teaser, input_html: { rows: 5 })
    end

    def summary
      input_form_for(:summary, input_html: { rows: 5, class: "html-textarea" })
    end

    def active_since
      input_form_for(:active_since, as: :string, input_html: { size: "20" })
    end

    def context_info
      input_form_for(:context_info, input_html: { class: "html-textarea" })
    end

    def creator
      @f.input :creator_id,
               as: :select,
               collection: User.all.map { |u| [u.title, u.id] },
               include_blank: true,
               hint: I18n.t("goldencobra.article_field_hints.creator")
    end

    def state
      @f.input :state,
               as: :select,
               collection: Goldencobra::Article.state_attributes_for_select,
               include_blank: false,
               hint: I18n.t("goldencobra.article_field_hints.state")
    end

    def tag_list
      @f.input :tag_list,
               hint: I18n.t("goldencobra.article_field_hints.tag_list"),
               input_html: { value: @f.object.tag_list.join(", ") }
    end

    def frontend_tag_list
      @f.input :frontend_tag_list,
               hint: I18n.t("goldencobra.article_field_hints.frontend_tag_list"),
               input_html: { value: @f.object.frontend_tag_list.join(", ") }
    end

    def parent_id
      css_name = "get_goldencobra_articles_per_remote" +
                 (@f.object.startpage ? " include_blank_true " : " include_blank_false ")
      collection = [[@f.object.try(:parent).try(:parent_path), @f.object.try(:parent).try(:id)]]
      input_form_for(:parent_id, as: :select,
                                 collection: collection,
                                 input_html: { class: css_name },
                                 style: "width: 80%;",
                                 dataplaceholder: "Elternelement auswählen")
    end

    def dynamic_redirection
      collection = Goldencobra::Article::DynamicRedirectOptions.map { |a| [a[1], a[0]] }
      input_form_for(:dynamic_redirection, as: :select, collection: collection,
                                           include_blank: false)
    end

    def permissions
      @f.has_many :permissions do
        p.input :domain, include_blank: "Alle"
        p.input :role, include_blank: "Alle"
        p.input :action, as: :select, collection: Goldencobra::Permission::PossibleActions,
                         include_blank: false
        p.input :_destroy, as: :boolean
      end
    end

    def widgets
      Goldencobra::Widget.tag_counts_on(:tags).map(&:name).each do |wtag|
        @f.inputs "Position: #{wtag}" do
          @f.input :widgets,
                   as: :select,
                   collection: Goldencobra::Widget.tagged_with(wtag),
                   input_html: { class: "chosen-select", style: "width: 80%; margin-left:20%",
                                 "data-placeholder" => "Widgets auswählen" },
                   wrapper_html: { class: "hidden_label" }
        end
      end
    end

    def article_images
      @f.has_many :article_images, heading: "", new_record: "+ hinzufügen" do |ai|
        ai.input :image, as: :select,
                         collection: Goldencobra::Upload.where(id: ai.object.image_id).map { |c| [c.complete_list_name, c.id] },
                         input_html: { class: "article_image_file chosen-select-deselect get_goldencobra_uploads_per_remote",
                                       style: "width: 80%;", "data-placeholder" => "Bitte warten" },
                         label: "Medium wählen",
                         include_blank: false
        ai.input :position, as: :select,
                            collection: Goldencobra::Setting.for_key("goldencobra.article.image_positions").to_s.split(",").map(&:strip),
                            include_blank: false
        ai.input :_destroy, as: :boolean, label: "Löschen"
      end
    end

    # Index Methods
    #
    def index__article_for_index_id
      collection = Goldencobra::Article.articles_for_index_selecetion
      @f.input :article_for_index_id, label: I18n.t("active_admin.articles.index.views.label1"),
                                      hint: I18n.t("active_admin.articles.index.views.hint1"),
                                      as: :select, collection: collection,
                                      include_blank: "/",
                                      id: "article_event_articleindex_id",
                                      input_html: { class: "chosen-select", style: "width: 80%;" }
    end

    def index__article_descendents_depth
      @f.input :index_of_articles_descendents_depth,
               as: :select,
               collection: [["1 Ebene", "1"], ["2 Ebenen", "2"], ["3 Ebenen", "3"], %w(Alle all)],
               include_blank: false, label: I18n.t("active_admin.articles.index.views.label4"),
               hint: I18n.t("active_admin.articles.index.views.hint4")
    end

    def index__display_index_types
      @f.input :display_index_types,
               label: I18n.t("active_admin.articles.index.views.label2"),
               hint: I18n.t("active_admin.articles.index.views.hint2"),
               as: :select,
               collection: Goldencobra::Article::DisplayIndexTypes,
               include_blank: false
    end

    def index__display_index_articletypes
      @f.input :display_index_articletypes,
               label: I18n.t("active_admin.articles.index.views.label3"),
               hint: I18n.t("active_admin.articles.index.views.hint3"),
               as: :select, collection: ["all"] + Goldencobra::Article.article_types_for_search,
               include_blank: false
    end

    def index__index_of_articles_tagged_with
      @f.input :index_of_articles_tagged_with,
               label: "Artikel mit folgenden Tags",
               hint: "Auf der Übersichtsseite werden alle Artikel des gleichen Artikeltyps mit diesen Tags ausgegeben. Sind keine Tags angegeben, werden alle Artikel des gleichen Artikeltyps ausgegeben."
    end

    def index__not_tagged_with
      @f.input :not_tagged_with,
               label: "Artikel ohne folgende Tags",
               hint: "Artikel mit diesen Tags nicht anzeigen!"
    end

    def index__sorter_limit
      @f.input :sorter_limit,
               label: "Anzahl anzuzeigender Artikel",
               hint: "Wieviel Artikel sollen maximal auf der Übersichtsseite erscheinen?"
    end

    def index__sort_order
      @f.input :sort_order,
               hint: "Created_at - Reihenfolge nach Erstellungsdatum | Updated_at - Reihenfolge nach Aktualisierungsdatum | Random - Reihenfolge zufällig | Alphabetically - Reihenfolge alphabetisch | GlobalSortID - Reihenfolge nach globaler Sortiernummer im Einzelartikel",
               as: :select,
               collection: Goldencobra::Article::SortOptions,
               include_blank: false
    end

    def index__reverse_sort
      @f.input :reverse_sort, hint: "Soll absteigend sortiert werden? Standard: aufsteigend"
    end

    # Alle nicht vom default abweichenden Artikel Methoden werden herüber abgefangen, es sei denn
    # es gibt einen Helper, der den selben Namen hat wie die Methode (Bsp. breadcrumb) - ätzend
    def method_missing(method_name, *arguments, &block)
      if @f.object.respond_to?(method_name)
        input_form_for(method_name.to_sym)
      else
        super
      end
    end

    # Deprecated Methods

    def metatags
      warn("Deprecated method metatags")
    end

    def enable_social_sharing
      warn("Deprecated method enable_social_sharing")
    end

    def commentable
      warn("Deprecated method commentable")
    end

    def author
      warn("Deprecated method author")
    end

    private

    def input_form_for(method_symbol, options = {})
      hint = options[:hint] || I18n.t("goldencobra.article_field_hints.#{method_symbol}")
      input_html = options[:input_html] || nil
      display_as = options[:as] || nil
      collection = options[:collection] || nil
      style = options[:style] || nil
      dataplaceholder = options[:dataplaceholder] || nil
      include_blank = options[:include_blank] || nil
      label = options[:label] || nil

      input_options = {
        hint: hint,
        input_html: input_html,
        as: display_as,
        collection: collection,
        style: style,
        dataplaceholder: dataplaceholder,
        include_blank: include_blank,
        label: label
      }

      input_options = input_options.delete_if { |_k, v| v.blank? }
      @f.input(method_symbol, input_options)
    end

    attr_reader :articletype
  end
end
