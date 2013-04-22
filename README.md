# Luhn CCValidator #

Ruby module and command line tool to validate credit cards using the Luhn algorithm.

## Usage ##

### As a module ###

```ruby
require 'ccvalidator.rb'
```
    
Firstly need to add companies so that it can check against their requirements:

```ruby
CCValidator::CCCompany.add("MasterCard", 51..55, 16)
CCValidator::CCCompany.add("VISA", 4, [13, 16])
```

Arguments required are their name, the number that their card numbers start with, and the number of digits their card numbers must have.  The last two arguments can be a single integers or an array of integers.
    
To perform a validation once the companies are added you can call:

```ruby
CCValidator.validate(numbers_to_validate)
```

with a single string number or a string with multiple numbers separated by newlines.

It will return a string in the form:

```ruby
MasterCard: 5105105105105100 (valid)
VISA: 4111111111111          (invalid)
```

You can also validate individual numbers with the CCNumber class:

```ruby
ccnumber = CCValidator::CCNumber.new("5105105105105100")
puts ccnumber.company  # -> "MasterCard"
puts ccnumber.valid  # -> true
puts ccnumber.to_s  # -> "MasterCard: 5105105105105100 (valid)"
```

### And on the command line. ###

```bash
$ ./ccvalidator.rb 5105105105105100  # -> "MasterCard: 5105105105105100 (valid)"
```

Again, you can give it multiple numbers separated by newlines.
    
You can also give it a text file of numbers separated by newlines:

```bash
$ ./ccvalidator.rb path/to/file.txt
```
    
The command line uses a default set of companies:

| Company    | Starts With | Length of Card Number |
| ---------- | ----------- | --------------------- |
| AMEX       | 34 or 37    | 15                    |
| Discover   | 6011        | 16                    |
| MasterCard | 51-55       | 16                    |
| VISA       | 4           | 13 or 16              |

### Testing ###

A basic test of the module can be performed by passing *test* as an argument:

```bash
$ ./ccvalidator.rb test
```
