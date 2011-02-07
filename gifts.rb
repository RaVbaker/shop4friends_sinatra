require 'sucker'  

class Gifts
  def initialize options = {}
    @worker = Sucker.new(options)
  end
  
  def find phrase, field="Keywords", index="All"    
  
    @worker << {
      "Operation"   => "ItemSearch",
      "SearchIndex" => index,
      "ResponseGroup" => "Small,Images",
      field      =>  phrase}                         
      
      @response = @worker.get                     
      p @response
      @response.to_hash
  end
      
  # according to docs: http://s3.amazonaws.com/awsdocs/Associates/2010-11-01/prod-adv-api-qrc-2010-11-01.pdf
  def indexes
    ['All','Apparel','Automotive','Baby','Beauty','Blended','Books','Classical','DVD','Electronics','Grocery','HealthPersonalCare','HomeGarden','HomeImprovement','Jewelry','KindleStore','Kitchen','Lighting','MP3Downloads','Music','MusicTracks','MusicalInstruments','OfficeProducts','OutdoorLiving','Outlet','PetSupplies','PCHardware','Shoes','Software','SoftwareVideoGames','SportingGoods','Tools','Toys','VHS','Video','VideoGames','Watches']
  end
  
  # according to docs: http://s3.amazonaws.com/awsdocs/Associates/2010-11-01/prod-adv-api-qrc-2010-11-01.pdf
  def fields
    %w{
      Actor 
      Artist 
      AudienceRating 
      Author 
      Availability 
      Brand 
      BrowseNode 
      City 
      Composer 
      Condition (Default: New) 
      Conductor 
      Cuisine 
      DeliveryMethod 
      Director 
      DisableParentAsinSubstitution 
      ISPUPostalCode 
      ItemPage 
      Keywords 
      Manufacturer 
      MaximumPrice 
      MerchantId (Default: Amazon) 
      MinimumPrice 
      MusicLabel 
      Neighborhood 
      Orchestra 
      PostalCode 
      Power 
      Publisher 
      RelatedItemPage 
      RelationshipType (Req. with RelatedItems RG) 
      ReleaseDate 
      ReviewSort (See DG, Default: -SubmissionDate) 
      Sort (See DG) 
      State 
      TagPage (1-400) 
      TagSort (See DG, Default: -Usages)  
      TagsPerPage (Pos. Integer) 
      TextStream 
      Title
    }      
  end
end