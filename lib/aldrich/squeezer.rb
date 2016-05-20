# Internal: This class is responsible for removing trailing, blank rows
# from sanitized CSV data
module Aldrich
  class Squeezer
    attr_reader :csv_file, :original_contents

    # Public: Remove trailing blank rows from a set of CSV data
    #
    # csv_file - A File object containins csv data
    #
    # Returns a TempFile object with the contents stripped of trailing
    # blank rows
    def self.compress!(csv_file)
      new(csv_file).compress!
    end

    def initialize(csv_file)
      @csv_file          = csv_file
      @original_contents = CSV.readlines(csv_file)
    end

    def compress!
      csv_file.tap do |file|
        file.truncate(0)
        file.write(compressed_contents)
        file.rewind
      end
    end

    def compressed_contents
      CSV.generate do |csv|
        cleaned_csv_table.each { |row| csv << row }
      end
    end

    private

    def cleaned_csv_table
      original_contents.reject do |row|
        row.all? { |column| column.nil? || column.strip.empty? }
      end
    end
  end
end
