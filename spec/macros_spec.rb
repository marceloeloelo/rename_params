describe RenameParams::Macros, type: :controller do
  describe '.rename' do

    context 'when not filtering' do
      let(:default_params) { { controller: 'anonymous', action: 'index' } }
      before { routes.draw { get index: 'anonymous#index' } }

      context 'when just renaming params' do
        controller(ActionController::Base) do
          rename :username, to: :login

          def index
            head :ok
          end
        end

        it 'renames username to login' do
          get :index, params: { username: 'aperson' }
          expected = default_params.merge(login: 'aperson')
          expect(controller.params).to eq ActionController::Parameters.new(expected)
        end

        context 'if param is not sent' do
          it 'leaves params as they were' do
            get :index
            expect(controller.params).to eq ActionController::Parameters.new(default_params)
          end
        end
      end

      context 'when converting values' do
        context 'and using enum converter' do
          controller(ActionController::Base) do
            rename :admin, to: :role, convert: { true: ['admin'], false: [] }

            def index
              head :ok
            end
          end

          it 'renames admin to role and converts value' do
            get :index, params: { admin: 'true' }
            expected = default_params.merge(role: ['admin'])
            expect(controller.params).to eq ActionController::Parameters.new(expected)
          end

          context 'if param is not sent' do
            it 'leaves params as they were' do
              get :index
              expect(controller.params).to eq ActionController::Parameters.new(default_params)
            end
          end
        end

        context 'and using a Proc converter' do
          controller(ActionController::Base) do
            rename :amount_due, to: :amount_due_in_cents, convert: ->(value) { value.to_i * 100 }

            def index
              head :ok
            end
          end

          it 'renames amount_due to amount_due_in_cents and converts value' do
            get :index, params: { amount_due: 100 }
            expected = default_params.merge(amount_due_in_cents: 10000)
            expect(controller.params).to eq ActionController::Parameters.new(expected)
          end

          context 'if param is not sent' do
            it 'leaves params as they were' do
              get :index
              expect(controller.params).to eq ActionController::Parameters.new(default_params)
            end
          end
        end
      end
    end

    context 'when filtering' do
      context 'using only' do
        controller(ActionController::Base) do
          rename :username, to: :login, only: :show

          def index
            head :ok
          end

          def show
            head :ok
          end
        end

        describe 'show' do
          before { routes.draw { get 'show' => 'anonymous#show' } }

          it 'renames username to login' do
            get :show, params: { username: 'aperson' }
            expected = { controller: 'anonymous', action: 'show', login: 'aperson' }
            expect(controller.params).to eq ActionController::Parameters.new(expected)
          end
        end

        describe 'index' do
          before { routes.draw { get 'index' => 'anonymous#index' } }

          it 'keeps username param' do
            get :index, params: { username: 'aperson' }
            expected = { controller: 'anonymous', action: 'index', username: 'aperson' }
            expect(controller.params).to eq ActionController::Parameters.new(expected)
          end
        end
      end

      context 'using except' do
        controller(ActionController::Base) do
          rename :username, to: :login, except: :show

          def index
            head :ok
          end

          def show
            head :ok
          end
        end

        describe 'show' do
          before { routes.draw { get 'show' => 'anonymous#show' } }

          it 'keeps username param' do
            get :show, params: { username: 'aperson' }
            expected = { controller: 'anonymous', action: 'show', username: 'aperson' }
            expect(controller.params).to eq ActionController::Parameters.new(expected)
          end
        end

        describe 'index' do
          before { routes.draw { get 'index' => 'anonymous#index' } }

          it 'renames username to login' do
            get :index, params: { username: 'aperson' }
            expected = { controller: 'anonymous', action: 'index', login: 'aperson' }
            expect(controller.params).to eq ActionController::Parameters.new(expected)
          end
        end
      end
    end
  end
end