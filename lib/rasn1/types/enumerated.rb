module RASN1
  module Types

    # ASN.1 Enumerated
    #
    # An enumerated type permits to assign names to integer values. It may be defined
    # different ways:
    #  enum = RASN1::Types::Enumerated.new(enum: { 'a' => 0, 'b' => 1, 'c' => 2 })
    #  enum = RASN1::Types::Enumerated.new(enum: { a: 0, b: 1, c: 2 })
    # Its value should be setting as an Integer or a String/symbol:
    #  enum.value = :b
    #  enum.value = 1   # equivalent to :b
    # But its value is always stored as named integer:
    #  enum.value = :b
    #  enum.value      # => :b
    #  enum.value = 0
    #  enum.value      # => :a
    # A {EnumeratedError} is raised when set value is not in enumeration.
    # @author Sylvain Daubert
    class Enumerated < Integer
      # @!attribute enum
      # @return [Hash]

      TAG = 0x0a

      # @overload initialize(options={})
      #   @option options [Hash] :enum enumeration hash. Keys are names, and values
      #     are integers. This key is mandatory.
      #   @raise [EnumeratedError] +:enum+ key is not present
      #   @raise [EnumeratedError] +:default+ value is unknown
      # @overload initialize(value, options={})
      #   @param [Object] value value to set for this ASN.1 object
      #   @option options [Hash] :enum enumeration hash. Keys are names, and values
      #     are integers. This key is mandatory.
      #   @raise [EnumeratedError] +:enum+ key is not present
      #   @raise [EnumeratedError] +:default+ value is unknown
      # @see Base#initialize common options to all ASN.1 types
      def initialize(value_or_options={}, options={})
        super
        raise EnumeratedError, 'no enumeration given' if @enum.nil?
      end

      # @return [Hash]
      def to_h
        @enum
      end
    end
  end
end
