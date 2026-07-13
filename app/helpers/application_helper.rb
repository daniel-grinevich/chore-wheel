module ApplicationHelper
  # "1h 05m" / "12m 30s" / "0m 45s"
  def format_seconds(total)
    total = total.to_i
    hours = total / 3600
    minutes = (total % 3600) / 60
    seconds = total % 60

    if hours.positive?
      format("%dh %02dm", hours, minutes)
    else
      format("%dm %02ds", minutes, seconds)
    end
  end
end
