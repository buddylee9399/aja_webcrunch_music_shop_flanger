# web crunch - music shop
- https://github.com/justalever/flanger/blob/master/Gemfile

- GEMS
```
group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  gem 'better_errors'
  gem 'binding_of_caller', '~> 1.0'
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

gem "image_processing", "~> 1.2"
# gem 'carrierwave'
# gem 'mini_magick'
gem 'bulma-rails'
gem 'simple_form'
gem 'devise'
gem 'gravatar_image_tag'
```
- brew install imagemagick
- I COULDNT INSTALL IMAGEMAGICK ON LAPTOP SO VARIANTS DIDNT WORK
- rails g simple_form:install
- rails g devise:install
- rails g devise:views
- rails g devise User
- rails g migration add_name_to_users name
- rails g scaffold instrument brand model description:text condition finish title price:decimal
- update migration

```
t.decimal :price, precision: 5, scale: 2, default: 0
```
- rails db:migrate
- rails active_storage:install
- rails g migration AddUserIdToInstruments user_id:integer
- rails g scaffold cart
- rails g scaffold LineItem instrument:references cart:belongs_to
- rails g migration AddQuantityToLineItems quantity:integer
- update migration
```
add_column :line_items, :quantity, :integer, default: 1
```

- rails db:migrate
- update routes

```
Rails.application.routes.draw do
  resources :line_items
  resources :carts
  resources :instruments

  root 'instruments#index'

  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end

```

- updated the devise for rails 7 turbo: https://dev.to/efocoder/how-to-use-devise-with-turbo-in-rails-7-9n9
- updated app controller
- copied over images to assets/images
- update app.scss and added functions and instruments.scss
- updated app controller with the cart

```
  before_action :configure_permitted_parameters, if: :devise_controller?
  include CurrentCart
  before_action :set_cart
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end

```

- updated carts controller
- updated instruments controller
- update line items controller
- update app helper

```
module ApplicationHelper
  def cart_count_over_one
    return total_cart_items if total_cart_items > 0
  end

  def total_cart_items
    total = @cart.line_items.map(&:quantity).sum
    return total if total > 0
  end
end

```

- update instruments helper

```
module InstrumentsHelper
  def instrument_author(instrument)
    user_signed_in? && current_user.id == instrument.user_id
  end

end
```

- update cart.rb

```
  has_many :line_items, dependent: :destroy

  def add_instrument(instrument)
    current_item = line_items.find_by(instrument_id: instrument.id)

    if current_item
      current_item.increment(:quantity)
    else
      current_item = line_items.build(instrument_id: instrument.id)
    end
    current_item
  end

  def total_price
    line_items.to_a.sum { |item| item.total_price }
  end

end

```

- update instrument.rb

```
class Instrument < ApplicationRecord
  before_destroy :not_referenced_by_any_line_item
  belongs_to :user, optional: true
  has_many :line_items

  has_one_attached :image
  # mount_uploader :image, ImageUploader
  # serialize :image, JSON # If you use SQLite, add this line

  validates :title, :brand, :price, :model, presence: true
  validates :description, length: { maximum: 1000, too_long: "%{count} characters is the maximum aloud. "}
  validates :title, length: { maximum: 140, too_long: "%{count} characters is the maximum aloud. "}
  validates :price, length: { maximum: 7 }

  BRAND = %w{ Fender Gibson Epiphone ESP Martin Dean Taylor Jackson PRS  Ibanez Charvel Washburn }
  FINISH = %w{ Black White Navy Blue Red Clear Satin Yellow Seafoam }
  CONDITION = %w{ New Excellent Mint Used Fair Poor }

  private

  def not_refereced_by_any_line_item
    unless line_items.empty?
      errors.add(:base, "Line items present")
      throw :abort
    end
  end

end

```

- update line item rb

```
  belongs_to :instrument
  belongs_to :cart

  def total_price
    instrument.price.to_i * quantity.to_i
  end
end

```

- update user.rb

```
 has_many :instruments
end

```

- create models/concerns/current_cart.rb

```
module CurrentCart

  private

  def set_cart
    @cart = Cart.find(session[:cart_id])
  rescue ActiveRecord::RecordNotFound
    @cart = Cart.create
    session[:cart_id] = @cart.id
  end
end
```

- add font awesome via cdn
- update all the views
- ADDING JAVASCRIPT FOR THE IMAGE PREVIEW
- added javascript via cdn
- added the code to app.js
- refresh and test
- THE NEW AND EDIT WORKED
- THERE IS NOT A SAMPLE IMAGE ON THE EDIT PAGE

- TESTING THE CART
- Add to carts worked
- cart appeared on the navbar
- view cart i had to change button_to for the line item remove
- the empty cart worked
- it works when user logged out as well
## THE END