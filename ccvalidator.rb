#! /usr/bin/env ruby

module CCValidator
  
  class CCCompany
    @@all = []
  
    def initialize(name, starting_numbers, lengths)
      @name = name
      @starting_numbers = [*starting_numbers]
      @lengths = [*lengths]
    end
    
    def matches?(number)
      # Check if number is a number
      return false unless number.to_i.to_s == number
      # Check number length matches any of the company lengths
      return false unless @lengths.any? do |length|
        length == number.length
      end
      # Finally, check the starting numbers
      return number.start_with?(*@starting_numbers.map(&:to_s))
    end
    
    def to_s
       return @name
    end
    
    def self.add(name, starting_numbers, lengths)
      @@all << CCCompany.new(name, starting_numbers, lengths)
    end
    
    def self.all
      @@all
    end
    
  end
  
  class CCNumber
    attr_reader :number, :company, :valid
    
    def initialize(number)
      @number = number.strip.delete(' ')
      @company = get_company
      @valid = validate
    end
    
    def to_s
      company_number_str = "#{@company}: #{@number}".ljust(28)
      valid_str = if @valid then " (valid)" else " (invalid)" end
      return company_number_str + valid_str
    end
    
    private
      
      def validate
        return false if @company == "Unknown"
        return is_number_valid?
      end
      
      def get_company
        CCCompany.all.each do |company|
          return company if company.matches?(@number)
        end
        return "Unknown"
      end
      
      def is_number_valid?
        # Convert to integers
        digits = @number.split('').map(&:to_i)
        # Do the doubling required. Even number length means even digits should be doubled, odd length means odd digits
        if digits.length.even?
          digits = digits.each_with_index.map do |digit, index|
            if index.even? then update_digit(digit) else digit end
          end
        else
          digits = digits.each_with_index.map do |digit, index|
            if index.odd? then update_digit(digit) else digit end
          end
        end
        # Add numbers together and return boolean result of mod10
        return digits.reduce(:+) % 10 == 0
      end
      
      def update_digit(digit)
        digit = digit * 2
        digit = digit - 9 if digit >= 10  # This is the equivalent of adding the two digits
        return digit
      end
      
  end
  
  def CCValidator.validate(numbers)
    output = numbers.split("\n").map do |number|
      ccnumber = CCNumber.new(number)
      next ccnumber.to_s
    end
    return output.join("\n")
  end
  
end


if __FILE__ == $0
  
  CCValidator::CCCompany.add("AMEX", [34, 37], 15)
  CCValidator::CCCompany.add("Discover", 6011, 16)
  CCValidator::CCCompany.add("MasterCard", 51..55, 16)
  CCValidator::CCCompany.add("VISA", 4, [13, 16])
  
  # Basic Test
  if ARGV[0] == "test"
    
    test_numbers = "4111111111111111
                    4111111111111
                    4012888888881881
                    378282246310005
                    6011111111111117
                    5105105105105100
                    5105 1051 0510 5106
                    9111111111111111"
    
    expected_output = "VISA: 4111111111111111       (valid)\n"   +
                      "VISA: 4111111111111          (invalid)\n" +
                      "VISA: 4012888888881881       (valid)\n"   +
                      "AMEX: 378282246310005        (valid)\n"   +
                      "Discover: 6011111111111117   (valid)\n"   +
                      "MasterCard: 5105105105105100 (valid)\n"   +
                      "MasterCard: 5105105105105106 (invalid)\n" +
                      "Unknown: 9111111111111111    (invalid)"
    
    output = CCValidator.validate(test_numbers)
    
    if output == expected_output
      puts "\nTEST PASSED!\n\n"
    else
      puts "\nTEST FAILED:\n\n"
      puts "Expected:\n#{expected_output}\n\n"
      puts "Got:\n#{output}\n\n"
    end
    
  
  # Command Line Usage
  elsif ARGV[0]
    
    if File.exists?(ARGV[0])
      puts CCValidator.validate(IO.read(ARGV[0]))
    else
      puts CCValidator.validate(ARGV[0])
    end
    
  end
  
end