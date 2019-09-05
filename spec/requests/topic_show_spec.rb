# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "post serializer" do
  let(:post) do
    raw = <<~RAW
      <p>Post with uploads</p>
      <a href="#{video_upload.url}">
        <img src="#{image_upload.url}">
      </a>
    RAW

    Fabricate(:post, raw: raw)
  end

  let(:image_upload) { Fabricate(:upload) }
  let(:video_upload) { Fabricate(:video_upload) }

  before do
    SiteSetting.authorized_extensions = "#{SiteSetting.authorized_extensions}|mp4"
    post.uploads << [video_upload, image_upload]
  end

  it "includes uploads on topic show" do
    get "/t/#{post.topic.id}.json"

    post = JSON.parse(response.body).dig("post_stream", "posts").first

    expect(response.status).to eq(200)
    expect(post["uploads"]).to eq(
      [
        {
          "extension" => "mp4",
          "short_url" => video_upload.short_url,
          "url" => video_upload.url
        },
        {
          "extension" => "png",
          "short_url" => image_upload.short_url,
          "url" => image_upload.url
        },
      ]
    )
  end
end
