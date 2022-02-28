require 'timeout'

class CustomerSuccessBalancing
  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
  end

  # Returns the ID of the customer success with most customers
  def execute
    # Write your solution here
  end

  def revome_unavailable_cs
    @customer_success.select { |cs|
      @away_customer_success.include? cs[:id]
    }
  end
end
