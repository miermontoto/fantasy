module ParallelDataFetcher
  extend ActiveSupport::Concern

  def render_with_parallel_update(options = {})
    collection = options[:collection]
    return unless collection.present?

    respond_to do |format|
      format.html do
        # Apply initial filters without expensive data
        options[:before_filters]&.each { |filter| send(filter) }
      end

      format.turbo_stream do
        # Fetch detailed data in parallel
        require "parallel"
        browsers = Parallel.processor_count.times.map { Browser.new }

        Parallel.each_with_index(collection, in_threads: Parallel.processor_count) do |item, index|
          browser = browsers[index % browsers.size]
          options[:update_method].call(item, browser)
        end

        # Apply filters after data update
        options[:before_filters]&.each { |filter| send(filter) }

        if options[:before_update]
          options[:before_update].call
        end

        # Build turbo stream response
        streams = [
          turbo_stream.update(options[:content_id],
            partial: options[:partial],
            locals: options[:locals]
          ),
          turbo_stream.remove(options[:update_id])
        ]

        # Add any additional updates
        if options[:after_update]
          additional_streams = options[:after_update].call
          streams.concat(additional_streams) if additional_streams.present?
        end

        # Render the turbo stream response
        render turbo_stream: streams
      end
    end
  end
end
