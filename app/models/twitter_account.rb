class TwitterAccount < SnsAccount
  def url
    "https://twitter.com/#{account}"
  end

  def timeline_url
    "https://twitter.com/#{account}?ref_src=twsrc%5Etfw"
  end
end
