#Goldencobra

[![Build Status](https://secure.travis-ci.org/ikusei/Goldencobra.png)](http://travis-ci.org/ikusei/Goldencobra)  
[![Code
Climate](https://codeclimate.com/github/ikusei/Goldencobra/badges/gpa.svg)](https://codeclimate.com/github/ikusei/Goldencobra)

This Project is still under development.
This repository is now in sync with http://git.ikusei.de/projects/GC/repos/basis-modul/browse and now always up to date!

# Powered by
- ActiveAdmin

Installation of Goldencobra into a fresh Ruby on Rails project:

# Requirements
* Ruby 2.2.2+ 
* Rails 4.2.3
* Mysql 5.5.x (tested with e.g. 5.5.19)

# Installation

## Guided Installation wit rvm,git,capistrano and server deploy
```ruby
rails new PROJECTNAME -m https://raw.github.com/ikusei/goldencobra-installer/master/template.rb -d mysql
```

## OR Manual Installation: Create new project
``` ruby
rails new PROJECTNAME -d mysql
```

## Install Goldencobra gem
Add the following to file "PROJECTNAME/Gemfile":
``` ruby
gem 'goldencobra', git: 'git://github.com/ikusei/Goldencobra.git'
gem 'activeadmin', :git => 'git://github.com/ikusei/active_admin.git', :require => 'activeadmin'
```

```ruby
bundle install
```

## Create database
```ruby
rake db:create
```

## Install prerequisites for Goldencobra
```ruby
rake goldencobra:install:migrations
rails generate goldencobra:install
rake db:migrate db:test:prepare
```

## If you want to use goldencobra in a subdirectory 

(http://www.domain.de/subdir/), please modify your config/routes.rb
and setup your domains in "Settings > Domains" in the backendinterface

```ruby
Goldencobra::Domain.pluck(:url_prefix).each do |url_prefix|
    scope url_prefix do
        ActiveAdmin.routes(self)
        devise_for :users, ActiveAdmin::Devise.config
        mount Goldencobra::Engine => "/"
    end
end
```

# Setup Goldencobra

If you want to use Batch Actions in Goldencobra (set a batch of articles offline), you need to uncomment the line `# config.batch_actions = true` in config/initializers/active_admin.rb

This would also be the place where you can override stylesheets and javascripts. Just put them inside the block `# == Register Stylesheets & Javascripts`.

# Create new article types
Nearly every site in Goldencobra is an article. If the default article isn't enough for your needs you can create new article types. There's a generator for that:
`rails generate goldencobra:articletype Thing name:string`

Where "Thing" would be your associated model and "name:string" are the usual ruby attributes.

This will create:
```ruby
    generate model Thing # Your associated model
    generate /app/views/articletypes
    generate /app/views/articletypes/thing # View folder
    # Necessary view files
    generate /app/views/articletypes/thing/_index.html.erb
    generate /app/views/articletypes/thing/_show.html.erb
    generate /app/views/articletypes/thing/_edit_show.html.erb
    generate /app/views/articletypes/thing/_edit_index.html.erb
```
The index and show partials are for fronted display of your article type. The "_edit" partials are for the ActiveAdmin.

"Index" is always the index view of articles of this article_type. The _edit_index enables you to set certain tags to filter your index view. Of course everything is customizable by you.

"Show" is an individual article of this article_type. The "_edit_show" gives you control over the models attributes.


# Settings

We have a quite flexible settings system in place.
In the admin backend you have many values you can customize for your installation.

Important values are
* Goldencobra-Facebook-AppId
* Goldencobra-url (should be set without http:// in front)
* Commentator: If you have a different frontend user model (like 'Visitor') you can set this here. Default is User.
* Bugherd: If you use [Bugherd.com](http://www.bugherd.com) for tracking frontend problems for your website you should enter the project's API key here. You can further decide wich User should be logged in to be able to track bugs.
* You have can enable or disable Solr Search Server and decide wether you want to recreate all menues and widgets after updating them. This might be useful for caching.


When creating articles, a default value is set for open graph image url. Please make sure you provide a default open graph image at "/assets/open-graph.png"


# Usage

## Basic Headers
call in head-section of any view_template to include stylesheets, javascripts (jquery, jqueryui, jquery.tools ...), bugtracker, metatags, airbrake and article_administration element:

```ruby
basic_goldencobra_headers(option={})

# option: {:exclude => ["stylesheets", "javascripts", "bugtracker", "metatags", "article_administration", "airbrake"]}
```

**example:**

```erb
<%= basic_goldencobra_headers(:exclude => ["javascripts","stylesheets"]) %>
```

##Only Activate Bugtracker in Application Layout
place this code in your application layout in header section:
`<%= bugtracker %>`


## Navigation Menu
call in any view_template:

```ruby
navigation_menu(menue_id, option={})

# option: { depth: integer }
#
# 0 = unlimited
# 1 = self
# 2 = self and children 1st grade
# 3 = self and up to children 2nd grade
# default = 0
```

**example:**
renders menue starting with id 1 and only childs of first grade
```ruby
<%= navigation_menu(1, :depth => 1) %>

```
renders menue starting with id 2 and all children as a nested list
```ruby
<%= navigation_menu(2) %>

```
renders menue starting with first Menuitem including title 'MainNavigation' and all children as a nested list
```ruby
<%= navigation_menu("MainNavigation") %>

```
renders menue starting with first Menuitem including title 'MainNavigation' in the submenue 'Sub' and all children as a nested list
```ruby
<%= navigation_menu("Sub/MainNavigation") %>

```
renders menue starting with first Menuitem including title 'MainNavigation' in the submenue 'de' or 'en' depending of your current Locale and all children as a nested list
```ruby
<%= navigation_menu("#{I18n.locale.to_s}/MainNavigation") %>

```

```ruby
<%= navigation_menu("Top-Menue", :submenue_of_article => @article, :class => "ul_submain_nav", :depth => 2, :show_image => false, :show_description_title => false, :show_description => false, :show_call_to_action_name => false) %>
```

## Switching Languages
```erb
<%= link_to "Deutsch", switch_language("de") %>
<%= link_to "Englisch", switch_language("en") %>
```



## Breadcrumb Menue
in your view_templates:
```erb
    <%= breadcrumb() %>
```


## Rendering content in layouts
```erb
<% # Renders contents of different article types %>
<% if @article %>
  <%= render_article_type_content() %>
<% end %>

<%= yield(:article_content) %>
<%= yield(:article_title) %>
<%= yield(:article_subtitle) %>
<%= yield(:article_teaser) %>
```

## Render widgets

Alle DefaultWidgets UND alle ArtikelWidgets mit dem Tag "sidebar" sortiert nach SorterID:
```erb
render_article_widgets(default: true, tagged_with: "sidebar")
```

Alle ArtikelWidgets mit dem Tag "sidebar" sortiert nach SorterID:
```erb
  <%= render_article_widgets(default: false, tagged_with: "sidebar") %>
```

Alle ArtikelWidgets mit dem Tag "sidebar" sortiert nach SorterID:
```erb
  <%= render_article_widgets(tagged_with: "sidebar") %>
```

Alle DefaultWidgets und alle ArtikelWidgets:
```erb
  <%= render_article_widgets(default: true) %>
```

Alle ArtikelWidgets:
```erb
  <%= render_article_widgets() %>
```

Alle DefaultWidgets:
```erb
  <%= render_article_widgets(article: false) %>
```

Alle DefaultWidgets mit dem Tag "sidebar" sortiert nach SorterID:
```erb
  <%= render_article_widgets(article: false, tagged_with: "sidebar") %>
```

Alle Optionen mit Defaultwerten:
```erb
  <%= render_article_widgets(default="false", article="true", tagged_with: "") %>
```


## Render Login and Registration Widgets
in your view_templates:
```erb
    <%= render_login_widget(User) %>
    <%= render_login_widget(Visitor) %>
    <%= render_registration_widget(User) %>
    <%= render_registration_widget(Visitor) %>
```



## Include social media sharing buttons where applicable
```erb
<div id="social_sharing_buttons" class="bottom_buttons">
  <%= yield(:social_sharing_buttons) %>
</div>
```

## Render an image gallery inside article content
```erb
<%= render_article_image_gallery %>
```

# Contributing


## Docker installieren

### Docker für Mac

https://www.docker.com/toolbox

Starte "Docker Quickstart Terminal.app"

=> docker is configured to use the default machine with IP xxx.xxx.xxx.xxx


## Installationsanleitung mit Docker


### Configs aus Templates erstellen:

``` 
cp config/database.yml.tmpl config/database.yml
cp config/initializers/sidekiq.rb.tmpl config/initializers/sidekiq.rb
cp config/unicorn.rb.tmpl config/unicorn.rb
```


### Datenbank Setup
```
docker-compose build
docker-compose run app rake db:setup
```


## Starten der App

```
git pull
docker-compose build
docker-compose up
```

=> visit: http://dockerIP:3000



See the [CONTRIBUTING] document.
Thank you, [contributors]!

[CONTRIBUTING]: CONTRIBUTING.md
[contributors]: https://github.com/ikusei/Goldencobra/graphs/contributors

# License

This project uses CC BY-NC-SA 3.0. See [License]

[License]: CC-LICENSE

# About

Goldencobra is maintained by [ikusei GmbH](http://ikusei.de) in Berlin.  
We like you.
