#-- copyright
# OpenProject Documents Plugin
#
# Former OpenProject Core functionality extracted into a plugin.
#
# Copyright (C) 2009-2014 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++


module OpenProject::Documents
  class Engine < ::Rails::Engine
    engine_name :openproject_documents

    include OpenProject::Plugins::ActsAsOpEngine

    register 'openproject-documents',
             :author_url => "http://www.finn.de",
             :requires_openproject => ">= 3.0.0" do

      menu :project_menu, :documents,
                          { :controller => '/documents', :action => 'index' },
                          :param => :project_id,
                          :caption => :label_document_plural,
                          :html => { :class => 'icon2 icon-book1' }

      permission :manage_documents, {:documents => [:new, :create, :edit, :update, :destroy, :add_attachment]}, :require => :loggedin
      permission :view_documents, :documents => [:index, :show, :download]

      Redmine::Notifiable.all << Redmine::Notifiable.new('document_added')

      Redmine::Activity.map do |activity|
        activity.register :documents, class_name: 'Activity::DocumentActivityProvider', default: false
      end

      Redmine::Search.register :documents
    end

    patches [:ApplicationHelper, :CustomFieldsHelper, :Project]

    assets %w(documents.css)

    initializer "documents.register_hooks" do
      require 'open_project/documents/hooks'
    end

    initializer 'documents.register_observers' do |app|
      ActiveRecord::Base.observers.push :document_observer
    end

    config.to_prepare do
      require_dependency 'document_category'
      require_dependency 'document_category_custom_field'
    end
  end
end
