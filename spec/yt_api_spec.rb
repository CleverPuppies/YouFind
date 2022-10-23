# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Tests Youtube API library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<RAPIDAPI_KEY>') { YT_API_KEY }
    c.filter_sensitive_data('<RAPIDAPI_KEY_ESC>') { CGI.escape(YT_API_KEY) }
  end

  before do
    VCR.insert_cassette CASSETTE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Video information' do
    it 'HAPPY: should provide correct video info' do
      video = YouFind::YoutubeAPI.new(YT_API_KEY).video(VIDEO_ID)
      _(video.title).must_equal CORRECT['title']
      _(video.url).must_equal CORRECT['url']
      _(video.id).must_equal CORRECT['id']
      _(video.duration).must_equal CORRECT['duration']
    end

    it 'SAD: should raise exception when unauthorized' do
      _(proc do
        YouFind::YoutubeAPI.new('BAD_TOKEN').video('cleverpuppies')
      end).must_raise YouFind::YoutubeAPI::Errors::Forbidden
    end
  end

  describe 'Captions' do
    before do
      @video = YouFind::YoutubeAPI.new(YT_API_KEY).video(VIDEO_ID)
    end

    it 'HAPPY: should be able to retrieve captions' do
      _(@video.captions).wont_be_nil
    end

    it 'HAPPY: should have start, duration, text' do
      first_caption = @video.captions.first
      _(first_caption['start']).must_equal CORRECT['captions'][0]['start']
      _(first_caption['dur']).must_equal CORRECT['captions'][0]['dur']
      _(first_caption['text']).must_equal CORRECT['captions'][0]['text']
    end
  end
end
