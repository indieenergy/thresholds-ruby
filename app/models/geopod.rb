class Geopod < ActiveRecord::Base
    validates :subdomain, :uniqueness => true, :presence => true
end
