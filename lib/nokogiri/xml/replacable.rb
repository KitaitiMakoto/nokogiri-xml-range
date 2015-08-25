using Nokogiri::XML::Range::Extension

module Nokogiri::XML
  module Replacable
    def replace_data(offset, count, data)
      len = length
      raise IndexSizeError, 'offset is greater than node length' if offset > len

      count = len - offset if offset + count > len
      encoding = content.encoding
      utf16_content = content.encode('UTF-16LE')
      utf16_data = data.encode('UTF-16LE')
      result = utf16_content.byteslice(0, offset * 2) + utf16_data + utf16_content.byteslice(offset * 2, utf16_content.bytesize)
      delete_offset = offset + utf16_data.bytesize / 2
      result = result.byteslice(0, delete_offset * 2) + result.byteslice((delete_offset + count) * 2, result.bytesize)

      self.content = result.encode(encoding)
    end

    def substring_data(offset, count)
      len = length
      raise IndexSizeError, 'offset is greater than node length' if offset > len

      encoding = content.encoding
      utf16_content = content.encode('UTF-16LE')

      end_offset = offset + count > len ? utf16_content.bytesize
                                        : (offset + count) * 2
      utf16_content.byteslice(offset * 2, end_offset).encode(encoding)
    end
  end

  class CharacterData
    include Replacable
  end

  class ProcessingInstruction
    include Replacable
  end
end
