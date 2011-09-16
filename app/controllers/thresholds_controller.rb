require "base64"
require "geopod"
require "json"
require "openssl"

class ThresholdsController < ApplicationController
    
    def show
        if params["data"] and params["sig"]
            data = JSON.parse(Base64.urlsafe_decode64(params["data"]))
            
            signature = Base64.urlsafe_decode64(params["sig"])
            signature_check = OpenSSL::HMAC.digest("sha256", GEOPOD_CONFIG[:consumer_secret], params["data"])
            
            if signature != signature_check
                render :nothing => true, :status => :forbidden
            end
            
            # Check the signature here
            if data["subdomain"]
                @geopod = Geopod.find_by_subdomain(data["subdomain"])
                gc = GeopodClient.new(@geopod.subdomain, @geopod.access_token, @geopod.access_token_secret, GEOPOD_CONFIG[:consumer_key], GEOPOD_CONFIG[:consumer_secret], GEOPOD_CONFIG[:api_host])
                @points = gc.request('/point/', params={'markers[]' => 'his'})
                @points = [{'id' => '149eecb3-4cb9224d'}]
                
                @start = params['start'] ? params['start'] : Date.today.strftime("%Y-%m-%d")
                @end = params['end'] ? params['end'] : Date.today.strftime("%Y-%m-%d")
            end
        end
    end
    
    def data
        point_ids = params.has_key?("points") ? params["points"] : []
        start_date = params.has_key?("start") ? params["start"] : Date.today.strftime("%Y-%m-%d")
        end_date = params.has_key?("end") ? params["end"] : Date.today.strftime("%Y-%m-%d")
        
        subdomain = params["subdomain"]
        if not subdomain then render :nothing => true, :status => :bad_request end
        geopod = Geopod.find_by_subdomain(subdomain)
        gc = GeopodClient.new(geopod.subdomain, geopod.access_token, geopod.access_token_secret, GEOPOD_CONFIG[:consumer_key], GEOPOD_CONFIG[:consumer_secret], GEOPOD_CONFIG[:api_host])
        
        data_series = []
        point_ids.each do |point_id|
            
            point = gc.request("/history/#{point_id}/#{start_date}/#{end_date}/")
            
            if not point.has_key?("error")
                data_series.push({
                    "name" => point["name"],
                    "unit" => point["unit"],
                    "data" => point["data"],
                    "point_id" => point_id
                })
            end
        end
        
        graph_data = {
            "start_date" => start_date,
            "end_date" => end_date,
            "utc_offset" => -Time.now.utc_offset * 1000,
            "series" => data_series,
        }
        
        render :json => graph_data
    end
    
    def auth
        if request.post?
            if params[:subdomain]
                geopod = Geopod.find_or_create_by_subdomain(:subdomain => params[:subdomain])
                geopod.name = params[:name]
                geopod.access_token = params[:access_token]
                geopod.access_token_secret = params[:access_token_secret]
                geopod.save
                render :nothing => true, :status => :ok
            else
                render :nothing => true, :status => :bad_request
            end
        else
            render :nothing => true, :status => :method_not_allowed
        end
        return true
    end
    
end
