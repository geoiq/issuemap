require 'spreadsheet'
require 'roo/generic_spreadsheet'
require 'roo/excel'
require 'roo/excelx'
require 'tempfile'

# This class is a universal interface to uploaded spreadsheet files. All it really
# does is determine (best guess) the file type, and produce a CSV representation
# of that file. Fairly straightforward.

class SpreadsheetReader
  class << self
    def read(upload)
      case upload.content_type
      when 'text/csv'
        File.read(upload.instance.previous_upload)
      else
        tmpfile = Tempfile.new(File.basename(upload.instance.previous_upload))
        case File.extname(upload.instance.upload_file_name)
        when '.xls'
          Excel.new(upload.instance.previous_upload).to_csv(tmpfile.path)
        when '.xlsx'
          Excelx.new(upload.instance.previous_upload).to_csv(tmpfile.path)
        else
          spreadsheet = Spreadsheet.open(upload.instance.previous_upload)
          raise spreadsheet.worksheets.first.inspect
        end
        File.read(tmpfile.path)
      end
    end
  end
end
