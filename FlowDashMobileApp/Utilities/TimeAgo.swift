import Foundation

func timeAgoString(from dateString: String?) -> String {
    guard let dateString else { return "—" }
    let date = ISO8601DateFormatter().date(from: dateString)
        ?? DateFormatter.n8nFormatter.date(from: dateString)
    guard let date else { return "—" }
    let interval = Date().timeIntervalSince(date)
    if interval < 60 { return "just now" }
    if interval < 3600 { return "\(Int(interval / 60)) min ago" }
    if interval < 86400 { return "\(Int(interval / 3600))h ago" }
    return "\(Int(interval / 86400))d ago"
}

func formatDuration(_ seconds: Double?) -> String {
    guard let seconds else { return "—" }
    if seconds < 1 { return String(format: "%.0fms", seconds * 1000) }
    if seconds < 60 { return String(format: "%.1fs", seconds) }
    let mins = Int(seconds) / 60
    let secs = Int(seconds) % 60
    return "\(mins)m \(secs)s"
}
