require 'spec_helper'

describe Aldrich::ModelTools::Detector do
  describe '#detect_model' do
    let(:variant1) { OpenStruct.new(sku: 'SOMETHINGELSE') }

    let(:model_set) { [variant1, variant2] }
    let(:criteria)  { { sku: 'SOMETHING' } }

    let(:detector) { Aldrich::ModelTools::Detector.new(model_set, criteria) }
    let(:detected) { detector.detect_model }

    context 'a matching model exists in the set' do
      let(:variant2) { OpenStruct.new(sku: 'SOMETHING') }

      it 'returns the matching model' do
        expect(detected).to eq(variant2)
      end
    end

    context 'a matching model does not exist in the set' do
      let(:variant2) { OpenStruct.new(sku: 'SOMETHINGELSE') }

      it 'returns nil' do
        expect(detected).to be_nil
      end
    end
  end
end
