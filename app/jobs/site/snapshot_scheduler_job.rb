class Site::SnapshotSchedulerJob < ApplicationJob
  queue_as :default

  def perform(site)
    @site = site.reload
    return unless @site
    monitor
  rescue => e
    Rails.logger.error e.message
    raise
  end

  private
  def monitor
    if @site.active?
      if within_monitoring_hours?
        take_snapshot
        schedule_next_snapshot
      else
        schedule_next_snapshot_window
      end
    else
      Rails.logger.info "Site #{@site.id} inactive, stopping monitoring"
    end
  end

  def take_snapshot
    Site::SnapshotJob.perform_later(@site)
  end

  def schedule_next_snapshot
    Site::SnapshotSchedulerJob.set(wait: @site.frequency_seconds.seconds).perform_later(@site)
  end

  def schedule_next_snapshot_window
    Site::SnapshotSchedulerJob.set(wait: next_monitoring_start_time).perform_later(@site)
  end

  def current_time_in_site_timezone
    Time.current + @site.timezone_offset_hours.hours
  end

  def next_monitoring_start_time
    current_site_time = current_time_in_site_timezone

    monitoring_start = @site.monitor_start_time
    today_start_time = current_time_in_site_timezone.beginning_of_day +
                       monitoring_start.hour.hours +
                       monitoring_start.min.minutes +
                       monitoring_start.sec.seconds
    if current_site_time < today_start_time
      today_start_time - current_site_time
    else
      tomorrow_start_time = today_start_time + 1.day
      tomorrow_start_time - current_site_time
    end
  end

  def within_monitoring_hours?
    return true unless @site.monitor_start_time && @site.monitor_end_time

    site_time = current_time_in_site_timezone
    current_time_of_day = site_time.strftime("%H:%M:%S")

    start_time = @site.monitor_start_time.strftime("%H:%M:%S")
    end_time = @site.monitor_end_time.strftime("%H:%M:%S")

    if start_time <= end_time
      current_time_of_day >= start_time && current_time_of_day <= end_time
    else
      current_time_of_day >= start_time || current_time_of_day <= end_time
    end
  end
end
