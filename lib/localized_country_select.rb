# = LocalizedCountrySelect
# 
# View helper for displaying select list with countries:
# 
#     localized_country_code_select(:user, :country)
# 
# Works just like the default Rails' +country_select+ plugin, but stores countries as
# country *codes*, not *names*, in the database.
# 
# You can easily translate country codes in your application like this:
#     <%= I18n.t @user.country, :scope => 'countries' %>
# 
# Uses the Rails internationalization framework (I18n) for translating the names of countries.
# 
# Use Rake task <tt>rake import:country_select 'de'</tt> for importing country names
# from Unicode.org's CLDR repository (http://www.unicode.org/cldr/data/charts/summary/root.html)
# 
# Code adapted from Rails' default +country_select+ plugin (previously in core)
# See http://github.com/rails/country_select/tree/master/lib/country_select.rb
#
# TODO : Test coverage
# TODO : Solve priority countries

module LocalizedCountrySelect
  class << self
    # Returns array with codes and localized country names (according to <tt>I18n.locale</tt>)
    # for <tt><option></tt> tags
    def localized_countries_array
      I18n.translate(:countries).map { |key, value| [value, key.to_s.upcase] }.sort
    end
  end
end

module ActionView
  module Helpers

    module FormOptionsHelper

      # Return select and option tags for the given object and method, using +localized_country_options_for_select+ 
      # to generate the list of option tags. Uses <b>country code</b>, not name as option +value+.
      def localized_country_select(object, method, priority_countries = nil, options = {}, html_options = {})
        InstanceTag.new(object, method, self, options.delete(:object)).
          to_localized_country_select_tag(priority_countries, options, html_options)
      end

      # Returns a string of option tags for countries according to locale. Supply the country code in upper-case ('US', 'DE') 
      # as +selected+ to have it marked as the selected option tag.
      # TODO : You can also supply an array of countries as +priority_countries+, so that they will be listed first.
      def localized_country_options_for_select(selected = nil, priority_countries = nil)
        country_options = ""
        if priority_countries
          country_options += options_for_select(priority_countries, selected)
          country_options += "<option value=\"\" disabled=\"disabled\">-------------</option>\n"
        end
        return country_options + options_for_select(LocalizedCountrySelect::localized_countries_array, selected)
      end
      
    end

    class InstanceTag
      def to_localized_country_select_tag(priority_countries, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        content_tag("select",
          add_options(
            localized_country_options_for_select(value, priority_countries),
            options, value
          ), html_options
        )
      end
    end
    
    class FormBuilder
      def localized_country_select(method, priority_countries = nil, options = {}, html_options = {})
        @template.localized_country_select(@object_name, method, priority_countries, options.merge(:object => @object), html_options)
      end
    end

  end
end