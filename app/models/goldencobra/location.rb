# encoding: utf-8

# == Schema Information
#
# Table name: goldencobra_locations
#
#  id              :integer          not null, primary key
#  lat             :string(255)
#  lng             :string(255)
#  street          :string(255)
#  city            :string(255)
#  zip             :string(255)
#  region          :string(255)
#  country         :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  title           :string(255)
#  street_number   :string(255)
#  locateable_type :string(255)
#  locateable_id   :integer
#

module Goldencobra
  class Location < ActiveRecord::Base
    attr_accessible :lat, :lng, :street, :city, :zip, :region, :country, :title,
                    :street_number, :locateable_type, :locateable_id,
                    :manual_geocoding, :skip_geocode

    attr_accessor :skip_geocode

    geocoded_by :complete_location, latitude: :lat, longitude: :lng
    after_validation :geocode, unless: :skip_geocoding_once_or_always


    liquid_methods :street, :city, :zip, :region, :country, :title
    belongs_to :locateable, polymorphic: true

    def complete_location
      result = ""
      result += "#{self.street}" if self.street.present?
      result += " #{self.street_number}" if self.street_number.present?
      result += ", #{self.zip}" if self.zip.present?
      result += " #{self.city}" if self.city.present?
    end

    def title
      self.complete_location
    end

    def skip_geocoding_once_or_always
      (Goldencobra::Setting.for_key("goldencobra.locations.geocoding") == "false" ) ||
      self.skip_geocode || self.manual_geocoding
    end
  end
end
