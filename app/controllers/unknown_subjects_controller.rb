#
# microphisher - a spear phishing support tool
#
# Created by Ulisses Albuquerque & Joaquim Espinhara
# Copyright (C) 2013 Trustwave Holdings, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

class UnknownSubjectsController < ApplicationController
  def index
    @unknown_subjects = current_user.unknown_subjects.asc(:name)
  end
  
  def show
    @unknown_subject = current_user.unknown_subjects.find(params[:id])
    
    # TODO: Refactor this code to perform aggregation in Mongo instead
    # of Ruby
    geo_sources = @unknown_subject.status_updates.ne(coordinates: nil)
    @geo_enabled_sources = Hash[geo_sources.pluck(:source).uniq.map do |src|
    	src_clean = src.gsub(/^<.+>(.+)<.+>$/, '\1')
    	src_regexp = Regexp.new(src_clean)
    	[ src_clean, geo_sources.where(source: src_regexp).count ]
    end]
  end
  
  def new
    @unknown_subject = current_user.unknown_subjects.new
  end
  
  def create
    @unknown_subject = current_user.unknown_subjects.new(params[:unknown_subject])
    @unknown_subject.save!
    redirect_to @unknown_subject
  end

  def edit
    @unknown_subject = current_user.unknown_subjects.find(params[:id])
  end

  def update
    @unknown_subject = current_user.unknown_subjects.find(params[:id])
    @unknown_subject.update_attributes(params[:unknown_subject])
    @unknown_subject.save!
    redirect_to @unknown_subject
  end  

  def destroy
    @unknown_subject = current_user.unknown_subjects.find(params[:id])
    @unknown_subject.destroy
    redirect_to unknown_subjects_path
  end
  
  def export_profile
  	@unknown_subject = current_user.unknown_subjects.find(params[:id])
		geo_updates = @unknown_subject.status_updates.ne(coordinates: nil)
		@status_updates = geo_updates.where(source: Regexp.new(params[:source]))
  	
  	respond_to do |format|
  		format.kml
  	end
  end
end
