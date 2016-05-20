require 'spec_helper'

describe Aldrich::OperationGroup do
  let(:group)   { 'ZOGM' }
  let(:product) { double('product', sku: group) }

  let(:invalid_mode_error) { Aldrich::Errors::InvalidImportMode.new(import, group) }

  let(:import)     { Aldrich::Models::Import.new }
  let(:operations) { [double('operation', group: group)] }

  let(:operation_group) { Aldrich::OperationGroup.new(import, operations) }

  before do
    allow(Aldrich::ImporterErrorHandler).to receive(:cache_importer_error)
  end

  describe 'simulate!' do
    let(:perform_simulation) { operation_group.simulate! }

    before do
      allow(Aldrich::Processors::ModelValidator).to receive(:perform!)
    end

    context 'an invalid import mode was selected for the given set of operations' do
      let(:handler)       { Aldrich::ImporterErrorHandler }
      let(:expected_args) { [import, group, invalid_mode_error] }

      before do
        allow(operation_group).to receive(:model).and_raise(invalid_mode_error)
      end

      it 'should not raise an error' do
        expect { perform_simulation }.to_not raise_error
      end

      it 'should cache the expected error' do
        perform_simulation
        expect(handler).to have_received(:cache_importer_error).with(*expected_args)
      end
    end

    context 'rows for a product in the spreadsheet do not match across all rows' do
      let(:cannot_infer_model_error) do
        Aldrich::Errors::CannotInferModel.new(group)
      end

      let(:handler)       { Aldrich::ImporterErrorHandler }
      let(:expected_args) { [import, group, cannot_infer_model_error] }

      before do
        allow(operation_group).to receive(:model).and_raise(cannot_infer_model_error)
      end

      it 'should not raise an error' do
        expect { perform_simulation }.to_not raise_error
      end

      it 'should cache the expected error' do
        perform_simulation
        expect(handler).to have_received(:cache_importer_error).with(*expected_args)
      end
    end
  end

  describe 'import!' do
    let(:perform_import) { operation_group.import! }

    before do
      allow(Aldrich::Processors::ModelPersistor).to receive(:perform!)
    end

    context 'an invalid import mode was selected for the given set of operations' do
      let(:handler)       { Aldrich::ImporterErrorHandler }
      let(:expected_args) { [import, group, invalid_mode_error] }

      before do
        allow(operation_group).to receive(:model).and_raise(invalid_mode_error)
      end

      it 'should not raise an error' do
        expect { perform_import }.to_not raise_error
      end

      it 'should cache the expected error' do
        perform_import
        expect(handler).to have_received(:cache_importer_error).with(*expected_args)
      end
    end

    context 'a product fails to pass validations upon saving' do
      let(:transaction_failed_error) do
        Aldrich::Errors::ModelTransactionFailed.new(product)
      end

      before do
        allow(operation_group).to receive(:model).and_raise(transaction_failed_error)
      end

      it 'should not raise an error' do
        expect { perform_import }.to_not raise_error
      end

    end

    context 'a product image url is not formed properly' do
      let(:uri_open_error) { Errno::ENOENT }

      before do
        allow(operation_group).to receive(:model).and_raise(uri_open_error)
      end

      it 'should not raise an error' do
        expect { perform_import }.to_not raise_error
      end
    end
  end
end
