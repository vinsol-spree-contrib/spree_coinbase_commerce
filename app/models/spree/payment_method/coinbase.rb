module Spree
  class PaymentMethod::Coinbase < PaymentMethod
    preference :api_key, :string
    preference :shared_secret, :string
    preference :redirect_host, :string

    def actions
      %w{capture}
    end

    def can_capture?(payment)
      ['checkout', 'failed', 'invalid'].include?(payment.state)
    end

    def auto_capture?
      false
    end

    def provider
      @provider ||= CoinbaseCommerce::API.new(preferred_api_key)
    end

    def verify(request)
      CoinbaseCommerce::Webhook.shared_secret = preferred_shared_secret
      CoinbaseCommerce::Webhook.verify(request)
    end

    def source_required?
      false
    end

    def capture(amount, response_code, options)
      return simulated_error_response('Response code not present') if response_code.blank?
      coinbase_charge = begin
        provider.charges.find(response_code)
      rescue StandardError => e
        return simulated_error_response(e.message)
      end

      if coinbase_charge.timeline.any? { |event| event.status == 'COMPLETED' }
        simulated_successful_billing_response
      else
        simulated_error_response('Charge not COMPLETED')
      end
    end

    private

    def simulated_successful_billing_response
      ActiveMerchant::Billing::Response.new(true, '', {}, {})
    end

    def simulated_error_response(error_message='')
      ActiveMerchant::Billing::Response.new(false, error_message, {}, {})
    end

  end
end
