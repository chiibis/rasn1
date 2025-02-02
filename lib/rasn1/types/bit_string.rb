module RASN1
  module Types

    # ASN.1 Bit String
    # @author Sylvain Daubert
    class BitString < Primitive
      TAG = 0x03

      # @param [Integer] bit_length
      # @return [Integer]
      attr_writer :bit_length

      # @overload initialize(options={})
      #   @param [Hash] options
      #   @option options [Object] :bit_length default bit_length value. Should be
      #     present if +:default+ is set
      # @overload initialize(value, options={})
      #   @param [Object] value value to set for this ASN.1 object
      #   @param [Hash] options
      #   @option options [Object] :bit_length default bit_length value. Should be
      #     present if +:default+ is set
      # @see Base#initialize common options to all ASN.1 types
      def initialize(value_or_options={}, options={})
        super
        opts = value_or_options.is_a?(Hash) ? value_or_options : options
        if @default
          if opts[:bit_length].nil?
            raise ASN1Error, "TAG #@name: default bit length is not defined"
          end
          @default_bit_length = opts[:bit_length]
        end
        @bit_length = opts[:bit_length]
      end

      # Get bit length
      def bit_length
        if @value.nil?
          @default_bit_length
        else
          @bit_length
        end
      end

      # @param [Integer] level
      # @return [String]
      def inspect(level=0)
        str = ''
        str << '  ' * level if level > 0
        str << "#{name} " unless @name.nil?
        str << "#{type}: #{value.inspect} (bit length: #{bit_length})"
      end

      private

      def build_tag?
        !(!@default.nil? and (@value.nil? or @value == @default and
                              @bit_length == @default_bit_length)) and
          !(optional? and @value.nil?)
      end

      def value_to_der
        raise ASN1Error, "TAG #@name: bit length is not set" if bit_length.nil?

        while @value.length * 8 < @bit_length
          @value << "\x00"
        end
        @value.force_encoding('BINARY')

        if @value.length * 8 > @bit_length
          max_len = @bit_length / 8 + (@bit_length % 8 > 0 ? 1 : 0)
          @value = @value[0, max_len]
        end

        unused = @value.length * 8 - @bit_length
        der = [unused, @value].pack('CA*')

        if unused > 0
          last_byte = @value[-1].unpack('C').first
          last_byte &= (0xff >> unused) << unused
          der[-1] = [last_byte].pack('C')
        end

        der
      end

      def der_to_value(der, ber:false)
        unused, @value = der.unpack('CA*')
        @bit_length = @value.length * 8 - unused
      end
    end
  end
end
