Spree::CheckoutController.class_eval do
  # before_action :coinbase_redirect, :only => [:update]

  # Updates the order and advances to the next state (when possible.)
  def update
    if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
      @order.temporary_address = !params[:save_user_address]

      if (params[:state] == "payment") && (coinbase_payment = @order.payments.checkout.coinbase.first) && coinbase_payment.charge_url.present?
        redirect_to(URI.encode(coinbase_payment.charge_url)) && return
      end

      unless @order.next
        flash[:error] = @order.errors.full_messages.join("\n")
        redirect_to(checkout_state_path(@order.state)) && return
      end

      if @order.completed?
        @current_order = nil
        flash.notice = Spree.t(:order_processed_successfully)
        flash['order_completed'] = true
        redirect_to completion_route
      else
        redirect_to checkout_state_path(@order.state)
      end
    else
      render :edit
    end
  end

end
