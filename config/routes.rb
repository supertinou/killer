Rails.application.routes.draw do

	root to: 'pages#home'
	get '/sign_up', to: 'oauth2#authorize_app'
	get '/sign_in', to: 'oauth2#authorize_app'

	put 'kill/:login', to: 'killer#kill', as: :kill

	put 'confirm_my_death', to: 'killer#confirm_my_death', as: :confirm_my_death
	put 'deny_my_death', to: 'killer#deny_my_death', as: :deny_my_death

	get 'oauth2/authorize_app', to: 'oauth2#authorize_app'
	get 'oauth2/callback', to: 'oauth2#callback'
	get 'oauth2/sign_out', to: 'oauth2#sign_out'

	scope "/admin", module: "admin" do
		resources :participants, except: [:destroy, :new, :create] do 
			collection do 
				get 'killed'
				get 'alive'
				get 'loop'
				get 'stats'
				get 'start'
				get 'refresh_participants_infos'
			end
			member do 
				get 'targets'
			end
		end
		get '/', to: 'participants#index'
	end

	if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

end
