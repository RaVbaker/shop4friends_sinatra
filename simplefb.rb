require "net/http"
require "net/https"
require "cgi"

require "json"

class SimpleFB       
  # attributes: :secret, :api_key, :app_id, :redirect_uri, :scope, :response_type
  attr_reader :params 
  attr_accessor :access_token
  
  def initialize options = {}
    @params = {:response_type => "code", :scope => "email"}.merge(options)
  end
            
  # auth url for redirect
  def auth_url
    "https://www.facebook.com/dialog/oauth/?scope=#{@params[:scope]}&client_id=#{@params[:app_id]}&redirect_uri=#{@params[:redirect_uri]}&response_type=#{@params[:response_type]}"
  end
  
  def code= code
    @params[:code] = code
    fetch_access_token unless @access_token
  end
  
  def fetch_access_token                                                     
    access_token_string = get('oauth/access_token', {:client_id => @params[:app_id], :redirect_uri => @params[:redirect_uri], :client_secret => @params[:secret], :code => @params[:code]}, false)
    
    self.access_token= access_token_string
  end               
  
  def photo_url id
    "https://graph.facebook.com/#{id}/picture"
  end        
  
  def url id
    "https://facebook.com/#{id}"
  end
  
  def get resource, params={}, parse_as_json = true
    params = {} if params.nil?
    
    http = Net::HTTP.new "graph.facebook.com", 443
    http.use_ssl = true             
    p url = "/#{resource}?#{@access_token if @access_token and parse_as_json}&#{hash_to_query_string params}"
    request = Net::HTTP::Get.new url
    response = http.request request
    @last_response = parse_as_json && JSON.parse(response.body) || response.body
    
    if (@last_response.is_a?(Hash) && @last_response["error"]) 
      raise "Error: #{@last_response}"
    end
    @last_response
  end  
  
  def post resource, params
    raise "Not implemented Yet!"
  end
  
  def method_missing name, *args
    if %w{me search}.include? name.to_s.split('_').first
       return self.method(:get).call(name.to_s.gsub('_','/'), args.first)
    end 
    raise "Method #{name} is not defined!"
  end        
  
  private 
    def hash_to_query_string hash
      hash.map do |k,v|            
         CGI::escape(k.to_s)+"="+CGI::escape(v.to_s)
      end.join("&")
    end
end