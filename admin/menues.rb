ActiveAdmin.register Goldencobra::Menue, as: "Menue" do
  menu parent: I18n.t("active_admin.menues.parent"), label: I18n.t("active_admin.menues.as"), if: proc{can?(:update, Goldencobra::Menue)}

  filter :title, label: I18n.t("active_admin.menues.labels.title")
  filter :target, label: I18n.t("active_admin.menues.labels.target")
  filter :css_class, label: I18n.t("active_admin.menues.labels.css_class")
  filter :sorter, label: I18n.t("active_admin.menues.labels.sorter")

  scope I18n.t("active_admin.menues.active"), :active
  scope I18n.t("active_admin.menues.inactive"), :inactive

  form do |f|
    f.actions
    f.inputs I18n.t("active_admin.menues.form.generals.general") do
      f.input :title, label: I18n.t("active_admin.menues.form.generals.title"), hint: I18n.t("active_admin.menues.form.generals.title_hint")
      f.input :target, label: I18n.t("active_admin.menues.form.generals.target"), hint: I18n.t("active_admin.menues.form.generals.target_hint")
      f.input :parent_id, label: I18n.t("active_admin.menues.form.generals.parent_id"), hint: I18n.t("active_admin.menues.form.generals.parent_id_hint"), as: :select, collection: Goldencobra::Menue.all.map{|c| ["#{c.path.map(&:title).join(" / ")}", c.id]}.sort{|a,b| a[0] <=> b[0]}, include_blank: true, input_html: { class: "chosen-select-deselect", style: "width: 80%;", "data-placeholder" => "Elternelement auswählen" }
      f.input :sorter, label: I18n.t("active_admin.menues.form.options.sorter_label"), hint: I18n.t("active_admin.menues.form.options.sorter_hint")
    end
    f.inputs I18n.t("active_admin.menues.form.options.option"), class: "foldable closed inputs" do
      check_box_tag "hidden", label: I18n.t("active_admin.menues.form.options.checkbox_label"), hint: I18n.t("active_admin.menues.form.options.checkbox_hint")
      f.input :css_class, label: I18n.t("active_admin.menues.form.options.css_class_label"), hint: I18n.t("active_admin.menues.form.options.css_class_hint")
      f.input :active, label: I18n.t("active_admin.menues.form.options.active_label"), hint: I18n.t("active_admin.menues.form.options.aktiv_hint")
      f.input :remote, label: I18n.t("active_admin.menues.form.options.remote_label"), hint: I18n.t("active_admin.menues.form.options.remote_hint")
    end
    f.inputs I18n.t("active_admin.menues.form.access.access_rights"), class: "foldable closed inputs" do
      f.has_many :permissions do |p|
        p.input :role, include_blank: I18n.t("active_admin.menues.form.access.include_blank")
        p.input :action, as: :select, collection: Goldencobra::Permission::PossibleActions, include_blank: false
        p.input :_destroy, as: :boolean
      end
    end

    # Deprecated, will be removed in GC 2.1
    # f.inputs I18n.t('active_admin.menues.form.details'), class: "foldable closed inputs" do
    #   f.input :image, label: I18n.t('active_admin.menues.form.image_label'), hint: I18n.t('active_admin.menues.form.image_hint'), as: :select, collection: Goldencobra::Upload.order("updated_at DESC").map{|c| [c.complete_list_name, c.id]}, input_html: { class: 'article_image_file chosen-select-deselect', style: 'width: 80%;', 'data-placeholder' => 'Bild auswählen' }
    #   f.input :description_title, label: I18n.t('active_admin.menues.form.details_description_title'), hint: ""
    #   f.input :description, label: I18n.t('active_admin.menues.form.details_description_label'), hint: "", input_html: { rows: 5 }
    #   f.input :call_to_action_name, label: I18n.t('active_admin.menues.form.details_description_call_to_action'), hint: ""
    # end
    f.actions
  end

  index download_links: proc{ Goldencobra::Setting.for_key("goldencobra.backend.index.download_links") == "true" }.call do
    selectable_column
    column I18n.t("active_admin.menues.form.index.column"), :title, sortable: :title do |menue|
      link_to(menue.title, edit_admin_menue_path(menue), title: I18n.t("active_admin.menues.form.index.title"))
    end
    column I18n.t("active_admin.menues.form.index.column1"), :target
    column I18n.t("active_admin.menues.form.index.column2"), :active, sortable: :active do |menue|
      link_to(menue.active ? "online" : "offline", activate_deactivate_menu_item_admin_menue_path(menue),
              title: "#{menue.active ? I18n.t("active_admin.menues.member_action.set_menu_item_offline") : I18n.t("active_admin.menues.member_action.set_menu_item_online")}",
              "data-confirm" => I18n.t("change_menu_visibility", scope: [:goldencobra, :flash_notice]),
              class: "member_link edit_link #{menue.active ? 'online' : 'offline'}")
    end
    column I18n.t("active_admin.menues.form.index.column3"), :sorter
    column I18n.t("active_admin.menues.form.index.column4") do |menue|
      Goldencobra::Permission.restricted?(menue) ? raw("<span class='secured'>beschränkt</span>") : ""
    end
    column I18n.t("active_admin.menues.form.index.column5") do |menue|
      if menue.mapped_to_article?
        link_to(I18n.t("active_admin.menues.form.index.search_link"), admin_articles_path("q[url_name_contains]" => menue.target.to_s.split("/").last), class: "list", title: I18n.t("active_admin.menues.form.index.search_title"))
      else
        link_to(I18n.t("active_admin.menues.form.index.search_link1"), new_admin_article_path(article: {title: menue.title, url_name: menue.target.to_s.split('/').last}), class: "create", title: I18n.t("active_admin.menues.form.index.search_title1"))
      end
    end
    column "" do |menue|
      result = ""
      result += link_to(I18n.t("active_admin.menues.form.column.edit"), edit_admin_menue_path(menue), class: "member_link edit_link edit", title: I18n.t("active_admin.menues.form.column.edit_title"))
      result += link_to(I18n.t("active_admin.menues.form.column.submenu"), new_admin_menue_path(parent: menue), class: "member_link edit_link new_subarticle", title: I18n.t("active_admin.menues.form.column.submenu_title"))
      result += link_to(I18n.t("active_admin.menues.form.column.delete"), admin_menue_path(menue), method: :DELETE, "data-confirm" => I18n.t("active_admin.menues.form.column.delete_confirm"), class: "member_link delete_link delete", title: I18n.t("active_admin.menues.form.column.delete_title"))
      raw(result)
    end
  end

  index as: ActiveAdmin::Views::IndexAsTree, download_links: false do
    title :title
    options [:edit,:new,:destroy]
  end

  sidebar :overview, only: [:index] do
    render partial: "/goldencobra/admin/shared/react_overview",
           locals: {
             url: "/admin/menues/load_overviewtree_as_json",
             object_class: "Goldencobra::Menue",
             link_name: "title",
             url_path: "menue",
             order_by: "title",
             class_name: "menues"
           }
  end

  sidebar :help, only: [:edit, :show] do
    render "/goldencobra/admin/shared/help"
  end

  collection_action :load_overviewtree_as_json do
    if params[:root_id].present?
      objects = Goldencobra::Menue.where(id: params[:root_id]).first.children.reorder(:title)
      cache_key ||= ["menus", params[:root_id], objects.map(&:id), objects.maximum(:updated_at)]

      menus = Rails.cache.fetch(cache_key) do
        Goldencobra::Menue.find(params[:root_id]).children.order(:title).as_json(
          only: [:id, :target, :title],
          methods: [:has_children])
      end
    else
      objects = Goldencobra::Menue.reorder(:title).roots
      cache_key ||= ["menus", objects.map(&:id), objects.maximum(:updated_at)]

      menus = Rails.cache.fetch(cache_key) do
        Goldencobra::Menue.order(:title)
          .roots.as_json(only: [:id, :target, :title], methods: [:has_children])
      end
    end
    render json: Oj.dump({"menues" => menus})
  end

  #batch_action :destroy, false

  batch_action :set_menue_offline, "data-confirm" => I18n.t("active_admin.menues.form.column.batch_action.confirm") do |selection|
    Goldencobra::Menue.find(selection).each do |menue|
      menue.active = false
      menue.save
    end
    flash["notice"] = I18n.t("active_admin.menues.form.column.batch_action.flash")
    redirect_to action: :index
  end

  batch_action :set_menue_online, "data-confirm" => I18n.t("active_admin.menues.form.column.batch_action.confirm1") do |selection|
    Goldencobra::Menue.find(selection).each do |menue|
      menue.active = true
      menue.save
    end
    flash["notice"] = I18n.t("active_admin.menues.form.column.batch_action.flash1")
    redirect_to action: :index
  end

  controller do
    def new
      @menue = Goldencobra::Menue.new(params[:menue])
      if params[:parent] && params[:parent].present?
        @parent = Goldencobra::Menue.find(params[:parent])
        @menue.parent_id = @parent.id
      end
    end
  end

  member_action :revert do
    @version = PaperTrail::Version.find(params[:id])
    if @version.reify
      @version.reify.save!
    else
      @version.item.destroy
    end
    redirect_to :back, notice: "#{I18n.t('active_admin.menues.form.member_action.notice')} #{@version.event}"
  end

  member_action :activate_deactivate_menu_item do
    menu_item = Goldencobra::Menue.find(params[:id])
    if menu_item.active
      menu_item.active = false
      flash[:notice] = I18n.t("active_admin.menues.member_action.flash.menu_item_offline")
    else
      menu_item.active = true
      flash[:notice] = I18n.t("active_admin.menues.member_action.flash.menu_item_online")
    end
    menu_item.save

    redirect_to action: :index
  end

  batch_action :clone, "data-confirm" => I18n.t("active_admin.menues.form.batch_action.confirm_clone") do |selection|
    Goldencobra::Menue.find(selection).each do |menue|
      Goldencobra::Menue.create(
        title: "#{I18n.t('active_admin.menues.form.batch_action.title_clone')} #{menue.title}",
        target: menue.target,
        css_class: menue.css_class,
        active: menue.active,
        parent_id: menue.parent_id,
        sorter: menue.sorter,
        description: menue.description,
        call_to_action_name: menue.call_to_action_name,
        description_title: menue.description_title,
        image_id: menue.image_id
      )
    end
    flash["notice"] = I18n.t("active_admin.menues.form.batch_action.flash_clone")
    redirect_to action: :index
  end

  action_item :prev_item, only: [:edit, :show] do
    render partial: "/goldencobra/admin/shared/prev_item"
  end

  action_item :undo, only: :edit do
    if resource.versions.last
      link_to(I18n.t("active_admin.menues.form.action_item.link_to"), revert_admin_menue_path(id: resource.versions.last), class: "undo")
    end
  end

  action_item :next_item, only: [:edit, :show] do
    render partial: "/goldencobra/admin/shared/next_item"
  end

  controller do
    def show
      show! do |format|
         format.html { redirect_to edit_admin_menue_path(@menue)}
      end
    end
  end
end
