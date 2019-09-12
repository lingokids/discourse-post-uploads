# name: Discourse Post Uploads
# about: Expose a given Post's file uploads on the serializer data
# version: 0.1
# authors: Lingokids
# url: https://github.com/lingokids

enabled_site_setting :discourse_post_uploads_enabled

PLUGIN_NAME ||= "DiscoursePostUploads".freeze

after_initialize do
  add_to_serializer :post, :uploads do
    object
      &.uploads
      &.map do |upload|
        upload
          .slice("extension")
          .merge({
            short_url: upload.short_url,
            url: begin
              if Discourse.store.external?
                upload.url.start_with?("//") ? Discourse.store.cdn_url(upload.url) : "#{Discourse.base_url}#{upload.url}"
              else
                "#{Discourse.base_url}#{upload.url}"
              end
            end
          })
      end
  end
end
