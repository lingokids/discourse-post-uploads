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

  before do
    SiteSetting.authorized_extensions = "#{SiteSetting.authorized_extensions}|mp4"
  end

  context "with local storage" do
    let(:image_upload) { Fabricate(:upload) }
    let(:video_upload) { Fabricate(:video_upload) }
    let(:base_url) { Discourse.base_url }

    before { post.uploads << [video_upload, image_upload] }

    it "includes uploads on topic show" do
      get "/t/#{post.topic.id}.json"

      post = JSON.parse(response.body).dig("post_stream", "posts").first

      expect(response.status).to eq(200)
      expect(post["uploads"]).to eq(
        [
          {
            "extension" => "mp4",
            "short_url" => video_upload.short_url,
            "url" => "#{base_url}#{video_upload.url}"
          },
          {
            "extension" => "png",
            "short_url" => image_upload.short_url,
            "url" => "#{base_url}#{image_upload.url}"
          },
        ]
      )
    end
  end

  context "with S3 storage" do
    let(:image_upload) { Fabricate(:upload_s3) }
    let(:video_upload) { Fabricate(:upload_s3, original_filename: "video.mp4", extension: "mp4") }

    before do
      SiteSetting.enable_s3_uploads = true
      SiteSetting.s3_access_key_id = "key"
      SiteSetting.s3_secret_access_key = "secret"
      SiteSetting.s3_upload_bucket = "test-bucket"

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

  context "with CDN url" do
    let(:image_upload) { Fabricate(:upload_s3) }
    let(:video_upload) { Fabricate(:upload_s3, original_filename: "video.mp4", extension: "mp4") }

    before do
      SiteSetting.enable_s3_uploads = true
      SiteSetting.s3_access_key_id = "key"
      SiteSetting.s3_secret_access_key = "secret"
      SiteSetting.s3_upload_bucket = "test-bucket"
      SiteSetting.s3_cdn_url = "https://assets.test.com"

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
            "url" => Discourse.store.cdn_url(video_upload.url)
          },
          {
            "extension" => "png",
            "short_url" => image_upload.short_url,
            "url" => Discourse.store.cdn_url(image_upload.url)
          },
        ]
      )
    end
  end
end
