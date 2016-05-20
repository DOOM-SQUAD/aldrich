require 'spec_helper'

describe Aldrich::Squeezer do
  let(:csv_string) do
    "Group Code,sku,price,quantity,description,,,\n" +
    "ZOGM,,17.95,6,\"Some measurement 3\"\" words\",,,\n" +
    "WTF,WTF-BBQ,1637,3,\"Some measurement 3\"\" words\",,, \n" +
    ",,,,,,\n" +
    ",,,,,,\n" +
    ",,, ,,,\n"
  end

  let(:csv_file) do
    Tempfile.new(['bad_csv', '.csv']).tap do |file|
      file.write(csv_string)
      file.rewind
    end
  end

  let(:squeezed_file) { Aldrich::Squeezer.compress!(csv_file) }
  let(:result_string) { squeezed_file.read }

  let(:expected_string) do
    "Group Code,sku,price,quantity,description,,,\n" +
    "ZOGM,,17.95,6,\"Some measurement 3\"\" words\",,,\n" +
    "WTF,WTF-BBQ,1637,3,\"Some measurement 3\"\" words\",,, \n"
  end

  it 'should procude a file containing the expected string contents' do
    expect(result_string).to eq(expected_string)
  end

  it 'produces a file with valid quoting' do
    expect { CSV.parse(squeezed_file) }.to_not raise_error
  end
end
