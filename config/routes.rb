JobScheduler::Application.routes.draw do
  root to: 'home#index'
  resources :user_types
  match 'test' => 'home#test', via: [:get]
  match 'my_schedule' => 'home#my_schedule', via: [:get]
  
  match 'reports' => 'reports#index', via: [:get]
  match 'reports/weeks_by_beginning' => 'reports#weeks_by_beginning', via: [:get]
  match 'reports/employees_scheduled_unschedule' => 'reports#employees_scheduled_unschedule', via: [:get]
  match 'reports/scheduled_for_the_week' => 'reports#scheduled_for_the_week', via: [:get]

  match 'schedules/search' => 'schedules#search', :via => [:get, :post]
  match 'schedules/scheduled_for_job' => 'schedules#scheduled_for_job', via: [:get]
  match 'schedules/schedule_conflicts' => 'schedules#schedule_conflicts', via: :all
  
  match 'schedules/grouped_by_job_id' => 'schedules#grouped_by_job_id', via: [:get]
  match 'schedules/create_schedule' => 'schedules#create_schedule', via: [:post]
  match 'schedules/update_schedule' => 'schedules#update_schedule', via: [:post]
  match 'schedules/create_pending_schedule' => 'schedules#create_pending_schedule', via: [:post]
  match 'schedules/update_pending_schedule' => 'schedules#update_pending_schedule', via: [:post]
  match 'schedules/delete_pending_schedule' => 'schedules#delete_pending_schedule', via: [:post]
  match 'schedules/get_available_employees' => 'schedules#get_available_employees', via: [:post]
  resources :schedules do
    get :scheduled_for_job
    get :grouped_by_job_id
    
    member do
      post :archive
    end
    
    collection do
      delete :delete_multiple
    end
  end

  devise_for :users
  
  resources :jobs, except: [:destroy] do
    member do
      post :archive
    end
  end
  
  match 'employees/employee_list' => 'employees#employee_list', via: [:get]
  resources :employees, except: [:destroy] do
    get :schedule
    member do
      post :archive
      post :add_skill
      delete :remove_skill
    end
  end
  
  resources :time_off_requests do
    member do
      post :approve
      post :deny
    end
  end
  
  resources :skills, except: [:destroy] do
    member do
      post :archive
    end
  end
  
  resources :customers, except: [:destroy] do
    resources :point_of_contacts, only: [:new, :edit, :update, :index, :create] do
      member do
        post :archive
      end
    end
    
    member do
      post :archive
    end
  end
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
