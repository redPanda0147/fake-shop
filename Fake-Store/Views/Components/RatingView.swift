import SwiftUI

struct RatingView: View {
    let rating: Rating?
    
    var body: some View {
        HStack(spacing: 4) {
            if let rating = rating {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                
                Text(String(format: "%.1f", rating.rate))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("(\(rating.count))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Text("No rating")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    RatingView(rating: Rating(rate: 4.5, count: 120))
} 