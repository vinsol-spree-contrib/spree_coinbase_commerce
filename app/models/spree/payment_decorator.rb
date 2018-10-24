Spree::Payment.class_eval do
  after_create :register_coinbase_charge, if: :coinbase?

  scope :coinbase, -> { joins(:payment_method).where(spree_payment_methods: {type: 'Spree::PaymentMethod::Coinbase'}) }

  def coinbase?
    payment_method.is_a?(Spree::PaymentMethod::Coinbase)
  end

  def charge_url
    "https://commerce.coinbase.com/charges/#{response_code}" if coinbase? && response_code.present?
  end

  private
    def register_coinbase_charge
      charge_params = {name: order.number, description: order.line_items.map(&:name).to_sentence, local_price: {amount: amount.to_s, currency: currency.to_s}, pricing_type: 'fixed_price', metadata: {number: number}, redirect_url: "#{Rails.application.config.action_mailer.default_url_options[:host]}/coinbase/redirect"}
      coinbase_charge = payment_method.provider.charges.create(charge_params)
      update_column(:response_code, coinbase_charge.code)
    end
end
