# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, key: '_myappda_session', domain: {
    production:   '.myappda.ru',
    staging:      '.myappda.ru',
    development:  '.lvh.me'
    # development:  '.k-comment.ru'
}.fetch(Rails.env.to_sym, :all)
