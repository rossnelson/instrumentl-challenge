module Resources
  # PageService will format the page for the content response.

  class PageService
    def call(content:, json_options: {})
      {
        content: content.as_json(json_options),
        total_pages: content.total_pages,
        current_page: content.current_page,
        next_page: content.next_page,
        prev_page: content.prev_page,
        first_page: content.first_page?,
        last_page: content.last_page?,
        out_of_range: content.out_of_range?
      }
    end
  end
end
