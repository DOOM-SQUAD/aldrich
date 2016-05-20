require 'spec_helper'

describe Aldrich::Sanitizer do
  let(:import_name) { "Some Import" }

  let(:bad_unicode_path) {
    File.join(SPEC_ROOT, 'data', 'bad_unicode_characters.txt')
  }

  let(:bad_unicode) { File.read(bad_unicode_path).chomp }

  let(:bad_string)  {
    "SKU,Desc\n"  +
    "1234,Bewt\n" +
    "5678,#{bad_unicode}"
  }

  let(:good_string) {
    "SKU,Desc\n"  +
    "1234,Bewt\n" +
    "5678,"
  }

  let(:sanitizer) { Aldrich::Sanitizer.new(import_name, spreadsheet) }

  let(:sanitized_file) { sanitizer.sanitized_file }
  let(:sanitized_text) { sanitizer.sanitized_contents }

  let(:file_name) { Pathname.new(sanitized_file.path).basename.to_s }

  describe "file naming" do
    let(:spreadsheet) { StringIO.new(good_string) }

    it "produces a file with the import name included" do
      expect(file_name).to start_with('some_import')
    end

    it "produces a file with the correct extension" do
      expect(file_name).to end_with('.csv')
    end
  end

  describe ".valid_utf8" do
    context "with a valid spreadsheet" do
      let(:spreadsheet)  { StringIO.new(good_string) }

      it "outputs a tempfile with the input contents" do
        expect(sanitized_text). to eq(good_string)
      end
    end

    context "with a bad spreadsheet" do
      let(:spreadsheet)  { StringIO.new(bad_string) }

      it "outputs a tempfile with sanitized input" do
        expect(sanitized_text). to eq(good_string)
      end
    end
  end

  describe 'vendor name handling' do
    context 'import name contains a forward slash' do
      let(:import_name) { "Some Import 24/7" }
      let(:spreadsheet) { StringIO.new(good_string) }

      it 'should return the expected filename, stripped of the slash' do
        expect(file_name).to start_with('some_import_24_7')
      end
    end
  end
end
