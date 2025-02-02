module RASN1
  module Types

    # ASN.1 Visible String
    # @author Sylvain Daubert
    class VisibleString < IA5String
      TAG = 26

      # Get ASN.1 type
      # @return [String]
      def self.type
        'VisibleString'
      end

    end
  end
end
