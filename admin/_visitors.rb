# Deprecated and will be removed in GC 2.1
# 
# # encoding: utf-8

# ActiveAdmin.register Visitor do
#   menu :priority => 10, :if => proc{can?(:update, Visitor)}

#   filter :firstname
#   filter :lastname
#   filter :email

#   index :download_links => proc{ Goldencobra::Setting.for_key("goldencobra.backend.index.download_links") == "true" }.call do
#     selectable_column
#     column :first_name
#     column :last_name
#     column :username
#     column :email
#     column :last_sign_in_at
#     column :sign_in_count
#     column :agb, sortable: :agb do |v|
#       v.agb ? I18n.t('active_admin.visitors.yes_check') : I18n.t('active_admin.visitors.no_check')
#     end
#     column I18n.t('active_admin.visitors.status') do |visitor|
#       I18n.t('active_admin.visitors.status2') if visitor.locked_at?
#     end
#     column :newsletter, sortable: :newsletter do |v|
#       v.newsletter ? I18n.t('active_admin.visitors.yes_check') : I18n.t('active_admin.visitors.no_check')
#     end
#     actions
#   end

#   form :html => { :enctype => "multipart/form-data" }  do |f|
#     f.actions
#     f.inputs I18n.t('active_admin.visitors.general') do
#       f.input :first_name
#       f.input :last_name
#       f.input :username
#       f.input :email
#       f.input :password, hint: I18n.t('active_admin.visitors.hint1')
#       f.input :password_confirmation, hint: I18n.t('active_admin.visitors.hint2')
#       f.input :provider
#       f.input :uid, hint: I18n.t('active_admin.visitors.hint3')
#       f.input :agb
#       f.input :newsletter
#       if current_user.has_role?('admin')
#         f.input :roles, :as => :check_boxes, :collection => Goldencobra::Role.all
#       else
#         f.input :id, :as => :hidden
#       end
#       f.input :id, :as => :hidden
#     end
#     f.actions
#   end

#   action_item :lock, :only => :edit do
#     if resource.locked_at?
#       result = link_to('Account entsperren', switch_lock_status_admin_visitor_path(resource.id))
#     else
#       result = link_to('Account sperren', switch_lock_status_admin_visitor_path(resource.id))
#     end
#     raw(result)
#   end

#   member_action :switch_lock_status do
#     visitor = Visitor.find(params[:id])
#     if visitor.locked_at?
#       visitor.locked_at = nil
#       status = I18n.t('active_admin.visitors.status1')
#     else
#       visitor.locked_at = Time.now
#       status = I18n.t('active_admin.visitors.status2')
#     end
#     visitor.save
#     flash[:notice] = "#{I18n.t('active_admin.visitors.flash')} #{status}"
#     redirect_to :action => :edit
#   end

#   controller do
#     def update
#       @visitor = Visitor.find(params[:id])
#       if params[:visitor] && params[:visitor][:password].present? && params[:visitor][:password_confirmation].present?
#         @visitor.update_attributes(params[:visitor])
#       else
#         @visitor.update_without_password(params[:visitor]) if params[:visitor].present?
#       end
#       render action: :edit
#     end
#   end

#   action_item :prev_item, only: [:edit, :show] do
#     render partial: '/goldencobra/admin/shared/prev_item'
#   end

#   action_item :next_item, only: [:edit, :show] do
#     render partial: '/goldencobra/admin/shared/next_item'
#   end
# end