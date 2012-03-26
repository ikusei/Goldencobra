# == Schema Information
#
# Table name: goldencobra_articles
#
#  id                       :integer(4)      not null, primary key
#  title                    :string(255)
#  created_at               :datetime        not null
#  updated_at               :datetime        not null
#  url_name                 :string(255)
#  slug                     :string(255)
#  content                  :text
#  teaser                   :text
#  ancestry                 :string(255)
#  startpage                :boolean(1)      default(FALSE)
#  active                   :boolean(1)      default(TRUE)
#  subtitle                 :string(255)
#  summary                  :text
#  context_info             :text
#  canonical_url            :string(255)
#  robots_no_index          :boolean(1)      default(FALSE)
#  breadcrumb               :string(255)
#  template_file            :string(255)
#  article_for_index_id     :integer(4)
#  article_for_index_levels :integer(4)      default(0)
#  article_for_index_count  :integer(4)      default(0)
#  article_for_index_images :boolean(1)      default(FALSE)
#

module Goldencobra
  class Article < ActiveRecord::Base
    extend FriendlyId
    attr_accessor :hint_label
    friendly_id :url_name, use: [:slugged, :history]
    has_ancestry :orphan_strategy => :restrict
    acts_as_taggable_on :tags #https://github.com/mbleigh/acts-as-taggable-on
    MetatagNames = ["Title Tag", "Meta Description", "Keywords", "OpenGraph Title", "OpenGraph Type", "OpenGraph URL", "OpenGraph Image"]
    has_many :metatags
    accepts_nested_attributes_for :metatags, :allow_destroy => true, :reject_if => proc { |attributes| attributes['value'].blank? }
    has_many :images, :through => :article_images, :class_name => Goldencobra::Upload
    has_many :article_images
    has_many :article_widgets
    has_many :widgets, :through => :article_widgets
    accepts_nested_attributes_for :article_images    
    
    validates_presence_of :title
    validates_presence_of :url_name
    validates_format_of :url_name, :with => /^[\w\d-]+$/
    
    before_save :verify_existens_of_url_name_and_slug
    attr_protected :startpage
    
    scope :active, where(:active => true)
    scope :startpage, where(:startpage => true)    

    scope :parent_ids_in_eq, lambda { |art_id| subtree_of(art_id) }
    search_methods :parent_ids_in_eq
    
    scope :parent_ids_in, lambda { |art_id| subtree_of(art_id) }
    search_methods :parent_ids_in
     
    def public_url
      return "/" if self.startpage
      "/#{self.path.map{|a| a.url_name if !a.is_root?}.compact.join("/")}"
    end 
    
    def verify_existens_of_url_name_and_slug
      self.url_name = self.title if self.url_name.blank?
      self.slug = self.url_name if self.slug.blank?
    end
    
    def self.templates_for_select
      Dir.glob(File.join(::Rails.root, "app", "views", "layouts", "*.html.erb")).map{|a| File.basename(a, ".html.erb")}.delete_if{|a| a =~ /^_/ }
    end
    
    def selected_layout
      if self.template_file.blank?
        "application"
      else
        self.template_file
      end
    end
    
    def breadcrumb_name
      if self.breadcrumb.present?
        return self.breadcrumb
      else
        return self.title
      end
    end
    
    def public_teaser
      return self.teaser if self.teaser.present?
      return self.summary if self.teaser.blank? && self.summary.present?
      return self.content[0..200] if self.teaser.blank? && self.summary.blank?
    end
    
    def article_for_index_limit
      if self.article_for_index_count.to_i <= 0
        return 1000
      else
        self.article_for_index_count.to_i
      end
    end
    
    def mark_as_startpage!
      Article.startpage.each do |a|
        a.startpage = false
        a.save
      end
      self.startpage = true
      self.save
    end
    
    def is_startpage?
      self.startpage
    end  
    
    def metatag(name)
      return "" if !MetatagNames.include?(name) 
      metatag = self.metatags.find_by_name(name)
      metatag.value if metatag
    end
      
  end
end

#parent           Returns the parent of the record, nil for a root node
#parent_id        Returns the id of the parent of the record, nil for a root node
#root             Returns the root of the tree the record is in, self for a root node
#root_id          Returns the id of the root of the tree the record is in
#is_root?         Returns true if the record is a root node, false otherwise
#ancestor_ids     Returns a list of ancestor ids, starting with the root id and ending with the parent id
#ancestors        Scopes the model on ancestors of the record
#path_ids         Returns a list the path ids, starting with the root id and ending with the node's own id
#path             Scopes model on path records of the record
#children         Scopes the model on children of the record
#child_ids        Returns a list of child ids
#has_children?    Returns true if the record has any children, false otherwise
#is_childless?    Returns true is the record has no childen, false otherwise
#siblings         Scopes the model on siblings of the record, the record itself is included
#sibling_ids      Returns a list of sibling ids
#has_siblings?    Returns true if the record's parent has more than one child
#is_only_child?   Returns true if the record is the only child of its parent
#descendants      Scopes the model on direct and indirect children of the record
#descendant_ids   Returns a list of a descendant ids
#subtree          Scopes the model on descendants and itself
#subtree_ids      Returns a list of all ids in the record's subtree
#depth            Return the depth of the node, root nodes are at depth 0

