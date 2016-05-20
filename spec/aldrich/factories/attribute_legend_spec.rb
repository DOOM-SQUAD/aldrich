require 'spec_helper'

describe Aldrich::Factories::AttributeLegend do
  let(:field_context) { { 'group_code' => 'Group Code' } }

  let(:attribute_context) do
    {
      "Color" => {
        "name" => "Color",
        "code" => "Color"
      },
      "Size" => {
        "name" => "",
        "code" => ""
      },
      "Width" => {
        "name" => "",
        "code" => ""
      },
      "Cheesiness" => {
        "name" => "Cheesiness\r\n",
        "code" => "Cheese Code\r\n"
      }
    }
  end

  let(:expected_legend) {
    { "Color"       => ["color_attribute_name", "color_attribute_code"],
      "Cheesiness"  => ["cheesiness_attribute_name"],
      "Cheese Code" => ["cheesiness_attribute_code"] }
  }

  let(:translate) do
    Aldrich::Factories::AttributeLegend.translated_attributes(attribute_context)
  end

  describe '.headers' do
    it 'removes unused attribute headers and chomps existing header values' do
      expect(translate).to eq(expected_legend)
    end
  end
end
