# Discourse Post Uploads

Discourse Post Uploads is a plugin to expose a Post's file uploads on the serializer data.

## Installation

Follow [Install a Plugin](https://meta.discourse.org/t/install-a-plugin/19157)
how-to from the official Discourse Meta, using `git clone https://github.com/lingokids/discourse-post-uploads.git`
as the plugin command.

## Usage
The plugin is enabled by default. No configuration needed.

Any request that includes full Post data will include its uploads.

## Testing
To run tests:

`LOAD_PLUGINS=1 bundle exec rspec plugins/discourse-post-uploads/spec/`

## Feedback

If you have issues or suggestions for the plugin, please bring them up on
[Discourse Meta](https://meta.discourse.org).
