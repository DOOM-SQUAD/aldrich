require 'spec_helper'

describe Aldrich::Decorators::Operation do
  let(:id)    { 1 }
  let(:group) { 'sample_group' }

  let(:sku) { 'ZOGM' }
  let(:upc) { '1234' }

  let(:size_attribute_name)  { 'Triple-XL' }
  let(:size_attribute_code)  { 'XXXL' }
  let(:color_attribute_name) { 'Blue' }
  let(:color_attribute_code) { 'BLU' }

  let(:image_urls) do
    "http://example.com/sample.ogg" +
      "#{Aldrich::TAGGING_DELIMITER}http://exmaple.org/c/sample.jpg"
  end

  let(:attributes) do
    { 'sku'                     => sku,
      'upc'                     => upc,
      'size_attribute_name'     => size_attribute_name,
      'size_attribute_code'     => size_attribute_code,
      'color_attribute_name'    => color_attribute_name,
      'color_attribute_code'    => color_attribute_code,
      Aldrich::TAGGING_REPLACE => 'something|somethingelse',
      Aldrich::IMAGE_URLS      => image_urls }
  end

  let(:operation)           { CasualJacket::Operation.new(id, attributes, group) }
  let(:decorated_operation) { Aldrich::Decorators::Operation.new(operation) }

  describe '#attribute_names' do
    let(:result) { decorated_operation.attribute_names }
    let(:names)  { ['Size', 'Color'] }

    it 'returns an array of attribute names' do
      expect(result).to eq (names)
    end
  end

  describe '#attribute' do
    let(:attribute_name) { 'color' }
    let(:result)         { decorated_operation.attribute(attribute_name) }

    let(:expected_hash)  do
      { name: 'Blue',
        code: 'BLU' }
    end

    it 'returns values for construction of an AttributeValue model' do
      expect(result).to eq(expected_hash)
    end
  end

  describe '#literal_fields' do
    let(:expected_fields) { { 'sku' => sku, 'upc' => upc } }

    it 'properly strips attribute and tagging information from the attribute set' do
      expect(decorated_operation.literal_fields).to eq(expected_fields)
    end
  end

  describe '#value_for' do
    let(:key)    { 'sku' }
    let(:result) { decorated_operation.value_for(key) }

    it 'returns values for product model attributes' do
      expect(result).to eq(sku)
    end
  end

  describe '#attributes_present?' do
    context 'no attributes are configured' do
      let(:attributes) { { 'sku' => sku, 'upc' => upc } }

      it 'returns false' do
        expect(decorated_operation.attributes_present?).to be_falsey
      end
    end

    context 'attributes are configure but not supplied' do
      let(:attributes) do
        { 'sku'                  => sku,
          'upc'                  => upc,
          'size_attribute_name'  => nil,
          'size_attribute_code'  => nil }
      end

      it 'returns false' do
        expect(decorated_operation.attributes_present?).to be_falsey
      end
    end

    context 'attributes are configured and supplied' do
      let(:attributes) do
        { 'sku'                  => sku,
          'upc'                  => upc,
          'size_attribute_name'  => nil,
          'size_attribute_code'  => nil,
          'color_attribute_name' => color_attribute_name,
          'color_attribute_code' => color_attribute_code }
      end

      it 'returns false' do
        expect(decorated_operation.attributes_present?).to be_truthy
      end
    end

    describe '#tag_replacement' do
      let(:attributes) { { Aldrich::TAGGING_REPLACE => "zogm|wtf|bbq" } }
      let(:expected_tags) { ['zogm', 'wtf', 'bbq'] }

      it 'returns the expected split array of tags' do
        expect(decorated_operation.tag_replacement).to match_array(expected_tags)
      end

      context 'the set of tags for replacement is nil' do
        let(:attributes) { { Aldrich::TAGGING_REPLACE => nil } }

        it 'returns an empty array' do
          expect(decorated_operation.tag_replacement).to match_array([])
        end
      end
    end

    describe '#tag_additions' do
      let(:attributes) { { Aldrich::TAGGING_APPEND => "zogm|wtf|bbq" } }
      let(:expected_tags) { ['zogm', 'wtf', 'bbq'] }

      it 'returns the expected split array of tags' do
        expect(decorated_operation.tag_additions).to match_array(expected_tags)
      end
    end

    describe '#tag_deletions' do
      let(:attributes) { { Aldrich::TAGGING_DELETE => "zogm|wtf|bbq" } }
      let(:expected_tags) { ['zogm', 'wtf', 'bbq'] }

      it 'returns the expected split array of tags' do
        expect(decorated_operation.tag_deletions).to match_array(expected_tags)
      end
    end

    describe '#image_urls' do
      let(:expected_urls) { image_urls.split(Aldrich::TAGGING_DELIMITER) }

      it 'returns the expected array of image urls' do
        expect(decorated_operation.image_urls).to match_array(expected_urls)
      end
    end
  end
end
