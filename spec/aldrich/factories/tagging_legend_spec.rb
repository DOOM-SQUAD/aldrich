require 'spec_helper'

describe Aldrich::Factories::TaggingLegend do
  let(:tagging_headers) do
    { 'replacements' => 'Replacement Tags',
      'additions'    => 'Appended Tags',
      'deletions'    => "Deleted Tags\r\n" }
  end

  describe '#translated_tags' do
    let(:translated_tags) do
      Aldrich::Factories::TaggingLegend.translated_tags(tagging_headers)
    end

    let(:expected_legend) do
      { 'Replacement Tags' => [Aldrich::TAGGING_REPLACE],
        'Appended Tags'    => [Aldrich::TAGGING_APPEND],
        'Deleted Tags'     => [Aldrich::TAGGING_DELETE] }
    end

    it 'produces the expected legend' do
      expect(translated_tags).to eq(expected_legend)
    end

    context 'a select box is blank' do
      let(:tagging_headers) do
        { 'additions'    => 'Appended Tags',
          'deletions'    => 'Deleted Tags' }
      end

      let(:expected_legend) do
        { 'Appended Tags'    => [Aldrich::TAGGING_APPEND],
          'Deleted Tags'     => [Aldrich::TAGGING_DELETE] }
      end

      it 'produces the expected legend' do
        expect(translated_tags).to eq(expected_legend)
      end
    end
  end
end
