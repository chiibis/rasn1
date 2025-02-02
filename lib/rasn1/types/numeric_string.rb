module RASN1
  module Types

    # ASN.1 Numeric String
    # @author Sylvain Daubert
    class NumericString < OctetString
      TAG = 18

      # Get ASN.1 type
      # @return [String]
      def self.type
        'NumericString'
      end

      private
      
      def value_to_der
        check_characters
        @value.to_s.force_encoding('BINARY')
      end

      def der_to_value(der, ber:false)
        super
        check_characters
      end

      def check_characters
        if @value.to_s =~ /([^0-9 ])/
          raise ASN1Error, "NUMERIC STRING #@name: invalid character: '#{$1}'"
        end
      end
    end
  end
end
