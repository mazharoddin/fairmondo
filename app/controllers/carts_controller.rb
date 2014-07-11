class CartsController < ApplicationController
  respond_to :html

  before_filter :generate_session, only: :edit
  before_filter :set_cart

  before_filter :authorize_and_authenticate_user_on_cart, only: :show
  skip_before_filter :authenticate_user!, only: :show

  def show
    respond_with @cart
  end

  def edit
    authorize @cart
    @cart_checkout_form = CartCheckoutForm.new(session, @cart, params[:checkout]) #try the old session data
    if @cart_checkout_form.session_valid? && params[:checkout]
      render :overview
    else
      render :edit
    end
  end


  # buy cart
  def update
    authorize @cart
    @cart_checkout_form = CartCheckoutForm.new(session, @cart, params[:checkout])
    result = @cart_checkout_form.process(params[:cart_checkout_form])

    case result
    when :invalid
      render :edit
    when :saved_in_session
      redirect_to edit_cart_path(@cart, checkout: true)
    when :checked_out
      clear_session
      respond_with @cart
    when :checkout_failed
      # failed because something isnt available anymore
      respond_with @cart
    end
  end

  private

    def generate_session
      session[:cart_checkout] ||= {}
    end

    def clear_session
      session[:cart_checkout] = nil
    end

    def set_cart
      @cart = Cart.includes( line_item_groups: [ :seller, { line_items:  [:article] }]).find params[:id]
    end

    def authorize_and_authenticate_user_on_cart
      if @cart.buyer_id # cart belongs to user
        authenticate_user! # and can only be accessed by a logged in user
      else # otherwise
        @cart.cookie_content = cookies.signed[:cart] # we need the cookie content to authorize the cart
      end

      authorize @cart
    end

end
