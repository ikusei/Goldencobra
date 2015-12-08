# encoding: utf-8

ActiveAdmin.register_page "Dashboard" do
  menu priority: 0

  content do
    columns do
      column do
        panel "Suche nach einem Artikel", priority: 1, if: proc{can?(:update, Goldencobra::Article)} do
          div select_tag :article_id, nil, class: "get_goldencobra_articles_per_remote",
              id: "dashboard_article_search", "data-placeholder" => "Artikel wählen"
        end
      end
    end

    #eine Zeile
    columns do
      #eine Spalte
      column do
        panel I18n.t("active_admin.dashboards.article_section"), priority: 1, if: proc{can?(:update, Goldencobra::Article)} do
          table do
            tr do
              [
                I18n.t("activerecord.attributes.goldencobra/article.title"),
                I18n.t("activerecord.attributes.goldencobra/article.created_at"),
                ""
              ].each do |sa|
                th sa
              end
            end

            Goldencobra::Article.recent(5).collect do |article|
              tr do
                td article.title
                td l(article.created_at, format: :short)
                result = link_to(t(:view), article.public_url, class: "member_link edit_link view",
                          title: I18n.t("active_admin.dashboards.title1"), target: "_blank")
                result += link_to(t(:edit), admin_article_path(article),
                          class: "member_link edit_link edit",
                          title: I18n.t('active_admin.dashboards.title2'))
                result += link_to(t(:new_subarticle), new_admin_article_path(parent: article),
                          class: "member_link edit_link new_subarticle",
                          title: I18n.t('active_admin.dashboards.title3'))
                td result
              end
            end
          end

          table do
            tr do
              td link_to(I18n.t("active_admin.dashboards.new_link"), admin_article_path("new"))
            end
          end
        end
      end
    end # end columns

    columns do
      #eine Spalte
      column do
        panel I18n.t("active_admin.dashboards.widget_section"), priority: 2, if: proc{can?(:update, Goldencobra::Widget)} do
          table do
            tr do
              [
                I18n.t("activerecord.attributes.goldencobra/widget.title"),
                I18n.t("activerecord.attributes.goldencobra/widget.created_at"),
                ""
              ].each do |sa|
                th sa
              end
            end

            Goldencobra::Widget.recent(5).collect do |widget|
              tr do
                td widget.title
                td l(widget.created_at, format: :short)
                td link_to(t(:edit), admin_widget_path(widget), class: "member_link edit_link edit",
                    title: I18n.t("active_admin.dashboards.title4"))
              end
            end
          end
        end
      end

      #eine Spalte
      column do
        panel I18n.t("active_admin.dashboards.vita_steps"), priority: 2, if: proc{can?(:update, Goldencobra::Vita)} do
          table do
            tr do
              [
                "Source",
                I18n.t("activerecord.attributes.goldencobra/widget.title"),
                "Description",
                ""
              ].each do |sa|
                th sa
              end
            end

            Goldencobra::Vita.where(status_cd: 2).last(5).each do |vita|
              tr do
                td "#{vita.loggable_type} ID:#{vita.loggable_id}"
                td vita.title
                td vita.description
                td l(vita.created_at, format: :short)
              end
            end
          end
        end
      end
    end # end columns




  # == Render Partial Section
  # The block is rendered within the context of the view, so you can
  # easily render a partial rather than build content in ruby.
  #
  #   section "Recent Posts" do
  #     div do
  #       render "recent_posts" # => this will render /app/views/admin/dashboard/_recent_posts.html.erb
  #     end
  #   end

  # == Section Ordering
  # The dashboard sections are ordered by a given priority from top left to
  # bottom right. The default priority is 10. By giving a section numerically lower
  # priority it will be sorted higher. For example:
  #
  #   section 'last_updated_articles', priority: 1
  #   section "Recent User", priority: 1
  #
  # Will render the "Recent Users" then the "Recent Posts" sections on the dashboard.
  end
end
