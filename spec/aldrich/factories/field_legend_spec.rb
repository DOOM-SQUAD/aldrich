require 'spec_helper'

describe Aldrich::Factories::FieldLegend do
  let(:factory) { Aldrich::Factories::FieldLegend.new(field_headers) }

  describe '#translated_fields' do
    let(:field_headers) do
      { 'upc_code'              => 'UPC Code',
        'quantity_at_vendor'    => 'Quantity',
        'quantity_in_warehouse' => 'Quantity',
        'reorder_multiple'      => "R. O. M.\r\n",
        'price_cents'           => '' }
    end

    let(:result) { factory.translated_fields }

    let(:expected_hash) do
      { 'UPC Code' => ['upc_code'],
        'Quantity' => ['quantity_at_vendor', 'quantity_in_warehouse'],
        'R. O. M.' => ['reorder_multiple'] }
    end

    it 'produces the expected hash' do
      expect(result).to eq(expected_hash)
    end
  end
end
