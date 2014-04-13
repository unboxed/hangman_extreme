module SocialHelper
 def share_url
   if mxit_request?
     'Share with your <a href="mxit://[communityportal]/RecommendPage?ItemId=7297721" type="mxit/service-navigation">friends</a>'
   elsif facebook_user?
     '<a href="#" onclick="fb_invite_friends();">Share with your friends</a>'
   end
 end
end
