class AddFullTextSearchToLocations < ActiveRecord::Migration[7.2]
  def change
    # Ensure the necessary extensions are enabled
    enable_extension("pg_trgm") unless extension_enabled?("pg_trgm")
    enable_extension("fuzzystrmatch") unless extension_enabled?("fuzzystrmatch")

    # Add a `tsvector` column that auto-generates based on address fields
    add_column(
      :locations,
      :search_vector,
      :tsvector,
      as: "to_tsvector('english', coalesce(name, '') || ' ' || coalesce(street, '') || ' ' || coalesce(city, '') || ' ' || coalesce(state, '') || ' ' || coalesce(postal_code, ''))",
      stored: true
    )

    # Create a GIN index to optimize text search
    add_index(:locations, :search_vector, using: :gin)
  end
end
