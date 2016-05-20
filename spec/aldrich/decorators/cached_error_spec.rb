require 'spec_helper'

describe Aldrich::Decorators::CachedError do
  let(:handle)  { 'some-import' }
  let(:group)   { 'ZOGM' }
  let(:field)   { 'name' }
  let(:message) { 'It sounds stupid' }

  let(:expected_context) { { field => message } }

  let(:error) { Aldrich::Decorators::CachedError.new(handle, group, field, message) }

  it 'sets the correct handle' do
    expect(error.handle).to eq(handle)
  end

  it 'sets the correct context' do
    expect(error.context).to eq(expected_context)
  end

  it 'sets the correct group' do
    expect(error.group).to eq(group)
  end
end
