require 'builder'

module RailsAdmin
  module Config
    module Fields
      module Types
        class State < RailsAdmin::Config::Fields::Base
          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types::register(self)
          include RailsAdmin::Engine.routes.url_helpers

          register_instance_option :pretty_value do
            @state_machine_options = ::RailsAdminAasm::Configuration.new @abstract_model
            v = bindings[:view]

            state = bindings[:object].send(name)
            state_class = @state_machine_options.state(state)
            ret = [
              '<div class="label ' + state_class + '">' + bindings[:object].aasm.human_state + '</div>',
              '<div style="height: 10px;"></div>'
            ]

            bindings[:object].aasm.events.each do |event|
              next unless event.may_fire? bindings[:object]
              unless bindings[:controller].try(:authorization_adapter).nil?
                adapter = bindings[:controller].authorization_adapter
                next unless (adapter.authorized?(:state, @abstract_model, bindings[:object]) && (adapter.authorized?(:all_events, @abstract_model, bindings[:object]) || adapter.authorized?(event, @abstract_model, bindings[:object])))
              end
              event_class = @state_machine_options.event(event.name)
              ret << bindings[:view].link_to(
                event.name.to_s.capitalize,
                state_path(model_name: @abstract_model, id: bindings[:object].id, event: event.name, attr: name),
                method: :post,
                class: "btn btn-mini btn-xs #{event_class}",
                style: 'margin-bottom: 5px;'
              )
            end
            ('<div style="white-space: normal;">' + ret.join(' ') + '</div>').html_safe
          end

          register_instance_option :formatted_value do
            form_value
          end

          register_instance_option :form_value do
            @state_machine_options = ::RailsAdminAasm::Configuration.new @abstract_model
            c = bindings[:controller]
            v = bindings[:view]

            state = bindings[:object].send(name)
            state_class = @state_machine_options.state(state)
            ret = [
              '<div class="label ' + state_class + '">' + bindings[:object].aasm.human_state + '</div>',
              '<div style="height: 10px;"></div>'
            ]

            empty = true
            bindings[:object].aasm.events.each do |event|
              next unless event.may_fire? bindings[:object]
              unless bindings[:controller].try(:authorization_adapter).nil?
                adapter = bindings[:controller].authorization_adapter
                next unless (adapter.authorized?(:state, @abstract_model, bindings[:object]) && (adapter.authorized?(:all_events, @abstract_model, bindings[:object]) || adapter.authorized?(event, @abstract_model, bindings[:object])))
              end
              empty = false
              event_class = @state_machine_options.event(event.name)
              ret << bindings[:view].link_to(
                event.name.to_s.capitalize,
                '#',
                'data-attr' => name,
                'data-event' => event.name,
                class: "state-btn btn btn-mini btn-xs #{event_class}",
                style: 'margin-bottom: 5px;'
              )
            end
            unless empty
              ret << bindings[:view].link_to(
                I18n.t('admin.state_machine.no_event'),
                '#',
                'data-attr' => name,
                'data-event' => '',
                class: "state-btn btn btn-default btn-mini btn-xs active",
                style: 'margin-bottom: 5px;'
              )
            end
            ('<div style="white-space: normal;">' + ret.join(' ') + '</div>').html_safe
          end

          register_instance_option :export_value do
            state = bindings[:object].send(name)
            bindings[:object].aasm.human_state
          end

          register_instance_option :partial do
            :form_state
          end

          register_instance_option :allowed_methods do
            [method_name, (method_name.to_s + '_event').to_sym]
          end

          register_instance_option :multiple? do
            false
          end
        end
      end
    end
  end
end
