class InstagramAccount < SnsAccount
  def url
    "https://www.instagram.com/#{account}/"
  end
end
